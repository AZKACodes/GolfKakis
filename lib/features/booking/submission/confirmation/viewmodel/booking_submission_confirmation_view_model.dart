import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:golf_kakis/features/booking/submission/slot/domain/booking_submission_slot_use_case.dart';
import 'package:golf_kakis/features/foundation/model/request/booking_submission_request_model.dart';
import 'package:golf_kakis/features/foundation/model/data_status_model.dart';
import 'package:golf_kakis/features/foundation/model/booking_submission_player_model.dart';
import 'package:golf_kakis/features/foundation/model/snackbar_message_model.dart';
import 'package:golf_kakis/features/foundation/util/date_util.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_view_model.dart';

import 'booking_submission_confirmation_view_contract.dart';

class BookingSubmissionConfirmationViewModel
    extends
        MviViewModel<
          BookingSubmissionConfirmationUserIntent,
          BookingSubmissionConfirmationViewState,
          BookingSubmissionConfirmationNavEffect
        >
    implements BookingSubmissionConfirmationViewContract {
  BookingSubmissionConfirmationViewModel(this._useCase);

  final BookingSubmissionSlotUseCase _useCase;
  StreamSubscription<DataStatusModel<dynamic>>? _submissionSubscription;
  StreamSubscription<DataStatusModel<dynamic>>? _extendHoldSubscription;
  StreamSubscription<DataStatusModel<dynamic>>? _previewSubscription;
  Timer? _holdCountdownTimer;
  bool _hasShownExpiryDialog = false;

  @override
  BookingSubmissionConfirmationViewState createInitialState() {
    return BookingSubmissionConfirmationDataLoaded.initial();
  }

  @override
  Future<void> handleIntent(
    BookingSubmissionConfirmationUserIntent intent,
  ) async {
    switch (intent) {
      case OnInit():
        emitViewState((state) {
          return getCurrentAsLoaded().copyWith(
            bookingRef: intent.bookingRef,
            holdDurationSeconds: intent.holdDurationSeconds,
            holdExpiresAt: intent.holdExpiresAt,
            golfClubName: intent.golfClubName,
            golfClubSlug: intent.golfClubSlug,
            selectedDate: intent.selectedDate,
            teeTimeSlot: intent.teeTimeSlot,
            pricePerPerson: intent.pricePerPerson,
            currency: intent.currency,
            guestId: intent.guestId,
            hostName: intent.hostName,
            hostPhoneNumber: intent.hostPhoneNumber,
            playerCount: intent.playerCount,
            selectedNine: intent.selectedNine,
            caddieCount: intent.caddieCount,
            golfCartCount: intent.golfCartCount,
            playerDetails: intent.playerDetails,
            accessToken: intent.accessToken,
            remainingHoldSeconds: _remainingSecondsUntil(intent.holdExpiresAt),
            isHoldExpired: _remainingSecondsUntil(intent.holdExpiresAt) <= 0,
            clearErrorMessage: true,
          );
        });
        _hasShownExpiryDialog = false;
        _startHoldCountdown();
        await _previewBooking();
      case OnBackClick():
        sendNavEffect(() => const NavigateBack());
      case OnConfirmClick():
        final current = getCurrentAsLoaded();
        if (current.isSubmitting ||
            current.isHoldExpired ||
            current.isPreviewPending) {
          return;
        }
        await _createBookingSubmission(current);
      case OnExtendBookingHoldClick():
        await _extendBookingHold(intent.accessToken);
      case OnAccessTokenAvailable():
        emitViewState((state) {
          return getCurrentAsLoaded().copyWith(accessToken: intent.value);
        });
        await _previewBooking();
      case OnVoucherCodeApplied():
        emitViewState((state) {
          return getCurrentAsLoaded().copyWith(
            voucherCode: intent.value.trim(),
          );
        });
        await _previewBooking();
      case OnVoucherRemoved():
        emitViewState((state) {
          return getCurrentAsLoaded().copyWith(clearVoucher: true);
        });
        await _previewBooking();
    }
  }

  BookingSubmissionConfirmationDataLoaded getCurrentAsLoaded() {
    final state = currentState;
    if (state is BookingSubmissionConfirmationDataLoaded) {
      return state;
    }

    return BookingSubmissionConfirmationDataLoaded.initial();
  }

  Future<void> _createBookingSubmission(
    BookingSubmissionConfirmationDataLoaded current,
  ) async {
    debugPrint(
      '[onSubmitBooking] started bookingRef=${current.bookingRef} '
      'accessTokenPresent=${current.accessToken.trim().isNotEmpty}',
    );
    if (_remainingSecondsUntil(current.holdExpiresAt) <= 0) {
      debugPrint('[onSubmitBooking] blocked because hold expired');
      emitViewState((state) {
        return current.copyWith(
          isHoldExpired: true,
          remainingHoldSeconds: 0,
          errorSnackbarMessageModel: const SnackbarMessageModel(
            message: 'Your booking session has expired. Please start again.',
          ),
        );
      });
      if (!_hasShownExpiryDialog) {
        _hasShownExpiryDialog = true;
        sendNavEffect(() => const ShowBookingSessionExpired());
      }
      return;
    }

    emitViewState((state) {
      return getCurrentAsLoaded().copyWith(
        isSubmitting: true,
        clearErrorMessage: true,
      );
    });

    await _submissionSubscription?.cancel();
    var hasHandledSubmissionResult = false;
    final completer = Completer<void>();
    final request = _buildRequest(current);
    debugPrint('[onSubmitBooking] request: ${jsonEncode(request.toJson())}');
    _submissionSubscription = _useCase
        .onCreateBookingSubmission(request: request)
        .listen(
          (result) {
            debugPrint(
              '[onSubmitBooking] stream event status=${result.status.name} '
              'code=${result.rawResponseCode} message=${result.apiMessage}',
            );
            switch (result.status) {
              case DataStatus.success:
                debugPrint(
                  '[onSubmitBooking] success payload: ${jsonEncode(result.data)}',
                );
                hasHandledSubmissionResult = true;
                _navigateToSubmissionSuccess(result.data);
                if (!completer.isCompleted) {
                  completer.complete();
                }
              case DataStatus.error:
                debugPrint(
                  '[onSubmitBooking] error response: ${result.apiMessage}',
                );
                hasHandledSubmissionResult = true;
                emitViewState((state) {
                  return getCurrentAsLoaded().copyWith(
                    isSubmitting: false,
                    errorSnackbarMessageModel: SnackbarMessageModel(
                      message: result.apiMessage.isEmpty
                          ? 'Failed to submit booking. Please try again.'
                          : result.apiMessage,
                    ),
                  );
                });
                if (!completer.isCompleted) {
                  completer.complete();
                }
              default:
                break;
            }
          },
          onError: (Object error) {
            debugPrint('[onSubmitBooking] stream error: $error');
            hasHandledSubmissionResult = true;
            emitViewState((state) {
              return getCurrentAsLoaded().copyWith(
                isSubmitting: false,
                errorSnackbarMessageModel: SnackbarMessageModel(
                  message: error.toString().isEmpty
                      ? 'Failed to submit booking. Please try again.'
                      : error.toString(),
                ),
              );
            });
            if (!completer.isCompleted) {
              completer.complete();
            }
          },
          onDone: () {
            debugPrint(
              '[onSubmitBooking] stream done '
              'hasHandledSubmissionResult=$hasHandledSubmissionResult '
              'isSubmitting=${getCurrentAsLoaded().isSubmitting}',
            );
            if (!hasHandledSubmissionResult &&
                getCurrentAsLoaded().isSubmitting) {
              _navigateToSubmissionSuccess(null);
            }
            if (!completer.isCompleted) {
              completer.complete();
            }
          },
        );

    return completer.future;
  }

  void _navigateToSubmissionSuccess(dynamic response) {
    final latest = getCurrentAsLoaded();
    final payload = _readMap(response);
    final summary = _readMap(payload['bookingSummary']);
    final pricing = _readMap(payload['pricing']);
    final bookingRef = _resolveBookingRef(response) ?? latest.bookingRef;
    final bookingId = _resolveBookingId(response);
    debugPrint(
      '[onSubmitBooking] navigating success '
      'bookingId=$bookingId bookingRef=$bookingRef '
      'payloadKeys=${payload.keys.toList()}',
    );
    if (bookingRef.isEmpty) {
      debugPrint('[onSubmitBooking] navigation blocked: missing bookingRef');
      emitViewState((state) {
        return latest.copyWith(
          isSubmitting: false,
          errorSnackbarMessageModel: const SnackbarMessageModel(
            message:
                'Booking submission succeeded without a booking reference.',
          ),
        );
      });
      return;
    }

    _holdCountdownTimer?.cancel();
    emitViewState((state) {
      return latest.copyWith(isSubmitting: false, clearErrorMessage: true);
    });
    sendNavEffect(
      () => NavigateToBookingSubmissionSuccess(
        bookingId: bookingId,
        bookingRef: bookingRef,
        bookingStatus: payload['status']?.toString() ?? 'confirmed',
        bookingDate:
            summary['bookingDate']?.toString() ??
            DateUtil.formatApiDate(latest.selectedDate),
        golfClubName:
            summary['golfClubName']?.toString() ?? latest.golfClubName,
        golfClubSlug: latest.golfClubSlug,
        teeTimeSlot: summary['teeTimeSlot']?.toString() ?? latest.teeTimeSlot,
        pricePerPerson: latest.pricePerPerson,
        currency: pricing['currency']?.toString() ?? latest.currency,
        paymentMethod:
            summary['paymentMethod']?.toString() ?? latest.paymentMethodLabel,
        greenFeeTotal:
            _readDouble(pricing['greenFeeTotal']) ?? latest.greenFeeTotal,
        buggyEstimatedTotal:
            _readDouble(pricing['buggyEstimatedTotal']) ??
            latest.buggyEstimatedTotal,
        caddieTotal: _readDouble(pricing['caddieTotal']) ?? latest.caddieTotal,
        insuranceTotal:
            _readDouble(pricing['insuranceTotal']) ?? latest.insuranceTotal,
        sstTotal: _readDouble(pricing['sstTotal']) ?? latest.sstTotal,
        discountAmount:
            _readDouble(pricing['discountAmount']) ?? latest.discountAmount,
        finalAmount:
            _readDouble(pricing['finalAmount']) ??
            _readDouble(pricing['grandTotal']) ??
            latest.totalCost,
        hostName: latest.hostName,
        hostPhoneNumber: latest.hostPhoneNumber,
        playerCount: _readInt(summary['playerCount']) ?? latest.playerCount,
        caddieCount: latest.caddieCount,
        golfCartCount:
            _readInt(summary['buggyQuantity']) ?? latest.golfCartCount,
      ),
    );
  }

  BookingSubmissionRequestModel _buildRequest(
    BookingSubmissionConfirmationDataLoaded current,
  ) {
    return BookingSubmissionRequestModel(
      bookingRef: current.bookingRef,
      caddieArrangement: current.caddieCount > 0 ? 'requested' : 'none',
      buggyQuantity: current.golfCartCount,
      playerDetails: _buildPlayerDetails(current),
      accessToken: current.accessToken,
      voucherCode: current.voucherCode,
      acknowledgedTerms: true,
    );
  }

  Future<void> _previewBooking() async {
    final current = getCurrentAsLoaded();
    if (current.accessToken.trim().isEmpty ||
        current.bookingRef.trim().isEmpty ||
        current.isHoldExpired) {
      return;
    }

    emitViewState((state) {
      return getCurrentAsLoaded().copyWith(
        isPreviewLoading: true,
        clearErrorMessage: true,
      );
    });

    final request = _buildPreviewRequest(current);
    debugPrint('[PreviewBooking] request: ${jsonEncode(request)}');

    await _previewSubscription?.cancel();
    _previewSubscription = _useCase
        .onPreviewBooking(accessToken: current.accessToken, request: request)
        .listen((result) {
          switch (result.status) {
            case DataStatus.success:
              debugPrint(
                '[PreviewBooking] response: ${jsonEncode(result.data)}',
              );
              final latest = getCurrentAsLoaded();
              final payload = _readMap(result.data);
              final summary = _readMap(payload['bookingSummary']);
              final pricing = _readMap(payload['pricing']);
              final voucher = _readMap(pricing['voucher']);
              final hasResponseVoucher = voucher.isNotEmpty;

              emitViewState((state) {
                return latest.copyWith(
                  bookingRef:
                      payload['bookingRef']?.toString() ?? latest.bookingRef,
                  golfClubName:
                      summary['golfClubName']?.toString() ??
                      latest.golfClubName,
                  teeTimeSlot:
                      summary['teeTimeSlot']?.toString() ?? latest.teeTimeSlot,
                  playerCount:
                      _readInt(summary['playerCount']) ?? latest.playerCount,
                  caddieCount: _caddieCountFromArrangement(
                    summary['caddieArrangement']?.toString(),
                    latest.caddieCount,
                  ),
                  golfCartCount:
                      _readInt(summary['buggyQuantity']) ??
                      latest.golfCartCount,
                  currency: pricing['currency']?.toString() ?? latest.currency,
                  greenFeeTotal:
                      _readDouble(pricing['greenFeeTotal']) ??
                      latest.greenFeeTotal,
                  buggyEstimatedTotal:
                      _readDouble(pricing['buggyEstimatedTotal']) ??
                      latest.buggyEstimatedTotal,
                  caddieTotal:
                      _readDouble(pricing['caddieTotal']) ?? latest.caddieTotal,
                  insuranceTotal:
                      _readDouble(pricing['insuranceTotal']) ??
                      latest.insuranceTotal,
                  sstTotal: _readDouble(pricing['sstTotal']) ?? latest.sstTotal,
                  subtotalAmount:
                      _readDouble(pricing['subtotalAmount']) ??
                      latest.subtotalAmount,
                  discountAmount:
                      _readDouble(pricing['discountAmount']) ??
                      latest.discountAmount,
                  finalAmount:
                      _readDouble(pricing['finalAmount']) ??
                      _readDouble(pricing['grandTotal']) ??
                      latest.finalAmount,
                  voucherCode: hasResponseVoucher
                      ? (voucher['code']?.toString() ?? latest.voucherCode)
                      : '',
                  voucherName: hasResponseVoucher
                      ? (voucher['name']?.toString() ?? latest.voucherName)
                      : '',
                  voucherDiscountType: hasResponseVoucher
                      ? (voucher['discountType']?.toString() ??
                            latest.voucherDiscountType)
                      : '',
                  voucherDiscountValue: hasResponseVoucher
                      ? (_readDouble(voucher['discountValue']) ??
                            latest.voucherDiscountValue)
                      : 0,
                  voucherAutoApplied: hasResponseVoucher
                      ? (_readBool(voucher['autoApplied']) ??
                            latest.voucherAutoApplied)
                      : false,
                  hasPreviewPricing: true,
                  isPreviewLoading: false,
                  clearErrorMessage: true,
                );
              });
            case DataStatus.error:
              debugPrint(
                '[PreviewBooking] error: ${result.rawResponseCode} ${result.apiMessage}',
              );
              emitViewState((state) {
                return getCurrentAsLoaded().copyWith(
                  isPreviewLoading: false,
                  errorSnackbarMessageModel: SnackbarMessageModel(
                    message: result.apiMessage.isEmpty
                        ? 'Failed to preview booking. Please try again.'
                        : result.apiMessage,
                  ),
                );
              });
            default:
              break;
          }
        });
  }

  Map<String, dynamic> _buildPreviewRequest(
    BookingSubmissionConfirmationDataLoaded current,
  ) {
    return <String, dynamic>{
      'bookingRef': current.bookingRef,
      'caddieArrangement': current.caddieCount > 0 ? 'requested' : 'none',
      'buggyQuantity': current.golfCartCount,
      'playerDetails': current.playerDetails.indexed.map((entry) {
        return entry.$2.copyWith(isHost: entry.$1 == 0).toJson();
      }).toList(),
      if (current.voucherCode.trim().isNotEmpty)
        'voucherCode': current.voucherCode.trim(),
    };
  }

  List<BookingSubmissionPlayerModel> _buildPlayerDetails(
    BookingSubmissionConfirmationDataLoaded current,
  ) {
    return current.playerDetails.indexed.map((entry) {
      final index = entry.$1;
      final player = entry.$2;
      return player.copyWith(isHost: index == 0);
    }).toList();
  }

  String _resolveBookingId(dynamic response) {
    if (response is Map<String, dynamic>) {
      final dynamic bookingId =
          response['bookingId'] ??
          response['booking_id'] ??
          response['id'] ??
          response['reference'] ??
          response['bookingReference'];
      if (bookingId is String && bookingId.trim().isNotEmpty) {
        return bookingId;
      }
      if (bookingId != null) {
        return bookingId.toString();
      }
    }

    return '';
  }

  String? _resolveBookingRef(dynamic response) {
    if (response is Map<String, dynamic>) {
      final dynamic bookingRef =
          response['bookingRef'] ?? response['bookingReference'];
      if (bookingRef is String && bookingRef.trim().isNotEmpty) {
        return bookingRef;
      }
      if (bookingRef != null) {
        return bookingRef.toString();
      }
    }

    return null;
  }

  void _startHoldCountdown() {
    _holdCountdownTimer?.cancel();
    _tickHoldCountdown();
    _holdCountdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _tickHoldCountdown();
    });
  }

  void _tickHoldCountdown() {
    final current = getCurrentAsLoaded();
    final remainingHoldSeconds = _remainingSecondsUntil(current.holdExpiresAt);
    final isHoldExpired = remainingHoldSeconds <= 0;

    emitViewState((state) {
      return current.copyWith(
        remainingHoldSeconds: remainingHoldSeconds,
        isHoldExpired: isHoldExpired,
      );
    });

    if (remainingHoldSeconds <= 60 && !_hasShownExpiryDialog) {
      _hasShownExpiryDialog = true;
      sendNavEffect(() => const ShowBookingSessionExpired());
    }

    if (isHoldExpired) {
      _holdCountdownTimer?.cancel();
    }
  }

  Future<void> _extendBookingHold(String accessToken) async {
    final current = getCurrentAsLoaded();
    if (current.bookingRef.trim().isEmpty || accessToken.trim().isEmpty) {
      sendNavEffect(
        () => const ShowErrorMessage(
          'Unable to extend this booking hold. Please try again.',
        ),
      );
      return;
    }

    emitViewState((state) {
      return current.copyWith(isExtendingHold: true, clearErrorMessage: true);
    });

    await _extendHoldSubscription?.cancel();
    _extendHoldSubscription = _useCase
        .onExtendBookingHold(
          bookingRef: current.bookingRef,
          accessToken: accessToken,
        )
        .listen((result) {
          switch (result.status) {
            case DataStatus.success:
              final latest = getCurrentAsLoaded();
              final payload = _readMap(result.data);
              final holdDurationSeconds =
                  _readInt(
                    payload['holdDurationSeconds'] ??
                        payload['hold_duration_seconds'],
                  ) ??
                  latest.holdDurationSeconds;
              final holdExpiresAt =
                  DateTime.tryParse(
                    payload['holdExpiresAt']?.toString() ??
                        payload['hold_expires_at']?.toString() ??
                        '',
                  ) ??
                  DateTime.now().add(Duration(seconds: holdDurationSeconds));
              final remainingHoldSeconds = _remainingSecondsUntil(
                holdExpiresAt,
              );

              emitViewState((state) {
                return latest.copyWith(
                  bookingRef:
                      payload['bookingRef']?.toString() ??
                      payload['booking_ref']?.toString() ??
                      latest.bookingRef,
                  holdDurationSeconds: holdDurationSeconds,
                  holdExpiresAt: holdExpiresAt,
                  remainingHoldSeconds: remainingHoldSeconds,
                  isHoldExpired: false,
                  isExtendingHold: false,
                  clearErrorMessage: true,
                );
              });
              _hasShownExpiryDialog = false;
              _startHoldCountdown();
              sendNavEffect(() => const DismissBookingSessionExpired());
            case DataStatus.error:
              emitViewState((state) {
                return getCurrentAsLoaded().copyWith(
                  isExtendingHold: false,
                  errorSnackbarMessageModel: SnackbarMessageModel(
                    message: result.apiMessage.isEmpty
                        ? 'Failed to extend booking hold. Please try again.'
                        : result.apiMessage,
                  ),
                );
              });
              sendNavEffect(
                () => ShowErrorMessage(
                  result.apiMessage.isEmpty
                      ? 'Failed to extend booking hold. Please try again.'
                      : result.apiMessage,
                ),
              );
            default:
              break;
          }
        });
  }

  int _remainingSecondsUntil(DateTime expiresAt) {
    final difference = expiresAt.difference(DateTime.now()).inSeconds;
    return difference < 0 ? 0 : difference;
  }

  Map<String, dynamic> _readMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    return <String, dynamic>{};
  }

  int? _readInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '');
  }

  double? _readDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '');
  }

  bool? _readBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    final text = value?.toString().toLowerCase();
    if (text == 'true') {
      return true;
    }
    if (text == 'false') {
      return false;
    }
    return null;
  }

  int _caddieCountFromArrangement(String? value, int fallback) {
    final normalized = value?.trim().toLowerCase() ?? '';
    if (normalized.isEmpty) {
      return fallback;
    }
    if (normalized == 'none') {
      return 0;
    }
    return fallback == 0 ? 1 : fallback;
  }

  @override
  void dispose() {
    _holdCountdownTimer?.cancel();
    _submissionSubscription?.cancel();
    _extendHoldSubscription?.cancel();
    _previewSubscription?.cancel();
    super.dispose();
  }
}
