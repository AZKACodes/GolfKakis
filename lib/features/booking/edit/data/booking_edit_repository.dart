import 'package:golf_kakis/features/foundation/model/booking/booking_model.dart';

abstract class BookingEditRepository {
  Future<BookingEditSaveResult> onSaveBooking({required BookingModel booking});
}

class BookingEditSaveResult {
  const BookingEditSaveResult({required this.booking});

  final BookingModel booking;
}
