import 'package:golf_kakis/features/foundation/model/booking/booking_model.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_contract.dart';

abstract class BookingEditViewContract {
  BookingEditViewState get viewState;
  Stream<BookingEditNavEffect> get navEffects;
  void onUserIntent(BookingEditUserIntent intent);
}

class BookingEditViewState extends ViewState {
  const BookingEditViewState({
    required this.booking,
    required this.canSave,
    required this.isSaving,
    this.errorMessage,
  }) : super();

  factory BookingEditViewState.initial(BookingModel booking) {
    return BookingEditViewState(
      booking: booking,
      canSave: _canSave(booking),
      isSaving: false,
    );
  }

  final BookingModel booking;
  final bool canSave;
  final bool isSaving;
  final String? errorMessage;

  BookingEditViewState copyWith({
    BookingModel? booking,
    bool? canSave,
    bool? isSaving,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    final nextBooking = booking ?? this.booking;
    return BookingEditViewState(
      booking: nextBooking,
      canSave: canSave ?? _canSave(nextBooking),
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  static bool _canSave(BookingModel booking) {
    return booking.playerDetails.every((player) => player.isComplete);
  }
}

sealed class BookingEditUserIntent extends UserIntent {
  const BookingEditUserIntent() : super();
}

class OnInit extends BookingEditUserIntent {
  const OnInit();
}

class OnBackClick extends BookingEditUserIntent {
  const OnBackClick();
}

class OnPlayerNameChanged extends BookingEditUserIntent {
  const OnPlayerNameChanged({required this.index, required this.value});

  final int index;
  final String value;
}

class OnPlayerPhoneChanged extends BookingEditUserIntent {
  const OnPlayerPhoneChanged({required this.index, required this.value});

  final int index;
  final String value;
}

class OnSaveClick extends BookingEditUserIntent {
  const OnSaveClick();
}

sealed class BookingEditNavEffect extends NavEffect {
  const BookingEditNavEffect() : super();
}

class NavigateBack extends BookingEditNavEffect {
  const NavigateBack({this.updatedBooking});

  final BookingModel? updatedBooking;
}
