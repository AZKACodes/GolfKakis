import 'package:flutter/foundation.dart';
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

  Future<dynamic> onFetchBookingUpcomingList({required String accessToken}) {
    return _apiClient.getJson(
      '/booking/list/upcoming',
      queryParameters: const <String, dynamic>{'page': 1, 'pageSize': 20},
      headers: <String, String>{'Authorization': 'Bearer $accessToken'},
    );
  }

  Future<dynamic> onFetchBookingPastList({required String accessToken}) {
    return _apiClient.getJson(
      '/booking/list/past',
      queryParameters: const <String, dynamic>{'page': 1, 'pageSize': 20},
      headers: <String, String>{'Authorization': 'Bearer $accessToken'},
    );
  }

  Future<dynamic> onFetchAvailableSlots({
    required String clubSlug,
    required String date,
    required String playType,
    String? selectedNine,
  }) {
    return _apiClient.postJson(
      '/booking/available-slots',
      body: <String, dynamic>{
        'golfClubSlug': clubSlug,
        'bookingDate': date,
        'playType': playType,
        if (selectedNine != null && selectedNine.trim().isNotEmpty)
          'selectedNine': selectedNine,
      },
    );
  }

  Future<dynamic> onCreateBookingSubmission({
    required BookingSubmissionRequestModel request,
  }) {
    final additionalHeaders = <String, String>{
      if (request.accessToken != null && request.accessToken!.isNotEmpty)
        'Authorization': 'Bearer ${request.accessToken!}',
    };
    return _apiClient.postJson(
      '/booking/submit',
      body: request.toJson(),
      headers: additionalHeaders.isEmpty ? null : additionalHeaders,
    );
  }

  Future<dynamic> onCreateBookingHold({
    required BookingHoldRequestModel request,
  }) {
    final additionalHeaders = <String, String>{
      'Authorization': 'Bearer ${request.accessToken}',
      if (request.idempotencyKey != null && request.idempotencyKey!.isNotEmpty)
        'Idempotency-Key': request.idempotencyKey!,
    };
    final resolvedHeaders = _apiClient.resolveHeaders(additionalHeaders);
    final body = request.toJson();

    debugPrint('onCreateBookingHold headers: $resolvedHeaders');
    debugPrint('onCreateBookingHold body: $body');

    return _apiClient
        .postJson('/booking/hold', body: body, headers: additionalHeaders)
        .then((response) {
          debugPrint('onCreateBookingHold response: $response');
          return response;
        })
        .catchError((error) {
          debugPrint('onCreateBookingHold error: $error');
          throw error;
        });
  }

  Future<dynamic> onFetchBookingDetails({
    required String bookingRef,
    String? accessToken,
  }) {
    final headers = <String, String>{
      if (accessToken != null && accessToken.isNotEmpty)
        'Authorization': 'Bearer $accessToken',
    };
    return _apiClient.getJson(
      '/booking/$bookingRef',
      headers: headers.isEmpty ? null : headers,
    );
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
