import 'package:golf_kakis/features/foundation/model/booking/booking_model.dart';

import '../data/booking_overview_repository.dart';
import '../data/booking_overview_repository_impl.dart';
import 'booking_overview_use_case.dart';

class BookingOverviewUseCaseImpl implements BookingOverviewUseCase {
  BookingOverviewUseCaseImpl._(this._repository);

  factory BookingOverviewUseCaseImpl.create() {
    return BookingOverviewUseCaseImpl._(const BookingOverviewRepositoryImpl());
  }

  final BookingOverviewRepository _repository;

  @override
  Future<BookingModel?> onFetchUpcomingBooking({required String accessToken}) {
    return _repository.onFetchUpcomingBooking(accessToken: accessToken);
  }
}
