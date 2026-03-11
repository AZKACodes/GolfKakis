import 'package:xxx_demo_app/features/foundation/model/booking/booking_model.dart';

abstract class ActivityBookingListRepository {
  Future<ActivityBookingTabData> onFetchUpcomingBookingList();

  Future<ActivityBookingTabData> onFetchPastBookingList();
}

class ActivityBookingTabData {
  const ActivityBookingTabData({
    required this.bookings,
    required this.isFallback,
  });

  final List<BookingModel> bookings;
  final bool isFallback;
}
