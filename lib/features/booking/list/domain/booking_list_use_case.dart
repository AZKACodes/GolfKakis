import 'package:golf_kakis/features/booking/list/data/booking_list_repository.dart';

abstract class BookingListUseCase {
  Future<BookingTabData> fetchUpcomingBookingList({
    required String accessToken,
  });

  Future<BookingTabData> fetchPastBookingList({required String accessToken});
}
