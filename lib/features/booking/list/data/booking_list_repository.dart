import 'package:golf_kakis/features/foundation/model/booking/booking_model.dart';

abstract class BookingListRepository {
  Future<BookingTabData> onFetchUpcomingBookingList();

  Future<BookingTabData> onFetchPastBookingList();
}

class BookingTabData {
  const BookingTabData({required this.bookings});

  final List<BookingModel> bookings;
}
