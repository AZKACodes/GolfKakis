abstract class ActivityBookingListViewContract {
  ActivityBookingListViewState get viewState;
  void onUserIntent(ActivityBookingListUserIntent intent);
}

class ActivityBookingListViewState {
  const ActivityBookingListViewState();

  static const initial = ActivityBookingListViewState();
}

sealed class ActivityBookingListUserIntent {
  const ActivityBookingListUserIntent();
}
