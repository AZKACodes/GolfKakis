import 'package:golf_kakis/features/foundation/model/booking/booking_model.dart';
import 'package:golf_kakis/features/foundation/model/booking/golf_club_model.dart';

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

class OnPopularClubClick extends BookingOverviewUserIntent {
  const OnPopularClubClick(this.club);

  final GolfClubModel club;
}

class OnBookingListClick extends BookingOverviewUserIntent {
  const OnBookingListClick();
}

class OnUpcomingBookingDetailClick extends BookingOverviewUserIntent {
  const OnUpcomingBookingDetailClick();
}

class OnRecentRoundOneDetailClick extends BookingOverviewUserIntent {
  const OnRecentRoundOneDetailClick();
}

class OnRecentRoundTwoDetailClick extends BookingOverviewUserIntent {
  const OnRecentRoundTwoDetailClick();
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

class NavigateToGolfClubDetail extends BookingOverviewNavEffect {
  const NavigateToGolfClubDetail(this.club);

  final GolfClubModel club;
}

class NavigateToBookingList extends BookingOverviewNavEffect {
  const NavigateToBookingList();
}

class NavigateToBookingDetail extends BookingOverviewNavEffect {
  const NavigateToBookingDetail(this.booking);

  final BookingModel booking;
}
