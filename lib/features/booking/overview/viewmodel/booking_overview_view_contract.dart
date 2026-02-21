abstract class BookingOverviewViewContract {
  BookingOverviewViewState get viewState;
  Stream<BookingOverviewNavEffect> get navEffects;
  void onUserIntent(BookingOverviewUserIntent intent);
}

class BookingOverviewViewState {
  const BookingOverviewViewState();

  static const initial = BookingOverviewViewState();
}

sealed class BookingOverviewUserIntent {
  const BookingOverviewUserIntent();
}

class OnBookingSubmissionClick extends BookingOverviewUserIntent {
  const OnBookingSubmissionClick();
}

sealed class NavEffect {
  const NavEffect();
}

sealed class BookingOverviewNavEffect extends NavEffect {
  const BookingOverviewNavEffect();
}

class NavigateToBookingSubmission extends BookingOverviewNavEffect {
  const NavigateToBookingSubmission();
}
