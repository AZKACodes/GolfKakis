import '../../foundation/network/network.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_hold_request_model.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_submission_request_model.dart';

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
      body: <String, dynamic>{'golfClubSlug': clubSlug, 'bookingDate': date},
    );
  }

  Future<dynamic> onCreateBookingSubmission({
    required BookingSubmissionRequestModel request,
  }) {
    return _apiClient.postJson('/booking/submit', body: request.toJson());
  }

  Future<dynamic> onCreateBookingHold({
    required BookingHoldRequestModel request,
  }) {
    return _apiClient.postJson('/booking/hold', body: request.toJson());
  }

  Future<dynamic> onFetchBookingDetails({required String bookingSlug}) {
    return _apiClient.getJson('/booking/$bookingSlug');
  }

  Future<dynamic> onUpdateBookingDetails({
    required String bookingId,
    required Map<String, dynamic> request,
  }) {
    return _apiClient.putJson('/booking/$bookingId', body: request);
  }

  Future<dynamic> onDeleteBookingDetails({required String bookingId}) {
    return _apiClient.deleteJson('/booking/$bookingId');
  }
}
