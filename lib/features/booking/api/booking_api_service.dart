import '../../foundation/network/network.dart';
import 'package:xxx_demo_app/features/foundation/model/booking/booking_submission_request_model.dart';

class BookingApiService {
  BookingApiService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<dynamic> onFetchGolfClubList() {
    return _apiClient.getJson('/booking/golf-clubs');
  }

  Future<dynamic> onFetchBookingUpcomingList() {
    return _apiClient.getJson('/booking/list/upcoming');
  }

  Future<dynamic> onFetchBookingPastList() {
    return _apiClient.getJson('/booking/list/past');
  }

  Future<dynamic> onFetchAvailableSlots({
    required String clubSlug,
    required String date,
  }) {
    return _apiClient.postJson(
      '/booking/available-slots',
      body: <String, dynamic>{'clubSlug': clubSlug, 'date': date},
    );
  }

  Future<dynamic> onCreateBookingSubmission({
    required BookingSubmissionRequestModel request,
  }) {
    return _apiClient.postJson('/booking/submit', body: request.toJson());
  }

  Future<dynamic> onFetchBookingDetails({required String bookingSlug}) {
    return _apiClient.getJson('/booking/$bookingSlug');
  }
}
