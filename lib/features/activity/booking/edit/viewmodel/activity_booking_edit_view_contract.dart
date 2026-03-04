import 'package:xxx_demo_app/features/foundation/model/booking/booking_model.dart';

abstract class ActivityBookingEditViewContract {
  ActivityBookingEditViewState get viewState;
  Stream<ActivityBookingEditNavEffect> get navEffects;
  void onUserIntent(ActivityBookingEditUserIntent intent);
}

class ActivityBookingEditViewState {
  const ActivityBookingEditViewState({required this.booking});

  final BookingModel booking;
}

sealed class ActivityBookingEditUserIntent {
  const ActivityBookingEditUserIntent();
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

sealed class NavEffect {
  const NavEffect();
}

sealed class ActivityBookingEditNavEffect extends NavEffect {
  const ActivityBookingEditNavEffect();
}

class NavigateBack extends ActivityBookingEditNavEffect {
  const NavigateBack({this.updatedBooking});

  final BookingModel? updatedBooking;
}
