import 'package:golf_kakis/features/booking/api/booking_api_service.dart';
import 'package:golf_kakis/features/foundation/model/booking/golf_club_model.dart';

import 'courses_list_repository.dart';

class CoursesListRepositoryImpl implements CoursesListRepository {
  CoursesListRepositoryImpl({BookingApiService? bookingApiService})
    : _bookingApiService = bookingApiService ?? BookingApiService();

  final BookingApiService _bookingApiService;

  @override
  Future<List<GolfClubModel>> onFetchCoursesList() async {
    final response = await _bookingApiService.onFetchGolfClubList();
    return _parseGolfClubList(response);
  }

  List<GolfClubModel> _parseGolfClubList(dynamic rawResponse) {
    if (rawResponse is List) {
      return rawResponse
          .whereType<Map<String, dynamic>>()
          .map(GolfClubModel.fromJson)
          .where((club) => club.slug.isNotEmpty)
          .toList();
    }

    if (rawResponse is Map<String, dynamic>) {
      final dynamic nestedList =
          rawResponse['data'] ??
          rawResponse['items'] ??
          rawResponse['clubs'] ??
          rawResponse['golfClubs'];
      return _parseGolfClubList(nestedList);
    }

    return const <GolfClubModel>[];
  }
}
