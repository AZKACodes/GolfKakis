import 'package:golf_kakis/features/foundation/model/booking/booking_model.dart';
import 'package:golf_kakis/features/foundation/model/booking/golf_club_model.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_contract.dart';

abstract class BookingOverviewViewContract {
  BookingOverviewViewState get viewState;
  Stream<BookingOverviewNavEffect> get navEffects;
  void onUserIntent(BookingOverviewUserIntent intent);
}

// ------ View State ------

sealed class BookingOverviewViewState implements ViewState {
  const BookingOverviewViewState();
}

class BookingOverviewDataLoaded extends BookingOverviewViewState {
  const BookingOverviewDataLoaded({
    this.isLoggedIn = false,
    this.isUpcomingLoading = false,
    this.upcomingBooking,
  }) : super();

  static const initial = BookingOverviewDataLoaded();

  final bool isLoggedIn;
  final bool isUpcomingLoading;
  final BookingModel? upcomingBooking;

  BookingOverviewDataLoaded copyWith({
    bool? isLoggedIn,
    bool? isUpcomingLoading,
    BookingModel? upcomingBooking,
    bool clearUpcomingBooking = false,
  }) {
    return BookingOverviewDataLoaded(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isUpcomingLoading: isUpcomingLoading ?? this.isUpcomingLoading,
      upcomingBooking: clearUpcomingBooking
          ? null
          : (upcomingBooking ?? this.upcomingBooking),
    );
  }
}

// ------ UserIntent ------

sealed class BookingOverviewUserIntent implements UserIntent {
  const BookingOverviewUserIntent();
}

class OnBookingSubmissionClick extends BookingOverviewUserIntent {
  const OnBookingSubmissionClick();
}

class OnInit extends BookingOverviewUserIntent {
  const OnInit({required this.isLoggedIn, this.accessToken});

  final bool isLoggedIn;
  final String? accessToken;
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

// ------ NavEffect ------

sealed class BookingOverviewNavEffect implements NavEffect {
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
