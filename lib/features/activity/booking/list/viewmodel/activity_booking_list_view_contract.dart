import 'package:golf_kakis/features/foundation/model/booking/booking_model.dart';

abstract class ActivityBookingListViewContract {
  ActivityBookingListViewState get viewState;
  Stream<ActivityBookingListNavEffect> get navEffects;
  void onUserIntent(ActivityBookingListUserIntent intent);
  Future<void> onRefresh(ActivityBookingListTab tab);
}

class ActivityBookingListViewState {
  const ActivityBookingListViewState({
    required this.upcomingBookings,
    required this.pastBookings,
    required this.isUpcomingLoading,
    required this.isPastLoading,
    required this.hasLoadedUpcoming,
    required this.hasLoadedPast,
    required this.isUsingUpcomingFallback,
    required this.isUsingPastFallback,
    this.upcomingErrorMessage,
    this.pastErrorMessage,
  });

  static const initial = ActivityBookingListViewState(
    upcomingBookings: <BookingModel>[],
    pastBookings: <BookingModel>[],
    isUpcomingLoading: false,
    isPastLoading: false,
    hasLoadedUpcoming: false,
    hasLoadedPast: false,
    isUsingUpcomingFallback: false,
    isUsingPastFallback: false,
  );

  final List<BookingModel> upcomingBookings;
  final List<BookingModel> pastBookings;
  final bool isUpcomingLoading;
  final bool isPastLoading;
  final bool hasLoadedUpcoming;
  final bool hasLoadedPast;
  final bool isUsingUpcomingFallback;
  final bool isUsingPastFallback;
  final String? upcomingErrorMessage;
  final String? pastErrorMessage;

  ActivityBookingListViewState copyWith({
    List<BookingModel>? upcomingBookings,
    List<BookingModel>? pastBookings,
    bool? isUpcomingLoading,
    bool? isPastLoading,
    bool? hasLoadedUpcoming,
    bool? hasLoadedPast,
    bool? isUsingUpcomingFallback,
    bool? isUsingPastFallback,
    String? upcomingErrorMessage,
    String? pastErrorMessage,
    bool clearUpcomingErrorMessage = false,
    bool clearPastErrorMessage = false,
  }) {
    return ActivityBookingListViewState(
      upcomingBookings: upcomingBookings ?? this.upcomingBookings,
      pastBookings: pastBookings ?? this.pastBookings,
      isUpcomingLoading: isUpcomingLoading ?? this.isUpcomingLoading,
      isPastLoading: isPastLoading ?? this.isPastLoading,
      hasLoadedUpcoming: hasLoadedUpcoming ?? this.hasLoadedUpcoming,
      hasLoadedPast: hasLoadedPast ?? this.hasLoadedPast,
      isUsingUpcomingFallback:
          isUsingUpcomingFallback ?? this.isUsingUpcomingFallback,
      isUsingPastFallback: isUsingPastFallback ?? this.isUsingPastFallback,
      upcomingErrorMessage: clearUpcomingErrorMessage
          ? null
          : upcomingErrorMessage ?? this.upcomingErrorMessage,
      pastErrorMessage: clearPastErrorMessage
          ? null
          : pastErrorMessage ?? this.pastErrorMessage,
    );
  }
}

enum ActivityBookingListTab { upcoming, past }

sealed class ActivityBookingListUserIntent {
  const ActivityBookingListUserIntent();
}

class OnInit extends ActivityBookingListUserIntent {
  const OnInit();
}

class OnRetryClick extends ActivityBookingListUserIntent {
  const OnRetryClick(this.tab);

  final ActivityBookingListTab tab;
}

class OnTabChanged extends ActivityBookingListUserIntent {
  const OnTabChanged(this.tab);

  final ActivityBookingListTab tab;
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
