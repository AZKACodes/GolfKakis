import 'package:golf_kakis/features/foundation/model/booking/booking_model.dart';

abstract class BookingDetailRepository {
  Future<BookingDetailResult> onFetchBookingDetail({
    required BookingModel booking,
  });

  Future<BookingDeleteResult> onDeleteBooking({required BookingModel booking});
}

class BookingDetailResult {
  const BookingDetailResult({required this.booking});

  final BookingModel booking;
}

class BookingDeleteResult {
  const BookingDeleteResult();
}
