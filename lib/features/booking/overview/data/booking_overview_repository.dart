import 'package:golf_kakis/features/foundation/model/booking/booking_model.dart';

abstract class BookingOverviewRepository {
  Future<BookingModel?> onFetchUpcomingBooking({required String accessToken});
}
