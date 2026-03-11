import 'package:xxx_demo_app/features/booking/api/booking_api_service.dart';
import 'package:xxx_demo_app/features/foundation/model/booking/booking_submission_request_model.dart';
import 'package:xxx_demo_app/features/foundation/model/booking/booking_slot_model.dart';
import 'package:xxx_demo_app/features/foundation/model/booking/golf_club_model.dart';
import 'package:xxx_demo_app/features/foundation/network/network.dart';

import 'package:xxx_demo_app/features/booking/submission/slot/data/booking_submission_slot_repository.dart';

class BookingSubmissionSlotRepositoryImpl
    implements BookingSubmissionSlotRepository {
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
    try {
      final response = await _apiService.onFetchGolfClubList();
      final clubs = _parseGolfClubList(response);
      if (clubs.isNotEmpty) {
        return clubs;
      }
    } catch (_) {
      // Temporary fallback until the golf club list endpoint contract is ready.
    }

    return const <GolfClubModel>[
      GolfClubModel(
        id: '1',
        slug: 'kinrara-golf-club',
        name: 'Kinrara Golf Club',
        address: 'Bandar Kinrara, Puchong',
        noOfHoles: 18,
      ),
      GolfClubModel(
        id: '2',
        slug: 'saujana-golf-country-club',
        name: 'Saujana Golf & Country Club',
        address: 'Shah Alam, Selangor',
        noOfHoles: 36,
      ),
      GolfClubModel(
        id: '3',
        slug: 'kota-permai-golf-country-club',
        name: 'Kota Permai Golf & Country Club',
        address: 'Kota Kemuning, Shah Alam',
        noOfHoles: 18,
      ),
      GolfClubModel(
        id: '4',
        slug: 'mines-resort-golf-club',
        name: 'The Mines Resort & Golf Club',
        address: 'Serdang, Selangor',
        noOfHoles: 18,
      ),
    ];
  }

  @override
  Future<List<BookingSlotModel>> onFetchAvailableSlots({
    required String clubSlug,
    required String date,
  }) async {
    try {
      final response = await _apiService.onFetchAvailableSlots(
        clubSlug: clubSlug,
        date: date,
      );

      final slots = _parseAvailableSlots(response);
      if (slots.isNotEmpty) {
        return slots;
      }
    } catch (_) {
      // Temporary fallback until the available slots endpoint contract is ready.
    }

    return _buildFallbackSlots(clubSlug: clubSlug, date: date);
  }

  @override
  Future<dynamic> onCreateBookingSubmission({
    required BookingSubmissionRequestModel request,
  }) async {
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
    try {
      final response = await _apiService.onFetchBookingDetails(
        bookingSlug: bookingSlug,
      );

      if (response is Map<String, dynamic>) {
        final detailMap =
            response['data'] is Map<String, dynamic>
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
    final sanitizedTime = request.teeTimeSlot
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '');
    final suffix = DateTime.now().millisecondsSinceEpoch
        .toString()
        .substring(7);
    final bookingSlug =
        '$normalizedSlugSeed-$sanitizedDate-$sanitizedTime-$suffix';
    final bookingIdPrefix = normalizedSlugSeed.replaceAll('-', '').toUpperCase();
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

  List<BookingSlotModel> _buildFallbackSlots({
    required String clubSlug,
    required String date,
  }) {
    if (clubSlug == 'kinrara-golf-club') {
      return const <BookingSlotModel>[
        BookingSlotModel(time: '07:00 AM', price: 145, noOfHoles: 18),
        BookingSlotModel(time: '07:30 AM', price: 145, noOfHoles: 18),
        BookingSlotModel(time: '08:15 AM', price: 155, noOfHoles: 18),
        BookingSlotModel(time: '09:45 AM', price: 165, noOfHoles: 18),
        BookingSlotModel(time: '01:15 PM', price: 118, noOfHoles: 9),
      ];
    }

    if (clubSlug == 'saujana-golf-country-club') {
      return const <BookingSlotModel>[
        BookingSlotModel(time: '02:00 PM', price: 132, noOfHoles: 18),
        BookingSlotModel(time: '02:15 PM', price: 132, noOfHoles: 18),
        BookingSlotModel(time: '02:30 PM', price: 132, noOfHoles: 18),
        BookingSlotModel(time: '02:45 PM', price: 125, noOfHoles: 9),
        BookingSlotModel(time: '03:00 PM', price: 125, noOfHoles: 9),
      ];
    }

    if (clubSlug == 'kota-permai-golf-country-club') {
      return date.endsWith('-01') || date.endsWith('-15')
          ? const <BookingSlotModel>[]
          : const <BookingSlotModel>[
              BookingSlotModel(time: '10:00 AM', price: 188, noOfHoles: 18),
              BookingSlotModel(time: '12:00 PM', price: 164, noOfHoles: 18),
              BookingSlotModel(time: '04:15 PM', price: 105, noOfHoles: 9),
            ];
    }

    if (clubSlug == 'mines-resort-golf-club') {
      return const <BookingSlotModel>[];
    }

    return const <BookingSlotModel>[
      BookingSlotModel(time: '08:00 AM', price: 150, noOfHoles: 18),
      BookingSlotModel(time: '11:30 AM', price: 135, noOfHoles: 18),
      BookingSlotModel(time: '03:15 PM', price: 120, noOfHoles: 9),
    ];
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
