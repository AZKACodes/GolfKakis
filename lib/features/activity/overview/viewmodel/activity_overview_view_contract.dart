import 'package:golf_kakis/features/foundation/model/booking/booking_model.dart';

abstract class ActivityOverviewViewContract {
  ActivityOverviewViewState get viewState;
  Stream<ActivityOverviewNavEffect> get navEffects;
  void onUserIntent(ActivityOverviewUserIntent intent);
}

class ActivityOverviewViewState {
  const ActivityOverviewViewState();

  static const initial = ActivityOverviewViewState();
}

sealed class ActivityOverviewUserIntent {
  const ActivityOverviewUserIntent();
}

class OnBookingListClick extends ActivityOverviewUserIntent {
  const OnBookingListClick();
}

class OnUpcomingBookingDetailClick extends ActivityOverviewUserIntent {
  const OnUpcomingBookingDetailClick();
}

class OnRecentRoundOneDetailClick extends ActivityOverviewUserIntent {
  const OnRecentRoundOneDetailClick();
}

class OnRecentRoundTwoDetailClick extends ActivityOverviewUserIntent {
  const OnRecentRoundTwoDetailClick();
}

sealed class NavEffect {
  const NavEffect();
}

sealed class ActivityOverviewNavEffect extends NavEffect {
  const ActivityOverviewNavEffect();
}

class NavigateToActivityBookingList extends ActivityOverviewNavEffect {
  const NavigateToActivityBookingList();
}

class NavigateToBookingDetails extends ActivityOverviewNavEffect {
  const NavigateToBookingDetails(this.booking);

  final BookingModel booking;
}
