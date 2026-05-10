import '../data/booking_overview_repository.dart';
import '../data/booking_overview_repository_impl.dart';
import 'booking_overview_use_case.dart';

class BookingOverviewUseCaseImpl implements BookingOverviewUseCase {
  BookingOverviewUseCaseImpl._(this._repository);

  factory BookingOverviewUseCaseImpl.create() {
    return BookingOverviewUseCaseImpl._(BookingOverviewRepositoryImpl());
  }

  final BookingOverviewRepository _repository;

  @override
  Future<BookingOverviewTabData> onFetchUpcomingBookingList({
    required String accessToken,
  }) {
    return _repository.onFetchUpcomingBookingList(accessToken: accessToken);
  }

  @override
  Future<BookingOverviewTabData> onFetchPastBookingList({
    required String accessToken,
  }) {
    return _repository.onFetchPastBookingList(accessToken: accessToken);
  }
}
