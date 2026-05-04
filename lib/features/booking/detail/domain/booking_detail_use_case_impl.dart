import 'package:golf_kakis/features/booking/detail/data/booking_detail_repository.dart';
import 'package:golf_kakis/features/booking/detail/data/booking_detail_repository_impl.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_model.dart';

import 'booking_detail_use_case.dart';

class BookingDetailUseCaseImpl implements BookingDetailUseCase {
  const BookingDetailUseCaseImpl();

  @override
  Future<BookingDeleteResult> deleteBooking({
    required String accessToken,
    required BookingModel booking,
  }) {
    return BookingDetailRepositoryImpl(
      accessToken: accessToken,
    ).onDeleteBooking(booking: booking);
  }

  @override
  Future<BookingDetailResult> fetchBookingDetail({
    required String accessToken,
    required BookingModel booking,
  }) {
    return BookingDetailRepositoryImpl(
      accessToken: accessToken,
    ).onFetchBookingDetail(booking: booking);
  }
}
