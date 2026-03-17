import 'dart:async';

import 'package:golf_kakis/features/booking/submission/slot/domain/booking_submission_slot_use_case.dart';
import 'package:golf_kakis/features/foundation/default_values.dart';
import 'package:golf_kakis/features/foundation/enums/booking/tee_time_slot.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_slot_model.dart';
import 'package:golf_kakis/features/foundation/model/booking/golf_club_model.dart';
import 'package:golf_kakis/features/foundation/model/data_status_model.dart';
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
              clearSelectedSlot: true,
              clearVisibleSelectedIndex: true,
              clearErrorMessage: true,
            ),
          );
        });
      case OnSelectDate():
        await onSelectDate(intent.date);
      case OnSelectSlot():
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
            golfClubName: current.selectedClubName,
            golfClubSlug: current.selectedClubSlug,
            selectedDate: current.selectedDate,
            teeTimeSlot: selectedSlot.time,
            pricePerPerson: selectedSlot.price,
            currency: selectedSlot.currency,
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
          if (selectedClubSlug.isNotEmpty) {
            onFetchAvailableSlots(
              clubSlug: selectedClubSlug,
              date: updatedState.selectedDate,
            );
          }
        case DataStatus.error:
          emitViewState((state) {
            return _derivePresentationState(
              getCurrentAsLoaded().copyWith(
                golfClubList: const <GolfClubModel>[],
                selectedClubSlug: emptyString,
                isLoading: false,
                errorMessage: result.apiMessage.isEmpty
                    ? 'Failed to fetch golf club list'
                    : result.apiMessage,
              ),
            );
          });
        default:
          break;
      }
    });
  }

  Future<void> onSelectDate(DateTime date) async {
    final current = getCurrentAsLoaded();
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
    emitViewState((state) {
      return _derivePresentationState(
        getCurrentAsLoaded().copyWith(
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
    _slotSubscription = _useCase
        .onFetchAvailableSlots(
          clubSlug: clubSlug,
          date: DateUtil.formatApiDate(date),
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
            case DataStatus.error:
              emitViewState((state) {
                return _derivePresentationState(
                  getCurrentAsLoaded().copyWith(
                    bookingSlots: const <BookingSlotModel>[],
                    isLoading: false,
                    errorMessage: result.apiMessage.isEmpty
                        ? 'Failed to fetch available slots'
                        : result.apiMessage,
                  ),
                );
              });
            default:
              break;
          }
        });
  }

  String _resolveSelectedClub(List<GolfClubModel> clubs) {
    if (clubs.isEmpty) {
      return emptyString;
    }

    if (clubs.any(
      (club) => club.slug == getCurrentAsLoaded().selectedClubSlug,
    )) {
      return getCurrentAsLoaded().selectedClubSlug;
    }

    return clubs.first.slug;
  }

  BookingSubmissionSlotDataLoaded _derivePresentationState(
    BookingSubmissionSlotDataLoaded state,
  ) {
    final today = DateUtil.dateOnly(DateTime.now());
    final visibleSlots = state.bookingSlots
        .where(
          (slot) =>
              TeeTimeSlot.fromLabel(slot.time)?.period == state.selectedPeriod,
        )
        .toList();
    final visibleSelectedIndex = state.selectedSlot == null
        ? null
        : visibleSlots.indexWhere(
            (slot) => slot.time == state.selectedSlot!.time,
          );

    return state.copyWith(
      selectedDate: DateUtil.dateOnly(state.selectedDate),
      pickerInitialDate: state.selectedDate.isBefore(today)
          ? today
          : DateUtil.dateOnly(state.selectedDate),
      visibleSlots: visibleSlots,
      visibleUnavailableIndices: const <int>{},
      visibleSelectedIndex: visibleSelectedIndex == -1
          ? null
          : visibleSelectedIndex,
      canContinue:
          state.selectedClubSlug.isNotEmpty && state.selectedSlot != null,
    );
  }

  @override
  void dispose() {
    _golfClubSubscription?.cancel();
    _slotSubscription?.cancel();
    super.dispose();
  }
}
