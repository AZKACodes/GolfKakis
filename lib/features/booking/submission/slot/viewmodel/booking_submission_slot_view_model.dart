import 'dart:async';

import 'package:golf_kakis/features/booking/submission/slot/domain/booking_submission_slot_use_case.dart';
import 'package:golf_kakis/features/foundation/default_values.dart';
import 'package:golf_kakis/features/foundation/enums/booking/time_period.dart';
import 'package:golf_kakis/features/foundation/model/request/booking_hold_request_model.dart';
import 'package:golf_kakis/features/foundation/model/booking_slot_model.dart';
import 'package:golf_kakis/features/foundation/model/booking_slot_details_model.dart';
import 'package:golf_kakis/features/foundation/model/golf_club_model.dart';
import 'package:golf_kakis/features/foundation/model/data_status_model.dart';
import 'package:golf_kakis/features/foundation/model/snackbar_message_model.dart';
import 'package:golf_kakis/features/foundation/util/date_util.dart';
import 'package:golf_kakis/features/foundation/util/phone_util.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_view_model.dart';

import 'booking_submission_slot_view_contract.dart';

class BookingSubmissionSlotViewModel
    extends
        MviViewModel<
          BookingSubmissionSlotUserIntent,
          BookingSubmissionSlotViewState,
          BookingSubmissionSlotNavEffect
        >
    implements BookingSubmissionSlotViewContract {
  BookingSubmissionSlotViewModel(this._useCase, {String? initialClubSlug})
    : _initialClubSlug = initialClubSlug ?? emptyString;

  final BookingSubmissionSlotUseCase _useCase;
  final String _initialClubSlug;

  StreamSubscription<DataStatusModel<List<GolfClubModel>>>?
  _golfClubSubscription;
  StreamSubscription<DataStatusModel<List<BookingSlotModel>>>?
  _slotSubscription;
  StreamSubscription<DataStatusModel<BookingSlotDetailsModel>>?
  _slotDetailsSubscription;
  StreamSubscription<DataStatusModel<dynamic>>? _holdSubscription;

  @override
  BookingSubmissionSlotViewState createInitialState() {
    return BookingSubmissionSlotDataLoaded.initial(
      selectedClubSlug: _initialClubSlug,
    );
  }

  @override
  Future<void> handleIntent(BookingSubmissionSlotUserIntent intent) async {
    switch (intent) {
      case OnInit():
        emitViewState((state) {
          return _derivePresentationState(
            getCurrentAsLoaded().copyWith(
              selectedDate: DateTime.now(),
              clearErrorMessage: true,
            ),
          );
        });
        await onFetchGolfClubList();
      case OnFetchGolfClubList():
        await onFetchGolfClubList();
      case OnFetchAvailableSlots():
        await onFetchAvailableSlots(
          clubSlug: intent.clubSlug,
          date: intent.date,
        );
      case OnSelectGolfClub():
        emitViewState((state) {
          return _derivePresentationState(
            getCurrentAsLoaded().copyWith(
              selectedClubSlug: intent.clubSlug,
              clearSelectedSupportedNine: true,
              clearSelectedSlot: true,
              clearSelectedSlotDetails: true,
              clearVisibleSelectedIndex: true,
              clearErrorMessage: true,
            ),
          );
        });
      case OnSelectSupportedNine():
        final nextState = _derivePresentationState(
          getCurrentAsLoaded().copyWith(
            selectedSupportedNine: intent.value,
            clearSelectedSlot: true,
            clearSelectedSlotDetails: true,
            clearVisibleSelectedIndex: true,
            clearErrorMessage: true,
          ),
        );
        emitViewState((state) {
          return nextState;
        });
        if (nextState.selectedClubSlug.isNotEmpty) {
          await onFetchAvailableSlots(
            clubSlug: nextState.selectedClubSlug,
            date: nextState.selectedDate,
          );
        }
      case OnPlayerCountChanged():
        emitViewState((state) {
          return _derivePresentationState(
            getCurrentAsLoaded().copyWith(
              playerCount: intent.value.clamp(2, 6),
              clearSelectedSlot: true,
              clearSelectedSlotDetails: true,
              clearVisibleSelectedIndex: true,
              clearErrorMessage: true,
            ),
          );
        });
      case OnSelectDate():
        await onSelectDate(intent.date);
      case OnSelectSlot():
        if (!intent.slot.isAvailable) {
          return;
        }

        emitViewState((state) {
          return _derivePresentationState(
            getCurrentAsLoaded().copyWith(
              selectedSlot: intent.slot,
              clearSelectedSlotDetails: true,
              clearErrorMessage: true,
            ),
          );
        });
      case OnSlotDetailsClick():
        if (!intent.slot.isAvailable) {
          return;
        }

        await _fetchSlotDetails(intent.slot);
      case OnConfirmSlotClick():
        final details = intent.details;
        final slot = _slotForDetails(details);
        if (slot == null || !slot.isAvailable) {
          return;
        }

        final nextState = _derivePresentationState(
          getCurrentAsLoaded().copyWith(
            selectedSlot: slot,
            selectedSlotDetails: details,
            clearErrorMessage: true,
          ),
        );
        emitViewState((state) {
          return nextState;
        });
        if (!nextState.canContinue || nextState.isSubmittingHold) {
          return;
        }
        sendNavEffect(
          () => RequestBookingHoldPrefill(selectedSlotDetails: details),
        );
      case OnCreateBookingHoldRequested():
        await _createBookingHold(intent);
      case OnSelectPeriod():
        emitViewState((state) {
          return _derivePresentationState(
            getCurrentAsLoaded().copyWith(
              selectedPeriod: intent.period,
              clearSelectedSlot: true,
              clearSelectedSlotDetails: true,
              clearVisibleSelectedIndex: true,
              clearErrorMessage: true,
            ),
          );
        });
      case OnBackClick():
        sendNavEffect(() => const NavigateBack());
      case OnContinueClick():
        final current = getCurrentAsLoaded();
        final selectedSlotDetails = current.selectedSlotDetails;
        if (!current.canContinue || selectedSlotDetails == null) {
          return;
        }

        sendNavEffect(
          () => RequestBookingHoldPrefill(
            selectedSlotDetails: selectedSlotDetails,
          ),
        );
    }
  }

  BookingSubmissionSlotDataLoaded getCurrentAsLoaded() {
    final state = currentState;
    if (state is BookingSubmissionSlotDataLoaded) {
      return state;
    }

    return BookingSubmissionSlotDataLoaded.initial(
      selectedClubSlug: _initialClubSlug,
    );
  }

  Future<void> _fetchSlotDetails(BookingSlotModel selectedSlot) async {
    final current = _derivePresentationState(
      getCurrentAsLoaded().copyWith(
        selectedSlot: selectedSlot,
        clearSelectedSlotDetails: true,
        isLoadingSlotDetails: true,
        clearErrorMessage: true,
      ),
    );
    if (!current.canActivateCalendar || current.selectedClubSlug.isEmpty) {
      return;
    }

    emitViewState((state) {
      return current;
    });

    await _slotDetailsSubscription?.cancel();
    final completer = Completer<void>();
    _slotDetailsSubscription = _useCase
        .onFetchSlotDetails(
          slotId: selectedSlot.slotId,
          clubSlug: current.selectedClubSlug,
          date: DateUtil.formatApiDate(current.selectedDate),
          playType: current.playTypeValue,
          playerCount: current.playerCount,
          selectedNine: null,
        )
        .listen((result) {
          switch (result.status) {
            case DataStatus.success:
              final details = result.data;
              emitViewState((state) {
                return _derivePresentationState(
                  getCurrentAsLoaded().copyWith(
                    selectedSlot: selectedSlot,
                    selectedSlotDetails: details,
                    isLoadingSlotDetails: false,
                    clearErrorMessage: true,
                  ),
                );
              });
              sendNavEffect(() => ShowSlotDetailsBottomSheet(details: details));
              if (!completer.isCompleted) {
                completer.complete();
              }
            case DataStatus.error:
              final message = result.apiMessage.isEmpty
                  ? 'Failed to fetch slot details'
                  : result.apiMessage;
              emitViewState((state) {
                return _derivePresentationState(
                  getCurrentAsLoaded().copyWith(
                    isLoadingSlotDetails: false,
                    clearSelectedSlotDetails: true,
                    errorSnackbarMessageModel: SnackbarMessageModel(
                      message: message,
                    ),
                  ),
                );
              });
              sendNavEffect(() => ShowErrorMessage(message));
              if (!completer.isCompleted) {
                completer.complete();
              }
            default:
              break;
          }
        });

    return completer.future;
  }

  Future<void> _createBookingHold(OnCreateBookingHoldRequested intent) async {
    final selectedSlotDetails = intent.selectedSlotDetails;
    final selectedSlot = _slotForDetails(selectedSlotDetails);
    final current = _derivePresentationState(
      getCurrentAsLoaded().copyWith(
        selectedSlot: selectedSlot,
        selectedSlotDetails: selectedSlotDetails,
        clearErrorMessage: true,
      ),
    );

    if (selectedSlot == null || !current.canContinue) {
      emitViewState((state) {
        return _derivePresentationState(
          current.copyWith(
            isSubmittingHold: false,
            errorSnackbarMessageModel: const SnackbarMessageModel(
              message: 'Please select an available slot before continuing.',
            ),
          ),
        );
      });
      return;
    }

    if (current.isSubmittingHold) {
      return;
    }

    emitViewState((state) {
      return current.copyWith(isSubmittingHold: true, clearErrorMessage: true);
    });

    await _holdSubscription?.cancel();
    final completer = Completer<void>();
    _holdSubscription = _useCase
        .onCreateBookingHold(
          request: _buildBookingHoldRequest(
            selectedSlotDetails: selectedSlotDetails,
            intent: intent,
          ),
        )
        .listen((result) {
          switch (result.status) {
            case DataStatus.success:
              final effect = _buildDetailNavEffect(
                selectedSlotDetails: selectedSlotDetails,
                hostName: intent.hostName,
                hostPhoneNumber: intent.hostPhoneNumber,
                guestId: intent.idempotencyKey,
                holdResponse: result.data,
              );
              if (effect == null) {
                _emitHoldFailure('Failed to hold booking. Please try again.');
              } else {
                emitViewState((state) {
                  return getCurrentAsLoaded().copyWith(
                    isSubmittingHold: false,
                    clearErrorMessage: true,
                  );
                });
                sendNavEffect(() => effect);
              }
              if (!completer.isCompleted) {
                completer.complete();
              }
            case DataStatus.error:
              _emitHoldFailure(
                result.apiMessage.isEmpty
                    ? 'Failed to hold booking. Please try again.'
                    : result.apiMessage,
              );
              if (!completer.isCompleted) {
                completer.complete();
              }
            default:
              break;
          }
        });

    return completer.future;
  }

  BookingHoldRequestModel _buildBookingHoldRequest({
    required BookingSlotDetailsModel selectedSlotDetails,
    required OnCreateBookingHoldRequested intent,
  }) {
    return BookingHoldRequestModel(
      slotId: selectedSlotDetails.slotId,
      accessToken: intent.accessToken,
      quoteId: selectedSlotDetails.quoteId,
      idempotencyKey: intent.idempotencyKey,
      hostName: intent.hostName,
      hostPhoneNumber: _normalizePhoneNumber(intent.hostPhoneNumber),
      source: intent.source,
      playType: selectedSlotDetails.playType,
      selectedNine: selectedSlotDetails.selectedNine,
      golfClubName: selectedSlotDetails.golfClubName,
      golfClubSlug: selectedSlotDetails.golfClubSlug,
      bookingDate: DateUtil.formatApiDate(selectedSlotDetails.bookingDate),
      teeTimeSlot: selectedSlotDetails.teeTimeSlot,
      playerCount: selectedSlotDetails.playerCount,
      normalPlayerCount: selectedSlotDetails.playerCount,
      seniorPlayerCount: 0,
      caddieCount: 0,
      golfCartCount: _defaultGolfCartCount(selectedSlotDetails.playerCount),
      paymentMethod: 'pay_counter',
    );
  }

  NavigateToBookingSubmissionDetail? _buildDetailNavEffect({
    required BookingSlotDetailsModel selectedSlotDetails,
    required String hostName,
    required String hostPhoneNumber,
    required String? guestId,
    required dynamic holdResponse,
  }) {
    if (holdResponse is! Map<String, dynamic>) {
      return null;
    }

    final bookingSummary = _readMap(holdResponse['bookingSummary']);
    final hostUser = _readMap(holdResponse['hostUser']);
    final pricing = _readMap(bookingSummary['pricing']);
    final playerCount =
        _readInt(bookingSummary['playerCount']) ??
        selectedSlotDetails.playerCount;
    final bookingDate =
        DateTime.tryParse(bookingSummary['bookingDate']?.toString() ?? '') ??
        selectedSlotDetails.bookingDate;
    final holdDurationSeconds =
        _readInt(holdResponse['holdDurationSeconds']) ?? 300;
    final holdExpiresAt =
        DateTime.tryParse(holdResponse['holdExpiresAt']?.toString() ?? '') ??
        DateTime.now().add(Duration(seconds: holdDurationSeconds));
    final resolvedHostName = _readNonEmptyString(hostUser['name']) ?? hostName;
    final resolvedHostPhoneNumber =
        _readNonEmptyString(hostUser['phoneNumber']) ?? hostPhoneNumber;

    return NavigateToBookingSubmissionDetail(
      slotId: selectedSlotDetails.slotId,
      bookingId: holdResponse['bookingId']?.toString() ?? emptyString,
      bookingRef: holdResponse['bookingRef']?.toString() ?? emptyString,
      holdDurationSeconds: holdDurationSeconds,
      holdExpiresAt: holdExpiresAt,
      playType:
          bookingSummary['playType']?.toString() ??
          selectedSlotDetails.playType,
      golfClubName:
          bookingSummary['golfClubName']?.toString() ??
          selectedSlotDetails.golfClubName,
      golfClubSlug:
          bookingSummary['golfClubSlug']?.toString() ??
          selectedSlotDetails.golfClubSlug,
      selectedDate: bookingDate,
      teeTimeSlot:
          bookingSummary['teeTimeSlot']?.toString() ??
          selectedSlotDetails.teeTimeSlot,
      pricePerPerson: selectedSlotDetails.pricePerPerson,
      currency: pricing['currency']?.toString() ?? selectedSlotDetails.currency,
      playerCount: playerCount,
      initialCaddieCount: _readInt(bookingSummary['caddieCount']) ?? 0,
      initialGolfCartCount:
          _readInt(bookingSummary['golfCartCount']) ??
          _defaultGolfCartCount(playerCount),
      selectedNine:
          _readNonEmptyString(bookingSummary['selectedNine']) ??
          selectedSlotDetails.selectedNine,
      initialPlayerName: resolvedHostName,
      initialPlayerPhoneNumber: _normalizePhoneNumber(resolvedHostPhoneNumber),
      guestId: guestId,
    );
  }

  void _emitHoldFailure(String message) {
    emitViewState((state) {
      return getCurrentAsLoaded().copyWith(
        isSubmittingHold: false,
        errorSnackbarMessageModel: SnackbarMessageModel(message: message),
      );
    });
    sendNavEffect(() => ShowErrorMessage(message));
  }

  Future<void> onFetchGolfClubList() async {
    emitViewState((state) {
      return _derivePresentationState(
        getCurrentAsLoaded().copyWith(isLoading: true, clearErrorMessage: true),
      );
    });

    await _golfClubSubscription?.cancel();
    _golfClubSubscription = _useCase.onFetchGolfClubList().listen((result) {
      switch (result.status) {
        case DataStatus.success:
          final current = getCurrentAsLoaded();
          final selectedClubSlug = _resolveSelectedClub(result.data);
          final updatedState = _derivePresentationState(
            current.copyWith(
              golfClubList: result.data,
              selectedClubSlug: selectedClubSlug,
              isLoading: false,
              clearErrorMessage: true,
            ),
          );
          emitViewState((state) {
            return updatedState;
          });
          if (updatedState.canActivateCalendar) {
            onFetchAvailableSlots(
              clubSlug: selectedClubSlug,
              date: updatedState.selectedDate,
            );
          }
        case DataStatus.error:
          final message = result.apiMessage.isEmpty
              ? 'Failed to fetch golf club list'
              : result.apiMessage;
          emitViewState((state) {
            return _derivePresentationState(
              getCurrentAsLoaded().copyWith(
                golfClubList: const <GolfClubModel>[],
                selectedClubSlug: emptyString,
                isLoading: false,
                errorSnackbarMessageModel: SnackbarMessageModel(
                  message: message,
                ),
              ),
            );
          });
          sendNavEffect(() => ShowErrorMessage(message));
        default:
          break;
      }
    });
  }

  Future<void> onSelectDate(DateTime date) async {
    final current = getCurrentAsLoaded();
    if (!current.canActivateCalendar) {
      return;
    }

    emitViewState((state) {
      return _derivePresentationState(
        current.copyWith(
          selectedDate: date,
          clearSelectedSlot: true,
          clearSelectedSlotDetails: true,
          clearVisibleSelectedIndex: true,
          clearErrorMessage: true,
        ),
      );
    });

    if (current.selectedClubSlug.isEmpty) {
      return;
    }

    await onFetchAvailableSlots(clubSlug: current.selectedClubSlug, date: date);
  }

  Future<void> onFetchAvailableSlots({
    required String clubSlug,
    required DateTime date,
  }) async {
    final requestState = _derivePresentationState(
      getCurrentAsLoaded().copyWith(
        selectedClubSlug: clubSlug,
        selectedDate: date,
      ),
    );
    if (!requestState.canActivateCalendar) {
      emitViewState((state) {
        return _derivePresentationState(
          requestState.copyWith(
            bookingSlots: const <BookingSlotModel>[],
            clearSelectedSlot: true,
            clearSelectedSlotDetails: true,
            clearVisibleSelectedIndex: true,
            isLoading: false,
            clearErrorMessage: true,
          ),
        );
      });
      return;
    }

    emitViewState((state) {
      return _derivePresentationState(
        requestState.copyWith(
          selectedClubSlug: clubSlug,
          selectedDate: date,
          clearSelectedSlot: true,
          clearSelectedSlotDetails: true,
          clearVisibleSelectedIndex: true,
          isLoading: true,
          clearErrorMessage: true,
        ),
      );
    });

    await _slotSubscription?.cancel();
    final completer = Completer<void>();
    _slotSubscription = _useCase
        .onFetchAvailableSlots(
          clubSlug: clubSlug,
          date: DateUtil.formatApiDate(date),
          playType: requestState.playTypeValue,
          playerCount: requestState.playerCount,
          selectedNine: null,
        )
        .listen((result) {
          switch (result.status) {
            case DataStatus.success:
              emitViewState((state) {
                return _derivePresentationState(
                  getCurrentAsLoaded().copyWith(
                    bookingSlots: result.data,
                    isLoading: false,
                    clearErrorMessage: true,
                  ),
                );
              });
              if (!completer.isCompleted) {
                completer.complete();
              }
            case DataStatus.error:
              final message = result.apiMessage.isEmpty
                  ? 'Failed to fetch available slots'
                  : result.apiMessage;
              emitViewState((state) {
                return _derivePresentationState(
                  getCurrentAsLoaded().copyWith(
                    bookingSlots: const <BookingSlotModel>[],
                    isLoading: false,
                    errorSnackbarMessageModel: SnackbarMessageModel(
                      message: message,
                    ),
                  ),
                );
              });
              sendNavEffect(() => ShowErrorMessage(message));
              if (!completer.isCompleted) {
                completer.complete();
              }
            default:
              break;
          }
        });
    return completer.future;
  }

  String _resolveSelectedClub(List<GolfClubModel> clubs) {
    if (clubs.isEmpty) {
      return emptyString;
    }

    final currentSelectedClubSlug = getCurrentAsLoaded().selectedClubSlug;
    if (currentSelectedClubSlug.isNotEmpty &&
        clubs.any((club) => club.slug == currentSelectedClubSlug)) {
      return currentSelectedClubSlug;
    }

    return emptyString;
  }

  BookingSubmissionSlotDataLoaded _derivePresentationState(
    BookingSubmissionSlotDataLoaded state,
  ) {
    final today = DateUtil.dateOnly(DateTime.now());
    final normalizedPlayerCount = state.playerCount.clamp(2, 6);
    final visibleSlots = state.bookingSlots
        .where((slot) => _isSlotInSelectedPeriod(slot, state.selectedPeriod))
        .toList();
    final visibleSelectedIndex = state.selectedSlot == null
        ? null
        : visibleSlots.indexWhere(
            (slot) => slot.time == state.selectedSlot!.time,
          );
    final availableSupportedNines = state.availableSupportedNines;
    final selectedSupportedNine =
        availableSupportedNines.contains(state.selectedSupportedNine)
        ? state.selectedSupportedNine
        : emptyString;
    final overCapacityIndices = visibleSlots.indexed
        .where(
          (entry) => entry.$2.remainingPlayerCapacity < normalizedPlayerCount,
        )
        .map((entry) => entry.$1)
        .toSet();
    final selectedSlotFitsCapacity =
        (state.selectedSlot?.remainingPlayerCapacity ?? 0) >=
        normalizedPlayerCount;
    final selectedDetailsMatchesSlot =
        state.selectedSlotDetails != null &&
        state.selectedSlotDetails!.slotId == state.selectedSlot?.slotId &&
        state.selectedSlotDetails!.playerCount == normalizedPlayerCount;

    return state.copyWith(
      playerCount: normalizedPlayerCount,
      selectedSupportedNine: selectedSupportedNine,
      selectedDate: DateUtil.dateOnly(state.selectedDate),
      pickerInitialDate: state.selectedDate.isBefore(today)
          ? today
          : DateUtil.dateOnly(state.selectedDate),
      visibleSlots: visibleSlots,
      visibleUnavailableIndices: <int>{
        ...visibleSlots.indexed
            .where((entry) => !entry.$2.isAvailable)
            .map((entry) => entry.$1),
        ...overCapacityIndices,
      },
      visibleSelectedIndex:
          visibleSelectedIndex == -1 || !selectedSlotFitsCapacity
          ? null
          : visibleSelectedIndex,
      canContinue:
          state.selectedClubSlug.isNotEmpty &&
          state.selectedSlot?.isAvailable == true &&
          selectedSlotFitsCapacity &&
          selectedDetailsMatchesSlot,
    );
  }

  bool _isSlotInSelectedPeriod(BookingSlotModel slot, TimePeriod period) {
    final slotPeriod = _periodForSlot(slot);
    return slotPeriod == null || slotPeriod == period;
  }

  TimePeriod? _periodForSlot(BookingSlotModel slot) {
    final normalizedTime = slot.time.toLowerCase();
    if (normalizedTime.contains('am')) {
      return TimePeriod.am;
    }
    if (normalizedTime.contains('pm')) {
      return TimePeriod.pm;
    }

    final startAt = slot.startAt;
    if (startAt != null) {
      return startAt.toLocal().hour < 12 ? TimePeriod.am : TimePeriod.pm;
    }

    return null;
  }

  BookingSlotModel? _slotForDetails(BookingSlotDetailsModel details) {
    for (final slot in getCurrentAsLoaded().bookingSlots) {
      if (slot.slotId == details.slotId) {
        return slot;
      }
    }

    return null;
  }

  Map<String, dynamic> _readMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    return <String, dynamic>{};
  }

  int? _readInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? emptyString);
  }

  String? _readNonEmptyString(dynamic value) {
    final normalized = value?.toString().trim() ?? emptyString;
    return normalized.isEmpty ? null : normalized;
  }

  int _defaultGolfCartCount(int playerCount) {
    if (playerCount <= 2) {
      return 1;
    }
    if (playerCount <= 4) {
      return 2;
    }
    return 3;
  }

  String _normalizePhoneNumber(String value) {
    final parts = PhoneUtil.splitPhoneNumber(value);
    if (parts.localNumber.isEmpty) {
      return value.replaceAll(' ', emptyString);
    }

    return PhoneUtil.normalizeFullPhoneNumber(
      countryCode: parts.countryCode,
      localNumber: parts.localNumber,
    );
  }

  @override
  void dispose() {
    _golfClubSubscription?.cancel();
    _slotSubscription?.cancel();
    _slotDetailsSubscription?.cancel();
    _holdSubscription?.cancel();
    super.dispose();
  }
}
