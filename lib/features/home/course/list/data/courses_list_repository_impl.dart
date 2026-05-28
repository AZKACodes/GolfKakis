import 'package:golf_kakis/features/booking/api/booking_api_service.dart';
import 'package:golf_kakis/features/foundation/model/golf_club_model.dart';

import 'courses_list_repository.dart';

class CoursesListRepositoryImpl implements CoursesListRepository {
  CoursesListRepositoryImpl({BookingApiService? bookingApiService})
    : _bookingApiService = bookingApiService ?? BookingApiService();

  final BookingApiService _bookingApiService;

  @override
  Future<List<GolfClubModel>> onFetchCoursesList() async {
    try {
      final response = await _bookingApiService.onFetchGolfClubList();
      final clubs = _parseGolfClubList(response);
      return clubs.isEmpty ? _fallbackCourses : clubs;
    } catch (_) {
      return _fallbackCourses;
    }
  }

  List<GolfClubModel> _parseGolfClubList(dynamic rawResponse) {
    if (rawResponse is List) {
      return rawResponse
          .map(_asStringMap)
          .whereType<Map<String, dynamic>>()
          .map(_tryParseClub)
          .whereType<GolfClubModel>()
          .where((club) => club.slug.isNotEmpty)
          .toList();
    }

    final map = _asStringMap(rawResponse);
    if (map != null) {
      final dynamic nestedList =
          map['data'] ?? map['items'] ?? map['clubs'] ?? map['golfClubs'];
      return _parseGolfClubList(nestedList);
    }

    return const <GolfClubModel>[];
  }

  GolfClubModel? _tryParseClub(Map<String, dynamic> json) {
    try {
      return GolfClubModel.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic>? _asStringMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    return null;
  }
}

const List<GolfClubModel> _fallbackCourses = <GolfClubModel>[
  GolfClubModel(
    id: 'fallback-kinrara',
    slug: 'kinrara-golf-club',
    name: 'Kinrara Golf Club',
    address: 'Puchong, Selangor',
    noOfHoles: 18,
    latitude: 3.04703,
    longitude: 101.64744,
    isEnabled: true,
  ),
];
