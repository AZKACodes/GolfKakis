import 'dart:async';

import 'package:golf_kakis/features/booking/submission/slot/domain/booking_submission_slot_use_case.dart';
import 'package:golf_kakis/features/foundation/default_values.dart';
import 'package:golf_kakis/features/foundation/enums/booking/time_period.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_slot_model.dart';
import 'package:golf_kakis/features/foundation/model/booking/golf_club_model.dart';
import 'package:golf_kakis/features/foundation/model/data_status_model.dart';
import 'package:golf_kakis/features/foundation/model/snackbar_message_model.dart';
import 'package:golf_kakis/features/foundation/util/date_util.dart';
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
              clearErrorMessage: true,
            ),
          );
        });
      case OnSelectPeriod():
        emitViewState((state) {
          return _derivePresentationState(
            getCurrentAsLoaded().copyWith(
              selectedPeriod: intent.period,
              clearSelectedSlot: true,
              clearVisibleSelectedIndex: true,
              clearErrorMessage: true,
            ),
          );
        });
      case OnBackClick():
        sendNavEffect(() => const NavigateBack());
      case OnContinueClick():
        final current = getCurrentAsLoaded();
        final selectedSlot = current.selectedSlot;
        if (!current.canContinue || selectedSlot == null) {
          return;
        }

        sendNavEffect(
          () => NavigateToBookingSubmissionDetail(
            slotId: selectedSlot.slotId,
            playType: current.playTypeValue,
            golfClubName: current.selectedClubName,
            golfClubSlug: current.selectedClubSlug,
            selectedDate: current.selectedDate,
            teeTimeSlot: selectedSlot.time,
            pricePerPerson: selectedSlot.price,
            currency: selectedSlot.currency,
            playerCount: current.playerCount,
            selectedNine: null,
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
          selectedSlotFitsCapacity,
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

  @override
  void dispose() {
    _golfClubSubscription?.cancel();
    _slotSubscription?.cancel();
    super.dispose();
  }
}
