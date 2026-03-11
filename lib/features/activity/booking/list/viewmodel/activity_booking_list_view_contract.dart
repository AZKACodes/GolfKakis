import 'package:xxx_demo_app/features/foundation/model/booking/booking_model.dart';

abstract class ActivityBookingListViewContract {
  ActivityBookingListViewState get viewState;
  Stream<ActivityBookingListNavEffect> get navEffects;
  void onUserIntent(ActivityBookingListUserIntent intent);
}

class ActivityBookingListViewState {
  const ActivityBookingListViewState({
    required this.upcomingBookings,
    required this.pastBookings,
  });

  static const initial = ActivityBookingListViewState(
    upcomingBookings: <BookingModel>[],
    pastBookings: <BookingModel>[],
  );

  final List<BookingModel> upcomingBookings;
  final List<BookingModel> pastBookings;
}

sealed class ActivityBookingListUserIntent {
  const ActivityBookingListUserIntent();
}

class OnViewBookingDetailClick extends ActivityBookingListUserIntent {
  const OnViewBookingDetailClick(this.booking);

  final BookingModel booking;
}

sealed class NavEffect {
  const NavEffect();
}

sealed class ActivityBookingListNavEffect extends NavEffect {
  const ActivityBookingListNavEffect();
}

class NavigateToActivityBookingDetail extends ActivityBookingListNavEffect {
  const NavigateToActivityBookingDetail(this.booking);

  final BookingModel booking;
}
