import 'package:golf_kakis/features/foundation/model/booking/booking_model.dart';

import '../../list/data/booking_list_repository_impl.dart';
import 'booking_overview_repository.dart';

class BookingOverviewRepositoryImpl implements BookingOverviewRepository {
  const BookingOverviewRepositoryImpl();

  @override
  Future<BookingModel?> onFetchUpcomingBooking({
    required String accessToken,
  }) async {
    final result = await BookingListRepositoryImpl(
      accessToken: accessToken,
    ).onFetchUpcomingBookingList();

    if (result.bookings.isEmpty) {
      return null;
    }

    return result.bookings.first;
  }
}
