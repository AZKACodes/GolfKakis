import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:xxx_demo_app/features/booking/submission/slot/domain/booking_submission_slot_use_case.dart';
import 'package:xxx_demo_app/features/foundation/default_values.dart';
import 'package:xxx_demo_app/features/foundation/model/booking/booking_slot_model.dart';
import 'package:xxx_demo_app/features/foundation/model/data_status_model.dart';

import 'booking_submission_slot_view_contract.dart';

class BookingSubmissionSlotViewModel extends ChangeNotifier
    implements BookingSubmissionSlotViewContract {
  BookingSubmissionSlotViewModel(this._useCase);

  final BookingSubmissionSlotUseCase _useCase;
  final StreamController<BookingSubmissionSlotNavEffect> _navEffectsController =
      StreamController<BookingSubmissionSlotNavEffect>.broadcast();

  StreamSubscription<DataStatusModel<List<String>>>? _golfClubSubscription;
  StreamSubscription<DataStatusModel<List<BookingSlotModel>>>?
  _slotSubscription;

  BookingSubmissionSlotViewState _viewState =
      BookingSubmissionSlotViewState.initial;

  @override
  BookingSubmissionSlotViewState get viewState => _viewState;

  @override
  Stream<BookingSubmissionSlotNavEffect> get navEffects =>
      _navEffectsController.stream;

  @override
  void onUserIntent(BookingSubmissionSlotUserIntent intent) {
    switch (intent) {
      case OnFetchGolfClubList():
        _fetchGolfClubList();
      case OnFetchAvailableSlots():
        _fetchAvailableSlots(clubSlug: intent.clubSlug, date: intent.date);
      case OnSelectGolfClub():
        _updateState(
          _currentState.copyWith(
            selectedClubSlug: intent.clubSlug,
            clearErrorMessage: true,
          ),
        );
      case OnSelectDate():
        _updateState(
          _currentState.copyWith(
            selectedDate: intent.date,
            clearErrorMessage: true,
          ),
        );
    }
  }

  Future<void> _fetchGolfClubList() async {
    _updateState(
      _currentState.copyWith(isLoading: true, clearErrorMessage: true),
    );

    await _golfClubSubscription?.cancel();
    _golfClubSubscription = _useCase.onFetchGolfClubList().listen((result) {
      switch (result.status) {
        case DataStatus.success:
          _updateState(
            _currentState.copyWith(
              golfClubList: result.data,
              selectedClubSlug: _resolveSelectedClub(result.data),
              isLoading: false,
              clearErrorMessage: true,
            ),
          );
        case DataStatus.error:
          _updateState(
            _currentState.copyWith(
              golfClubList: const <String>[],
              selectedClubSlug: emptyString,
              isLoading: false,
              errorMessage: result.apiMessage.isEmpty
                  ? 'Failed to fetch golf club list'
                  : result.apiMessage,
            ),
          );
        default:
          break;
      }
    });
  }

  Future<void> _fetchAvailableSlots({
    required String clubSlug,
    required String date,
  }) async {
    _updateState(
      _currentState.copyWith(
        selectedClubSlug: clubSlug,
        selectedDate: date,
        isLoading: true,
        clearErrorMessage: true,
      ),
    );

    await _slotSubscription?.cancel();
    _slotSubscription = _useCase
        .onFetchAvailableSlots(clubSlug: clubSlug, date: date)
        .listen((result) {
          switch (result.status) {
            case DataStatus.success:
              _updateState(
                _currentState.copyWith(
                  bookingSlots: result.data,
                  isLoading: false,
                  clearErrorMessage: true,
                ),
              );
            case DataStatus.error:
              _updateState(
                _currentState.copyWith(
                  bookingSlots: const <BookingSlotModel>[],
                  isLoading: false,
                  errorMessage: result.apiMessage.isEmpty
                      ? 'Failed to fetch available slots'
                      : result.apiMessage,
                ),
              );
            default:
              break;
          }
        });
  }

  BookingSubmissionSlotDataLoaded get _currentState {
    final state = _viewState;
    if (state is BookingSubmissionSlotDataLoaded) {
      return state;
    }

    return const BookingSubmissionSlotDataLoaded();
  }

  String _resolveSelectedClub(List<String> clubs) {
    if (clubs.isEmpty) {
      return emptyString;
    }

    if (clubs.contains(_currentState.selectedClubSlug)) {
      return _currentState.selectedClubSlug;
    }

    return clubs.first;
  }

  void _updateState(BookingSubmissionSlotViewState state) {
    _viewState = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _golfClubSubscription?.cancel();
    _slotSubscription?.cancel();
    _navEffectsController.close();
    super.dispose();
  }
}
