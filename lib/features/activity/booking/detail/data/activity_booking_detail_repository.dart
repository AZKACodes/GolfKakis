import 'package:xxx_demo_app/features/foundation/model/booking/booking_model.dart';

abstract class ActivityBookingDetailRepository {
  Future<ActivityBookingDetailResult> onFetchBookingDetail({
    required BookingModel booking,
  });

  Future<ActivityBookingDeleteResult> onDeleteBooking({
    required BookingModel booking,
  });
}

class ActivityBookingDetailResult {
  const ActivityBookingDetailResult({
    required this.booking,
    required this.isFallback,
  });

  final BookingModel booking;
  final bool isFallback;
}

class ActivityBookingDeleteResult {
  const ActivityBookingDeleteResult({required this.isFallback});

  final bool isFallback;
}
