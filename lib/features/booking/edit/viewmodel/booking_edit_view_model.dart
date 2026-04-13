import 'package:golf_kakis/features/booking/edit/data/booking_edit_repository.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_submission_player_model.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_view_model.dart';

import 'booking_edit_view_contract.dart';

class BookingEditViewModel
    extends
        MviViewModel<
          BookingEditUserIntent,
          BookingEditViewState,
          BookingEditNavEffect
        >
    implements BookingEditViewContract {
  BookingEditViewModel({
    required BookingEditRepository repository,
    required BookingEditViewState initialState,
  }) : _repository = repository,
       _initialState = initialState;

  final BookingEditRepository _repository;
  final BookingEditViewState _initialState;

  @override
  BookingEditViewState createInitialState() => _initialState;

  @override
  Future<void> handleIntent(BookingEditUserIntent intent) async {
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
          clearErrorMessage: true,
        ),
      );
      sendNavEffect(() => NavigateBack(updatedBooking: result.booking));
    } catch (_) {
      emitViewState(
        (state) => state.copyWith(
          isSaving: false,
          errorMessage: 'Unable to save booking changes right now.',
        ),
      );
    }
  }
}
