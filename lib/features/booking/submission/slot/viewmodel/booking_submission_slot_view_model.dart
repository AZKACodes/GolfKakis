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
  BookingSubmissionSlotViewModel(
    this._useCase, {
    String? initialClubSlug,
    GolfClubModel? initialClub,
    int? initialPlayerCount,
  }) : _initialClubSlug = initialClubSlug ?? emptyString,
       _initialClub = initialClub,
       _initialPlayerCount = initialPlayerCount ?? 2;

  final BookingSubmissionSlotUseCase _useCase;
  final String _initialClubSlug;
  final GolfClubModel? _initialClub;
  final int _initialPlayerCount;

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
      selectedClub: _initialClub,
      playerCount: _initialPlayerCount,
    );
  }

  @override
  Future<void> handleIntent(BookingSubmissionSlotUserIntent intent) async {
    switch (intent) {
      case OnInit():
        final nextState = _derivePresentationState(
          getCurrentAsLoaded().copyWith(
            selectedDate: DateTime.now(),
            clearErrorMessage: true,
          ),
        );
        emitViewState((state) => nextState);
        if (nextState.canActivateCalendar &&
            nextState.selectedClubSlug.isNotEmpty) {
          await onFetchAvailableSlots(
            clubSlug: nextState.selectedClubSlug,
            date: nextState.selectedDate,
          );
        }
      case OnFetchGolfClubList():
        await onFetchGolfClubList();
      case OnFetchAvailableSlots():
        await onFetchAvailableSlots(
          clubSlug: intent.clubSlug,
          date: intent.date,
        );
      case OnSelectGolfClub():
        GolfClubModel? selectedClub;
        for (final club in getCurrentAsLoaded().golfClubList) {
          if (club.slug == intent.clubSlug) {
            selectedClub = club;
            break;
          }
        }
        if (selectedClub == null ||
            !isGolfClubEnabledForCurrentRelease(selectedClub)) {
          const message =
              'Only Kinrara Golf Club is available for booking right now.';
          emitViewState((state) {
            return getCurrentAsLoaded().copyWith(
              errorSnackbarMessageModel: const SnackbarMessageModel(
                message: message,
              ),
            );
          });
          sendNavEffect(() => const ShowErrorMessage(message));
          return;
        }
        final nextState = _derivePresentationState(
          getCurrentAsLoaded().copyWith(
            selectedClubSlug: intent.clubSlug,
            clearSelectedSupportedNine: true,
            clearSelectedSlot: true,
            clearSelectedSlotDetails: true,
            clearVisibleSelectedIndex: true,
            clearErrorMessage: true,
          ),
        );
        emitViewState((state) {
          return nextState;
        });
        await onFetchAvailableSlots(
          clubSlug: nextState.selectedClubSlug,
          date: nextState.selectedDate,
        );
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
        final current = getCurrentAsLoaded();
        final nextState = _derivePresentationState(
          current.copyWith(
            playerCount: intent.value.clamp(2, 6),
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
      case OnSelectDate():
        await onSelectDate(intent.date);
      case OnSelectSlot():
        if (!_isSlotBookable(intent.slot, getCurrentAsLoaded())) {
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
        if (!_isSlotBookable(intent.slot, getCurrentAsLoaded())) {
          return;
        }

        sendNavEffect(() => const ShowSlotDetailsBottomSheet());
        await _fetchSlotDetails(intent.slot);
      case OnConfirmSlotClick():
        final details = intent.details;
        final slot = _slotForDetails(details);
        if (slot == null || !_isSlotBookable(slot, getCurrentAsLoaded())) {
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
          if (!nextState.canContinue) {
            const message = 'Selected player count exceeds this slot capacity.';
            emitViewState((state) {
              return getCurrentAsLoaded().copyWith(
                errorSnackbarMessageModel: const SnackbarMessageModel(
                  message: message,
                ),
              );
            });
            sendNavEffect(() => const ShowErrorMessage(message));
          }
          return;
        }
        sendNavEffect(
          () => RequestBookingHoldPrefill(selectedSlotDetails: details),
        );
      case OnSlotDetailsDismissed():
        await _slotDetailsSubscription?.cancel();
        emitViewState((state) {
          return _derivePresentationState(
            getCurrentAsLoaded().copyWith(
              clearSelectedSlot: true,
              clearSelectedSlotDetails: true,
              clearVisibleSelectedIndex: true,
              isLoadingSlotDetails: false,
              clearErrorMessage: true,
            ),
          );
        });
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
      selectedClub: _initialClub,
      playerCount: _initialPlayerCount,
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
      idempotencyKey: intent.idempotencyKey,
      hostName: intent.hostName,
      hostPhoneNumber: _normalizePhoneNumber(intent.hostPhoneNumber),
      source: intent.source,
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

    final bookingSummary = _readMap(
      holdResponse['bookingSummary'] ??
          holdResponse['booking_summary'] ??
          holdResponse['summary'] ??
          holdResponse['booking'],
    );
    final hostUser = _readMap(
      holdResponse['hostUser'] ??
          holdResponse['host_user'] ??
          holdResponse['host'] ??
          holdResponse['user'],
    );
    final pricing = _readMap(
      bookingSummary['pricing'] ?? holdResponse['pricing'],
    );
    final playerCount =
        _readInt(
          _readPayloadValue(bookingSummary, holdResponse, const <String>[
            'playerCount',
            'player_count',
          ]),
        ) ??
        selectedSlotDetails.playerCount;
    final bookingDate =
        DateTime.tryParse(
          _readPayloadValue(bookingSummary, holdResponse, const <String>[
                'bookingDate',
                'booking_date',
              ])?.toString() ??
              '',
        ) ??
        selectedSlotDetails.bookingDate;
    final holdDurationSeconds =
        _readInt(
          _readPayloadValue(bookingSummary, holdResponse, const <String>[
            'holdDurationSeconds',
            'hold_duration_seconds',
          ]),
        ) ??
        300;
    final holdExpiresAt =
        DateTime.tryParse(
          _readPayloadValue(bookingSummary, holdResponse, const <String>[
                'holdExpiresAt',
                'hold_expires_at',
                'expiresAt',
                'expires_at',
              ])?.toString() ??
              '',
        ) ??
        DateTime.now().add(Duration(seconds: holdDurationSeconds));
    final resolvedHostName =
        _readNonEmptyString(
          hostUser['name'] ??
              _readPayloadValue(bookingSummary, holdResponse, const <String>[
                'hostName',
                'host_name',
              ]),
        ) ??
        hostName;
    final resolvedHostPhoneNumber =
        _readNonEmptyString(
          hostUser['phoneNumber'] ??
              hostUser['phone_number'] ??
              _readPayloadValue(bookingSummary, holdResponse, const <String>[
                'hostPhoneNumber',
                'host_phone_number',
              ]),
        ) ??
        hostPhoneNumber;

    return NavigateToBookingSubmissionDetail(
      slotId: selectedSlotDetails.slotId,
      bookingId:
          _readNonEmptyString(
            _readPayloadValue(bookingSummary, holdResponse, const <String>[
              'bookingId',
              'booking_id',
              'holdId',
              'hold_id',
              'id',
            ]),
          ) ??
          emptyString,
      bookingRef:
          _readNonEmptyString(
            _readPayloadValue(bookingSummary, holdResponse, const <String>[
              'bookingRef',
              'bookingReference',
              'booking_ref',
              'booking_reference',
              'reference',
              'referenceNo',
              'reference_no',
            ]),
          ) ??
          emptyString,
      holdDurationSeconds: holdDurationSeconds,
      holdExpiresAt: holdExpiresAt,
      playType:
          _readPayloadValue(bookingSummary, holdResponse, const <String>[
            'playType',
            'play_type',
          ])?.toString() ??
          selectedSlotDetails.playType,
      golfClubName:
          _readPayloadValue(bookingSummary, holdResponse, const <String>[
            'golfClubName',
            'golf_club_name',
          ])?.toString() ??
          selectedSlotDetails.golfClubName,
      golfClubSlug:
          _readPayloadValue(bookingSummary, holdResponse, const <String>[
            'golfClubSlug',
            'golf_club_slug',
          ])?.toString() ??
          selectedSlotDetails.golfClubSlug,
      selectedDate: bookingDate,
      teeTimeSlot:
          _readPayloadValue(bookingSummary, holdResponse, const <String>[
            'teeTimeSlot',
            'tee_time_slot',
          ])?.toString() ??
          selectedSlotDetails.teeTimeSlot,
      pricePerPerson: selectedSlotDetails.pricePerPerson,
      currency:
          pricing['currency']?.toString() ??
          holdResponse['currency']?.toString() ??
          selectedSlotDetails.currency,
      playerCount: playerCount,
      initialCaddieCount:
          _readInt(
            _readPayloadValue(bookingSummary, holdResponse, const <String>[
              'caddieCount',
              'caddie_count',
              'caddyCount',
              'caddy_count',
            ]),
          ) ??
          0,
      initialGolfCartCount:
          _readInt(
            _readPayloadValue(bookingSummary, holdResponse, const <String>[
              'golfCartCount',
              'golf_cart_count',
              'buggyCount',
              'buggy_count',
            ]),
          ) ??
          _defaultGolfCartCount(playerCount),
      selectedNine:
          _readNonEmptyString(
            _readPayloadValue(bookingSummary, holdResponse, const <String>[
              'selectedNine',
              'selected_nine',
            ]),
          ) ??
          selectedSlotDetails.selectedNine,
      initialPlayerName: resolvedHostName,
      initialPlayerPhoneNumber: _normalizePhoneNumber(resolvedHostPhoneNumber),
      guestId: guestId,
    );
  }

  dynamic _readPayloadValue(
    Map<String, dynamic> primary,
    Map<String, dynamic> fallback,
    List<String> keys,
  ) {
    for (final key in keys) {
      final primaryValue = primary[key];
      if (primaryValue != null) {
        return primaryValue;
      }

      final fallbackValue = fallback[key];
      if (fallbackValue != null) {
        return fallbackValue;
      }
    }

    return null;
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
    final completer = Completer<void>();
    _golfClubSubscription = _useCase.onFetchGolfClubList().listen((result) {
      switch (result.status) {
        case DataStatus.success:
          final current = getCurrentAsLoaded();
          final golfClubList = _applyCurrentReleaseGolfClubAvailability(
            result.data,
          );
          final selectedClubSlug = _resolveSelectedClub(golfClubList);
          final updatedState = _derivePresentationState(
            current.copyWith(
              golfClubList: golfClubList,
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
          if (!completer.isCompleted) {
            completer.complete();
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
          if (!completer.isCompleted) {
            completer.complete();
          }
        default:
          break;
      }
    });
    return completer.future;
  }

  Future<void> onSelectDate(DateTime date) async {
    final current = getCurrentAsLoaded();
    if (!current.canActivateCalendar) {
      return;
    }

    final today = DateUtil.dateOnly(DateTime.now());
    final selectedDate = DateUtil.dateOnly(date);
    final selectedPeriod = selectedDate == today
        ? currentTimePeriod()
        : TimePeriod.am;

    emitViewState((state) {
      return _derivePresentationState(
        current.copyWith(
          selectedDate: selectedDate,
          selectedPeriod: selectedPeriod,
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
        clubs.any(
          (club) =>
              club.slug == currentSelectedClubSlug &&
              isGolfClubEnabledForCurrentRelease(club),
        )) {
      return currentSelectedClubSlug;
    }

    for (final club in clubs) {
      if (isGolfClubEnabledForCurrentRelease(club)) {
        return club.slug;
      }
    }

    return emptyString;
  }

  List<GolfClubModel> _applyCurrentReleaseGolfClubAvailability(
    List<GolfClubModel> clubs,
  ) {
    return clubs.map((club) {
      final isEnabled = isGolfClubEnabledForCurrentRelease(club);
      return club.copyWith(
        isEnabled: isEnabled,
        isBookable: isEnabled,
        availabilityLabel: isEnabled ? 'Booking available' : 'Coming soon',
      );
    }).toList();
  }

  BookingSubmissionSlotDataLoaded _derivePresentationState(
    BookingSubmissionSlotDataLoaded state,
  ) {
    final today = DateUtil.dateOnly(DateTime.now());
    final selectedDate = DateUtil.dateOnly(state.selectedDate);
    final selectedPeriod = selectedDate == today
        ? currentTimePeriod()
        : state.selectedPeriod;
    final normalizedPlayerCount = state.playerCount.clamp(2, 6);
    final visibleSlots = state.bookingSlots
        .where(
          (slot) =>
              _isSlotInSelectedPeriod(slot, selectedPeriod) &&
              _selectedPlayerCountFitsSlot(
                playerCount: normalizedPlayerCount,
                slot: slot,
              ),
        )
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
    final selectedSlotFitsCapacity = _selectedPlayerCountFitsSlot(
      playerCount: normalizedPlayerCount,
      slot: state.selectedSlot,
    );
    final selectedDetailsMatchesSlot =
        state.selectedSlotDetails != null &&
        state.selectedSlotDetails!.slotId == state.selectedSlot?.slotId &&
        state.selectedSlotDetails!.isAvailable &&
        normalizedPlayerCount <= state.selectedSlotDetails!.maxPlayers;

    return state.copyWith(
      playerCount: normalizedPlayerCount,
      selectedPeriod: selectedPeriod,
      selectedSupportedNine: selectedSupportedNine,
      selectedDate: selectedDate,
      pickerInitialDate: selectedDate.isBefore(today) ? today : selectedDate,
      visibleSlots: visibleSlots,
      visibleUnavailableIndices: <int>{
        ...visibleSlots.indexed
            .where((entry) => !_isSlotBookable(entry.$2, state))
            .map((entry) => entry.$1),
      },
      visibleSelectedIndex:
          visibleSelectedIndex == -1 || !selectedSlotFitsCapacity
          ? null
          : visibleSelectedIndex,
      canContinue:
          state.selectedClubSlug.isNotEmpty &&
          state.selectedSlot != null &&
          _isSlotBookable(state.selectedSlot!, state) &&
          selectedSlotFitsCapacity &&
          selectedDetailsMatchesSlot,
    );
  }

  bool _selectedPlayerCountFitsSlot({
    required int playerCount,
    required BookingSlotModel? slot,
  }) {
    if (slot == null) {
      return false;
    }
    return playerCount <= slot.maxPlayers;
  }

  bool _isSlotInSelectedPeriod(BookingSlotModel slot, TimePeriod period) {
    final slotPeriod = _periodForSlot(slot);
    return slotPeriod == null || slotPeriod == period;
  }

  bool _isSlotBookable(
    BookingSlotModel slot,
    BookingSubmissionSlotDataLoaded state,
  ) {
    return slot.isAvailable && !_isSlotPast(slot, state.selectedDate);
  }

  bool _isSlotPast(BookingSlotModel slot, DateTime selectedDate) {
    final slotDateTime = _slotDateTime(slot, selectedDate);
    if (slotDateTime == null) {
      return false;
    }
    return slotDateTime.isBefore(DateTime.now());
  }

  DateTime? _slotDateTime(BookingSlotModel slot, DateTime selectedDate) {
    final startAt = slot.startAt;
    if (startAt != null) {
      return startAt.toLocal();
    }

    final parsedTime = _parseSlotTime(slot.time);
    if (parsedTime == null) {
      return null;
    }

    final date = DateUtil.dateOnly(selectedDate);
    return DateTime(
      date.year,
      date.month,
      date.day,
      parsedTime.$1,
      parsedTime.$2,
    );
  }

  (int, int)? _parseSlotTime(String rawTime) {
    final match = RegExp(
      r'(\d{1,2})[:.](\d{2})\s*(am|pm)?',
      caseSensitive: false,
    ).firstMatch(rawTime.trim());
    if (match == null) {
      return null;
    }

    var hour = int.tryParse(match.group(1) ?? '');
    final minute = int.tryParse(match.group(2) ?? '');
    if (hour == null || minute == null || minute > 59) {
      return null;
    }

    final meridiem = match.group(3)?.toLowerCase();
    if (meridiem == 'pm' && hour < 12) {
      hour += 12;
    } else if (meridiem == 'am' && hour == 12) {
      hour = 0;
    }

    if (hour > 23) {
      return null;
    }

    return (hour, minute);
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
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
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
