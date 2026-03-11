import 'package:xxx_demo_app/features/foundation/model/booking/booking_model.dart';

abstract class ActivityBookingDetailViewContract {
  ActivityBookingDetailViewState get viewState;
  Stream<ActivityBookingDetailNavEffect> get navEffects;
  void onUserIntent(ActivityBookingDetailUserIntent intent);
}

class ActivityBookingDetailViewState {
  const ActivityBookingDetailViewState({required this.booking});

  final BookingModel booking;
}

sealed class ActivityBookingDetailUserIntent {
  const ActivityBookingDetailUserIntent();
}

class OnBackClick extends ActivityBookingDetailUserIntent {
  const OnBackClick();
}

class OnDeleteClick extends ActivityBookingDetailUserIntent {
  const OnDeleteClick();
}

class OnEditDetailsClick extends ActivityBookingDetailUserIntent {
  const OnEditDetailsClick();
}

class OnBookingUpdated extends ActivityBookingDetailUserIntent {
  const OnBookingUpdated(this.booking);

  final BookingModel booking;
}

sealed class NavEffect {
  const NavEffect();
}

sealed class ActivityBookingDetailNavEffect extends NavEffect {
  const ActivityBookingDetailNavEffect();
}

class NavigateBack extends ActivityBookingDetailNavEffect {
  const NavigateBack();
}

class NavigateToActivityBookingEdit extends ActivityBookingDetailNavEffect {
  const NavigateToActivityBookingEdit(this.booking);

  final BookingModel booking;
}
