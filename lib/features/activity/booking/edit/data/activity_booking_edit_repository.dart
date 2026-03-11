import 'package:xxx_demo_app/features/foundation/model/booking/booking_model.dart';

abstract class ActivityBookingEditRepository {
  Future<ActivityBookingEditSaveResult> onSaveBooking({
    required BookingModel booking,
  });
}

class ActivityBookingEditSaveResult {
  const ActivityBookingEditSaveResult({
    required this.booking,
    required this.isFallback,
  });

  final BookingModel booking;
  final bool isFallback;
}
