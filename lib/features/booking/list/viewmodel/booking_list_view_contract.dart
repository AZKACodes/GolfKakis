import 'package:golf_kakis/features/foundation/model/booking/booking_model.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_contract.dart';

abstract class BookingListViewContract {
  BookingListViewState get viewState;
  Stream<BookingListNavEffect> get navEffects;
  void onUserIntent(BookingListUserIntent intent);
  Future<void> onRefresh(BookingListTab tab);
}

class BookingListViewState extends ViewState {
  const BookingListViewState({
    required this.upcomingBookings,
    required this.pastBookings,
    required this.isUpcomingLoading,
    required this.isPastLoading,
    required this.hasLoadedUpcoming,
    required this.hasLoadedPast,
  }) : super();

  static const initial = BookingListViewState(
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

  BookingListViewState copyWith({
    List<BookingModel>? upcomingBookings,
    List<BookingModel>? pastBookings,
    bool? isUpcomingLoading,
    bool? isPastLoading,
    bool? hasLoadedUpcoming,
    bool? hasLoadedPast,
  }) {
    return BookingListViewState(
      upcomingBookings: upcomingBookings ?? this.upcomingBookings,
      pastBookings: pastBookings ?? this.pastBookings,
      isUpcomingLoading: isUpcomingLoading ?? this.isUpcomingLoading,
      isPastLoading: isPastLoading ?? this.isPastLoading,
      hasLoadedUpcoming: hasLoadedUpcoming ?? this.hasLoadedUpcoming,
      hasLoadedPast: hasLoadedPast ?? this.hasLoadedPast,
    );
  }
}

enum BookingListTab { upcoming, past }

sealed class BookingListUserIntent extends UserIntent {
  const BookingListUserIntent() : super();
}

class OnInit extends BookingListUserIntent {
  const OnInit();
}

class OnRetryClick extends BookingListUserIntent {
  const OnRetryClick(this.tab);

  final BookingListTab tab;
}

class OnTabChanged extends BookingListUserIntent {
  const OnTabChanged(this.tab);

  final BookingListTab tab;
}

class OnViewBookingDetailClick extends BookingListUserIntent {
  const OnViewBookingDetailClick(this.booking);

  final BookingModel booking;
}

sealed class BookingListNavEffect extends NavEffect {
  const BookingListNavEffect() : super();
}

class NavigateToBookingDetails extends BookingListNavEffect {
  const NavigateToBookingDetails(this.booking);

  final BookingModel booking;
}

class ShowBookingListError extends BookingListNavEffect {
  const ShowBookingListError(this.message);

  final String message;
}
