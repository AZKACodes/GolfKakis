import '../data/booking_overview_repository.dart';

abstract class BookingOverviewUseCase {
  Future<BookingOverviewTabData> onFetchUpcomingBookingList({
    required String accessToken,
  });

  Future<BookingOverviewTabData> onFetchPastBookingList({
    required String accessToken,
  });
}
