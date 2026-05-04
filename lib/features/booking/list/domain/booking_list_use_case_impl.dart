import 'package:golf_kakis/features/booking/list/data/booking_list_repository.dart';
import 'package:golf_kakis/features/booking/list/data/booking_list_repository_impl.dart';

import 'booking_list_use_case.dart';

class BookingListUseCaseImpl implements BookingListUseCase {
  const BookingListUseCaseImpl();

  @override
  Future<BookingTabData> fetchUpcomingBookingList({
    required String accessToken,
  }) {
    return BookingListRepositoryImpl(
      accessToken: accessToken,
    ).onFetchUpcomingBookingList();
  }

  @override
  Future<BookingTabData> fetchPastBookingList({required String accessToken}) {
    return BookingListRepositoryImpl(
      accessToken: accessToken,
    ).onFetchPastBookingList();
  }
}
