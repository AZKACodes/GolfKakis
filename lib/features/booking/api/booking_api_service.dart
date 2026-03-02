import '../../foundation/network/network.dart';

class BookingApiService {
  BookingApiService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<dynamic> onFetchGolfClubList() {
    return _apiClient.getJson('/general/golf-clubs');
  }

  Future<dynamic> onFetchAvailableSlots({
    required String clubSlug,
    required String date,
  }) {
    return _apiClient.postJson(
      '/booking/available-slots',
      body: <String, dynamic>{
        'clubSlug': clubSlug,
        'date': date
      },
    );
  }

  Future<dynamic> onCreateBookingSubmission() {
    return _apiClient.getJson('/booking/submit');
  }
}
