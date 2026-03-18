import 'package:golf_kakis/features/booking/api/booking_api_service.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_submission_request_model.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_slot_model.dart';
import 'package:golf_kakis/features/foundation/model/booking/golf_club_model.dart';
import 'package:golf_kakis/features/foundation/network/network.dart';

import 'package:golf_kakis/features/booking/submission/slot/data/booking_submission_slot_repository.dart';

class BookingSubmissionSlotRepositoryImpl
    implements BookingSubmissionSlotRepository {
  static const bool _preferImmediateFallback = true;
  static final Map<String, Map<String, dynamic>> _fallbackBookingStore =
      <String, Map<String, dynamic>>{};

  BookingSubmissionSlotRepositoryImpl({
    ApiClient? apiClient,
    BookingApiService? apiService,
  }) : _apiService =
           apiService ?? BookingApiService(apiClient: apiClient ?? ApiClient());

  final BookingApiService _apiService;

  @override
  Future<List<GolfClubModel>> onFetchGolfClubList() async {
    final response = await _apiService.onFetchGolfClubList();
    return _parseGolfClubList(response);
  }

  @override
  Future<List<BookingSlotModel>> onFetchAvailableSlots({
    required String clubSlug,
    required String date,
  }) async {
    final response = await _apiService.onFetchAvailableSlots(
      clubSlug: clubSlug,
      date: date,
    );
    return _parseAvailableSlots(response);
  }

  @override
  Future<dynamic> onCreateBookingSubmission({
    required BookingSubmissionRequestModel request,
  }) async {
    if (_preferImmediateFallback) {
      return _buildFallbackSubmissionResponse(request);
    }

    try {
      final response = await _apiService.onCreateBookingSubmission(
        request: request,
      );
      return _normalizeSubmissionResponse(response: response, request: request);
    } catch (_) {
      return _buildFallbackSubmissionResponse(request);
    }
  }

  @override
  Future<dynamic> onFetchBookingDetails({required String bookingSlug}) async {
    if (_preferImmediateFallback) {
      return _buildFallbackBookingDetails(bookingSlug);
    }

    try {
      final response = await _apiService.onFetchBookingDetails(
        bookingSlug: bookingSlug,
      );

      if (response is Map<String, dynamic>) {
        final detailMap = response['data'] is Map<String, dynamic>
            ? response['data'] as Map<String, dynamic>
            : response['booking'] is Map<String, dynamic>
            ? response['booking'] as Map<String, dynamic>
            : response;
        _fallbackBookingStore[bookingSlug] = Map<String, dynamic>.from(
          detailMap,
        );
      }

      return response;
    } catch (_) {
      return _buildFallbackBookingDetails(bookingSlug);
    }
  }

  Map<String, dynamic> _normalizeSubmissionResponse({
    required dynamic response,
    required BookingSubmissionRequestModel request,
  }) {
    final fallbackResponse = _buildFallbackSubmissionResponse(request);
    if (response is! Map<String, dynamic>) {
      return fallbackResponse;
    }

    final bookingId =
        response['bookingId'] ??
        response['booking_id'] ??
        response['id'] ??
        fallbackResponse['bookingId'];
    final bookingSlug =
        response['bookingSlug'] ??
        response['booking_slug'] ??
        response['slug'] ??
        fallbackResponse['bookingSlug'];

    final normalized = <String, dynamic>{
      ...response,
      'bookingId': bookingId,
      'bookingSlug': bookingSlug,
    };

    _fallbackBookingStore[bookingSlug.toString()] = _buildFallbackBookingRecord(
      request: request,
      bookingId: bookingId.toString(),
      bookingSlug: bookingSlug.toString(),
    );

    return normalized;
  }

  Map<String, dynamic> _buildFallbackSubmissionResponse(
    BookingSubmissionRequestModel request,
  ) {
    final slugSeed = request.golfClubSlug
        .replaceAll(RegExp(r'[^a-zA-Z0-9-]'), '')
        .toLowerCase();
    final normalizedSlugSeed = slugSeed.isEmpty ? 'booking' : slugSeed;
    final sanitizedDate = request.bookingDate.replaceAll('-', '');
    final sanitizedTime = request.teeTimeSlot.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]'),
      '',
    );
    final suffix = DateTime.now().millisecondsSinceEpoch.toString().substring(
      7,
    );
    final bookingSlug =
        '$normalizedSlugSeed-$sanitizedDate-$sanitizedTime-$suffix';
    final bookingIdPrefix = normalizedSlugSeed
        .replaceAll('-', '')
        .toUpperCase();
    final bookingId =
        '${bookingIdPrefix.substring(0, bookingIdPrefix.length.clamp(0, 4))}-$suffix';

    _fallbackBookingStore[bookingSlug] = _buildFallbackBookingRecord(
      request: request,
      bookingId: bookingId,
      bookingSlug: bookingSlug,
    );

    return <String, dynamic>{
      'bookingId': bookingId,
      'bookingSlug': bookingSlug,
      'message': 'Fallback booking submission created for testing.',
    };
  }

  Map<String, dynamic> _buildFallbackBookingDetails(String bookingSlug) {
    return _fallbackBookingStore[bookingSlug] ??
        <String, dynamic>{
          'bookingId': bookingSlug.toUpperCase(),
          'bookingSlug': bookingSlug,
          'bookingDate': DateTime.now().toIso8601String().split('T').first,
          'golfClubName': 'Kinrara Golf Club',
          'golfClubSlug': 'kinrara-golf-club',
          'teeTimeSlot': '07:30 AM',
          'pricePerPerson': 145,
          'currency': 'MYR',
          'hostName': 'Test Host',
          'hostPhoneNumber': '+60 12-000 0000',
          'playerCount': 4,
          'caddieCount': 2,
          'golfCartCount': 2,
          'playerDetails': const <Map<String, dynamic>>[
            <String, dynamic>{
              'name': 'Test Host',
              'phoneNumber': '+60 12-000 0000',
            },
            <String, dynamic>{
              'name': 'Player Two',
              'phoneNumber': '+60 12-000 0001',
            },
            <String, dynamic>{
              'name': 'Player Three',
              'phoneNumber': '+60 12-000 0002',
            },
            <String, dynamic>{
              'name': 'Player Four',
              'phoneNumber': '+60 12-000 0003',
            },
          ],
        };
  }

  Map<String, dynamic> _buildFallbackBookingRecord({
    required BookingSubmissionRequestModel request,
    required String bookingId,
    required String bookingSlug,
  }) {
    return <String, dynamic>{
      'bookingId': bookingId,
      'bookingSlug': bookingSlug,
      'bookingDate': request.bookingDate,
      'golfClubName': request.golfClubName,
      'golfClubSlug': request.golfClubSlug,
      'teeTimeSlot': request.teeTimeSlot,
      'pricePerPerson': request.pricePerPerson,
      'currency': request.currency,
      'guestId': request.guestId,
      'hostName': request.hostName,
      'hostPhoneNumber': request.hostPhoneNumber,
      'playerCount': request.playerCount,
      'caddieCount': request.caddieCount,
      'golfCartCount': request.golfCartCount,
      'playerDetails': request.playerDetails
          .map((player) => player.toJson())
          .toList(),
      'status': 'Confirmed',
    };
  }

  List<GolfClubModel> _parseGolfClubList(dynamic response) {
    if (response is List) {
      return response
          .whereType<Map<String, dynamic>>()
          .map(GolfClubModel.fromJson)
          .where((club) => club.slug.isNotEmpty)
          .toList();
    }

    if (response is Map<String, dynamic>) {
      final dynamic nestedList =
          response['data'] ?? response['items'] ?? response['clubs'];
      return _parseGolfClubList(nestedList);
    }

    return const <GolfClubModel>[];
  }

  List<BookingSlotModel> _parseAvailableSlots(dynamic response) {
    if (response is List) {
      return response
          .map(
            (slot) => slot is Map<String, dynamic>
                ? BookingSlotModel.fromJson(slot)
                : BookingSlotModel(
                    time: slot.toString(),
                    price: 0,
                    noOfHoles: 18,
                  ),
          )
          .where((slot) => slot.time.isNotEmpty)
          .toList();
    }

    if (response is Map<String, dynamic>) {
      final dynamic nestedList =
          response['data'] ??
          response['items'] ??
          response['slots'] ??
          response['availableSlots'];
      return _parseAvailableSlots(nestedList);
    }

    if (response is String && response.isNotEmpty) {
      return <BookingSlotModel>[
        BookingSlotModel(time: response, price: 0, noOfHoles: 18),
      ];
    }

    return const <BookingSlotModel>[];
  }
}
