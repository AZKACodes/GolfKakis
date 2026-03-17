import 'package:golf_kakis/features/foundation/model/booking/booking_model.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_contract.dart';

abstract class ActivityBookingEditViewContract {
  ActivityBookingEditViewState get viewState;
  Stream<ActivityBookingEditNavEffect> get navEffects;
  void onUserIntent(ActivityBookingEditUserIntent intent);
}

class ActivityBookingEditViewState extends ViewState {
  const ActivityBookingEditViewState({
    required this.booking,
    required this.canSave,
    required this.isSaving,
    required this.isUsingFallback,
    this.errorMessage,
  }) : super();

  factory ActivityBookingEditViewState.initial(BookingModel booking) {
    return ActivityBookingEditViewState(
      booking: booking,
      canSave: _canSave(booking),
      isSaving: false,
      isUsingFallback: false,
    );
  }

  final BookingModel booking;
  final bool canSave;
  final bool isSaving;
  final bool isUsingFallback;
  final String? errorMessage;

  ActivityBookingEditViewState copyWith({
    BookingModel? booking,
    bool? canSave,
    bool? isSaving,
    bool? isUsingFallback,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    final nextBooking = booking ?? this.booking;
    return ActivityBookingEditViewState(
      booking: nextBooking,
      canSave: canSave ?? _canSave(nextBooking),
      isSaving: isSaving ?? this.isSaving,
      isUsingFallback: isUsingFallback ?? this.isUsingFallback,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  static bool _canSave(BookingModel booking) {
    return booking.playerDetails.every((player) => player.isComplete);
  }
}

sealed class ActivityBookingEditUserIntent extends UserIntent {
  const ActivityBookingEditUserIntent() : super();
}

class OnInit extends ActivityBookingEditUserIntent {
  const OnInit();
}

class OnBackClick extends ActivityBookingEditUserIntent {
  const OnBackClick();
}

class OnPlayerNameChanged extends ActivityBookingEditUserIntent {
  const OnPlayerNameChanged({required this.index, required this.value});

  final int index;
  final String value;
}

class OnPlayerPhoneChanged extends ActivityBookingEditUserIntent {
  const OnPlayerPhoneChanged({required this.index, required this.value});

  final int index;
  final String value;
}

class OnSaveClick extends ActivityBookingEditUserIntent {
  const OnSaveClick();
}

sealed class ActivityBookingEditNavEffect extends NavEffect {
  const ActivityBookingEditNavEffect() : super();
}

class NavigateBack extends ActivityBookingEditNavEffect {
  const NavigateBack({this.updatedBooking});

  final BookingModel? updatedBooking;
}
