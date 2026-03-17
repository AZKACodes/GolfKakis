import 'package:golf_kakis/features/activity/booking/edit/data/activity_booking_edit_repository.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_submission_player_model.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_view_model.dart';

import 'activity_booking_edit_view_contract.dart';

class ActivityBookingEditViewModel
    extends
        MviViewModel<
          ActivityBookingEditUserIntent,
          ActivityBookingEditViewState,
          ActivityBookingEditNavEffect
        >
    implements ActivityBookingEditViewContract {
  ActivityBookingEditViewModel({
    required ActivityBookingEditRepository repository,
    required ActivityBookingEditViewState initialState,
  }) : _repository = repository,
       _initialState = initialState;

  final ActivityBookingEditRepository _repository;
  final ActivityBookingEditViewState _initialState;

  @override
  ActivityBookingEditViewState createInitialState() => _initialState;

  @override
  Future<void> handleIntent(ActivityBookingEditUserIntent intent) async {
    switch (intent) {
      case OnInit():
        emitViewState((state) => state.copyWith(clearErrorMessage: true));
      case OnBackClick():
        sendNavEffect(() => const NavigateBack());
      case OnPlayerNameChanged():
        _updatePlayer(index: intent.index, name: intent.value);
      case OnPlayerPhoneChanged():
        _updatePlayer(index: intent.index, phone: intent.value);
      case OnSaveClick():
        await _saveBooking();
    }
  }

  void _updatePlayer({required int index, String? name, String? phone}) {
    final players = List<BookingSubmissionPlayerModel>.from(
      currentState.booking.playerDetails,
    );
    if (index < 0 || index >= players.length) {
      return;
    }

    final current = players[index];
    players[index] = current.copyWith(
      name: name ?? current.name,
      phoneNumber: phone ?? current.phoneNumber,
    );

    emitViewState(
      (state) => state.copyWith(
        booking: state.booking.copyWith(playerDetails: players),
        isUsingFallback: false,
        clearErrorMessage: true,
      ),
    );
  }

  Future<void> _saveBooking() async {
    if (!currentState.canSave || currentState.isSaving) {
      return;
    }

    emitViewState(
      (state) => state.copyWith(isSaving: true, clearErrorMessage: true),
    );

    try {
      final result = await _repository.onSaveBooking(
        booking: currentState.booking,
      );
      emitViewState(
        (state) => state.copyWith(
          booking: result.booking,
          isSaving: false,
          isUsingFallback: result.isFallback,
          clearErrorMessage: true,
        ),
      );
      sendNavEffect(() => NavigateBack(updatedBooking: result.booking));
    } catch (_) {
      emitViewState(
        (state) => state.copyWith(
          isSaving: false,
          isUsingFallback: false,
          errorMessage: 'Unable to save booking changes right now.',
        ),
      );
    }
  }
}
