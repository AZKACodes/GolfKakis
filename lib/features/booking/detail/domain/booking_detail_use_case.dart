import 'package:golf_kakis/features/booking/detail/data/booking_detail_repository.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_model.dart';

abstract class BookingDetailUseCase {
  Future<BookingDetailResult> fetchBookingDetail({
    required String accessToken,
    required BookingModel booking,
  });

  Future<BookingDeleteResult> deleteBooking({
    required String accessToken,
    required BookingModel booking,
  });
}
