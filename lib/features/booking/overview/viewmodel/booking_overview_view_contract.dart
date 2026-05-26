import 'package:golf_kakis/features/foundation/model/booking_model.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_contract.dart';

abstract class BookingOverviewViewContract {
  BookingOverviewViewState get viewState;
  Stream<BookingOverviewNavEffect> get navEffects;
  void onUserIntent(BookingOverviewUserIntent intent);
  Future<void> onRefresh(BookingOverviewTab tab);
}

class BookingOverviewViewState extends ViewState {
  const BookingOverviewViewState({
    required this.upcomingBookings,
    required this.pastBookings,
    required this.isUpcomingLoading,
    required this.isPastLoading,
    required this.hasLoadedUpcoming,
    required this.hasLoadedPast,
  }) : super();

  static const initial = BookingOverviewViewState(
    upcomingBookings: <BookingModel>[],
    pastBookings: <BookingModel>[],
    isUpcomingLoading: false,
    isPastLoading: false,
    hasLoadedUpcoming: false,
    hasLoadedPast: false,
  );

  final List<BookingModel> upcomingBookings;
  final List<BookingModel> pastBookings;
  final bool isUpcomingLoading;
  final bool isPastLoading;
  final bool hasLoadedUpcoming;
  final bool hasLoadedPast;

  BookingOverviewViewState copyWith({
    List<BookingModel>? upcomingBookings,
    List<BookingModel>? pastBookings,
    bool? isUpcomingLoading,
    bool? isPastLoading,
    bool? hasLoadedUpcoming,
    bool? hasLoadedPast,
  }) {
    return BookingOverviewViewState(
      upcomingBookings: upcomingBookings ?? this.upcomingBookings,
      pastBookings: pastBookings ?? this.pastBookings,
      isUpcomingLoading: isUpcomingLoading ?? this.isUpcomingLoading,
      isPastLoading: isPastLoading ?? this.isPastLoading,
      hasLoadedUpcoming: hasLoadedUpcoming ?? this.hasLoadedUpcoming,
      hasLoadedPast: hasLoadedPast ?? this.hasLoadedPast,
    );
  }
}

enum BookingOverviewTab { upcoming, past }

sealed class BookingOverviewUserIntent implements UserIntent {
  const BookingOverviewUserIntent();
}

class OnInitBookingOverview extends BookingOverviewUserIntent {
  const OnInitBookingOverview({
    required this.isLoggedIn,
    required this.accessToken,
  });

  final bool isLoggedIn;
  final String accessToken;
}

class OnTabChanged extends BookingOverviewUserIntent {
  const OnTabChanged(this.tab);

  final BookingOverviewTab tab;
}

class OnViewBookingDetailClick extends BookingOverviewUserIntent {
  const OnViewBookingDetailClick(this.booking);

  final BookingModel booking;
}

sealed class BookingOverviewNavEffect implements NavEffect {
  const BookingOverviewNavEffect();
}

class NavigateToBookingDetail extends BookingOverviewNavEffect {
  const NavigateToBookingDetail(this.booking);

  final BookingModel booking;
}

class ShowBookingOverviewError extends BookingOverviewNavEffect {
  const ShowBookingOverviewError(this.message);

  final String message;
}
