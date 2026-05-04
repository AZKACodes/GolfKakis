import 'package:golf_kakis/features/foundation/model/booking/booking_model.dart';

abstract class BookingOverviewUseCase {
  Future<BookingModel?> onFetchUpcomingBooking({required String accessToken});
}
