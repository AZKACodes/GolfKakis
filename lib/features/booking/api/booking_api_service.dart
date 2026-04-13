import 'package:flutter/foundation.dart';
import '../../foundation/network/network.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_hold_request_model.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_submission_request_model.dart';

class BookingApiService {
  BookingApiService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<dynamic> onFetchGolfClubList() {
    return Future<dynamic>.value(const <Map<String, dynamic>>[
      <String, dynamic>{
        'id': '40000000-0000-0000-0000-000000000001',
        'slug': 'kinrara-golf-club',
        'name': 'Main Golf Course',
        'address': 'Bandar Kinrara, Puchong, Selangor',
        'noOfHoles': 18,
        'supportsNineHoles': true,
        'supportedNines': <String>['damai', 'sutera'],
        'buggyPolicy': 'required',
        'paymentMethods': <String>['pay_counter'],
        'updatedAt': '2026-03-18T12:26:21.693743+00:00',
      },
    ]);
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
    return Future<dynamic>.value(<String, dynamic>{
      'club': <String, dynamic>{'slug': clubSlug, 'name': 'Main Golf Course'},
      'bookingDate': date,
      'playType': playType,
      'selectedNine': selectedNine,
      'slots': const <Map<String, dynamic>>[
        <String, dynamic>{
          'slotId': 'b91e2ed9-7a13-48a3-ae0a-25b4bcdfd457',
          'teeTimeSlot': '07:30 am',
          'startAt': '2026-04-01T23:30:00+00:00',
          'endAt': '2026-04-02T00:00:00+00:00',
          'currency': 'MYR',
          'fromPrice': 145,
          'pricingLabel': 'From MYR 145 nett',
          'remainingPlayerCapacity': 4,
          'buggyPolicy': 'required',
          'isAvailable': true,
        },
        <String, dynamic>{
          'slotId': 'ec4bf5ac-ebfb-42ed-89f3-0910a50fb05f',
          'teeTimeSlot': '12:30 pm',
          'startAt': '2026-04-02T04:30:00+00:00',
          'endAt': '2026-04-02T05:00:00+00:00',
          'currency': 'MYR',
          'fromPrice': 155,
          'pricingLabel': 'From MYR 155 nett',
          'remainingPlayerCapacity': 4,
          'buggyPolicy': 'required',
          'isAvailable': true,
        },
        <String, dynamic>{
          'slotId': '4d08524d-b264-44d8-b7ad-1f002acf78e5',
          'teeTimeSlot': '04:30 pm',
          'startAt': '2026-04-02T08:30:00+00:00',
          'endAt': '2026-04-02T09:00:00+00:00',
          'currency': 'MYR',
          'fromPrice': 135,
          'pricingLabel': 'From MYR 135 nett',
          'remainingPlayerCapacity': 4,
          'buggyPolicy': 'required',
          'isAvailable': true,
        },
      ],
    });
  }

  Future<dynamic> onCreateBookingSubmission({
    required BookingSubmissionRequestModel request,
  }) {
    return _apiClient.postJson('/booking/submit', body: request.toJson());
  }

  Future<dynamic> onCreateBookingHold({
    required BookingHoldRequestModel request,
  }) {
    final additionalHeaders =
        request.idempotencyKey == null || request.idempotencyKey!.isEmpty
        ? const <String, String>{}
        : <String, String>{'Idempotency-Key': request.idempotencyKey!};
    final resolvedHeaders = _apiClient.resolveHeaders(
      additionalHeaders.isEmpty ? null : additionalHeaders,
    );
    final body = request.toJson();

    debugPrint('onCreateBookingHold headers: $resolvedHeaders');
    debugPrint('onCreateBookingHold body: $body');

    return _apiClient
        .postJson(
          '/booking/hold',
          body: body,
          headers: additionalHeaders.isEmpty ? null : additionalHeaders,
        )
        .then((response) {
          debugPrint('onCreateBookingHold response: $response');
          return response;
        })
        .catchError((error) {
          debugPrint('onCreateBookingHold error: $error');
          throw error;
        });
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
