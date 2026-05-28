import 'package:flutter/foundation.dart';
import '../../foundation/network/network.dart';
import 'package:golf_kakis/features/foundation/model/request/booking_hold_request_model.dart';
import 'package:golf_kakis/features/foundation/model/request/booking_submission_request_model.dart';

class BookingApiService {
  BookingApiService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<dynamic> onFetchGolfClubs({String? slug}) {
    return _apiClient.getJson(
      '/booking/golf-clubs',
      queryParameters: <String, dynamic>{
        if (slug != null && slug.trim().isNotEmpty) 'slug': slug,
      },
    );
  }

  Future<dynamic> onFetchGolfClubList() {
    return _apiClient.getJsonWithoutSharedHeaders(
      '/booking/golf-clubs',
      headers: const <String, String>{'Content-Type': 'application/json'},
    );
  }

  Future<dynamic> onFetchGolfClubDetail({required String slug}) {
    return onFetchGolfClubs(slug: slug);
  }

  Future<dynamic> onFetchCourseDetails({required String slug}) {
    return onFetchGolfClubDetail(slug: slug);
  }

  Future<dynamic> onFetchCourseExtraDetails({required String slug}) {
    return _apiClient.getJson('/booking/golf-clubs/$slug/extra-details');
  }

  Future<dynamic> onQuickBook({
    required String golfClubSlug,
    double? latitude,
    double? longitude,
    int maxResults = 3,
    int searchDays = 7,
  }) {
    return _apiClient.postJson(
      '/booking/quick-book',
      body: <String, dynamic>{
        'golfClubSlug': golfClubSlug,
        'latitude': latitude,
        'longitude': longitude,
        'maxResults': maxResults,
        'searchDays': searchDays,
      },
    );
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
    required int playerCount,
    String? selectedNine,
  }) {
    return _apiClient.postJsonWithoutSharedHeaders(
      '/booking/available-slots',
      body: <String, dynamic>{
        'golfClubSlug': clubSlug,
        'bookingDate': date,
        'playType': playType,
      },
      headers: const <String, String>{'Content-Type': 'application/json'},
    );
  }

  Future<dynamic> onFetchSlotDetails({
    required String slotId,
    required String clubSlug,
    required String date,
    required int playerCount,
    required String playType,
    String? selectedNine,
  }) {
    return _apiClient.postJsonWithoutSharedHeaders(
      '/booking/slots/$slotId/details',
      body: <String, dynamic>{'slotId': slotId},
      headers: const <String, String>{'Content-Type': 'application/json'},
    );
  }

  Future<dynamic> onCreateBookingSubmission({
    required BookingSubmissionRequestModel request,
  }) {
    final additionalHeaders = <String, String>{
      if (request.accessToken != null && request.accessToken!.isNotEmpty)
        'Authorization': 'Bearer ${request.accessToken!}',
    };
    final body = request.toJson();

    debugPrint('onSubmitBooking headers: ${additionalHeaders.keys.toList()}');
    debugPrint('onSubmitBooking body: $body');

    return _apiClient
        .postJson(
          '/booking/submit',
          body: body,
          headers: additionalHeaders.isEmpty ? null : additionalHeaders,
        )
        .then((response) {
          debugPrint('onSubmitBooking response: $response');
          return response;
        })
        .catchError((error) {
          debugPrint('onSubmitBooking error: $error');
          throw error;
        });
  }

  Future<dynamic> onCreateBookingHold({
    required BookingHoldRequestModel request,
  }) {
    final additionalHeaders = <String, String>{
      'Authorization': 'Bearer ${request.accessToken}',
      if (request.idempotencyKey != null && request.idempotencyKey!.isNotEmpty)
        'idempotency-key': request.idempotencyKey!,
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

  Future<dynamic> onExtendBookingHold({
    required String bookingRef,
    required String accessToken,
  }) {
    return _apiClient.postJson(
      '/booking/$bookingRef/extend-hold',
      headers: <String, String>{'Authorization': 'Bearer $accessToken'},
    );
  }

  Future<dynamic> onPreviewBooking({
    required String accessToken,
    required Map<String, dynamic> request,
  }) {
    return _apiClient.postJson(
      '/booking/preview',
      body: request,
      headers: <String, String>{'Authorization': 'Bearer $accessToken'},
    );
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
