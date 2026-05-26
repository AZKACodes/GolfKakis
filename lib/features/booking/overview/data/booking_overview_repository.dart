import 'package:golf_kakis/features/foundation/model/booking_model.dart';

abstract class BookingOverviewRepository {
  Future<BookingOverviewTabData> onFetchUpcomingBookingList({
    required String accessToken,
  });

  Future<BookingOverviewTabData> onFetchPastBookingList({
    required String accessToken,
  });
}

class BookingOverviewTabData {
  const BookingOverviewTabData({required this.bookings});

  final List<BookingModel> bookings;
}
