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

sealed class NavEffect {
  const NavEffect();
}

sealed class ActivityOverviewNavEffect extends NavEffect {
  const ActivityOverviewNavEffect();
}

class NavigateToActivityBookingList extends ActivityOverviewNavEffect {
  const NavigateToActivityBookingList();
}
