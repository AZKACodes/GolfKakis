import 'package:golf_kakis/features/booking/api/booking_api_service.dart';
import 'package:golf_kakis/features/booking/submission/slot/data/booking_submission_slot_repository.dart';
import 'package:golf_kakis/features/foundation/model/request/booking_hold_request_model.dart';
import 'package:golf_kakis/features/foundation/model/booking_slot_model.dart';
import 'package:golf_kakis/features/foundation/model/booking_slot_details_model.dart';
import 'package:golf_kakis/features/foundation/model/request/booking_submission_request_model.dart';
import 'package:golf_kakis/features/foundation/model/golf_club_model.dart';
import 'package:golf_kakis/features/foundation/network/network.dart';

class BookingSubmissionSlotRepositoryImpl
    implements BookingSubmissionSlotRepository {
  BookingSubmissionSlotRepositoryImpl({
    ApiClient? apiClient,
    BookingApiService? apiService,
  }) : _apiService =
           apiService ?? BookingApiService(apiClient: apiClient ?? ApiClient());

  final BookingApiService _apiService;

  @override
  Future<List<GolfClubModel>> onFetchGolfClubList() async {
    final response = await _apiService.onFetchGolfClubList();

    List<GolfClubModel> parseGolfClubList(dynamic rawResponse) {
      if (rawResponse is List) {
        return rawResponse
            .whereType<Map<String, dynamic>>()
            .map(GolfClubModel.fromJson)
            .where((club) => club.slug.isNotEmpty)
            .toList();
      }

      if (rawResponse is Map<String, dynamic>) {
        final dynamic nestedList =
            rawResponse['data'] ?? rawResponse['items'] ?? rawResponse['clubs'];
        return parseGolfClubList(nestedList);
      }

      return const <GolfClubModel>[];
    }

    return parseGolfClubList(response);
  }

  @override
  Future<List<BookingSlotModel>> onFetchAvailableSlots({
    required String clubSlug,
    required String date,
    required String playType,
    required int playerCount,
    String? selectedNine,
  }) async {
    final response = await _apiService.onFetchAvailableSlots(
      clubSlug: clubSlug,
      date: date,
      playType: playType,
      playerCount: playerCount,
      selectedNine: selectedNine,
    );

    List<BookingSlotModel> parseAvailableSlots(dynamic rawResponse) {
      if (rawResponse is List) {
        return rawResponse
            .map(_asStringMap)
            .whereType<Map<String, dynamic>>()
            .map(
              (slot) => BookingSlotModel.fromJson(<String, dynamic>{
                ...slot,
                'noOfHoles': slot['noOfHoles'] ?? 18,
              }),
            )
            .where((slot) => slot.time.isNotEmpty)
            .toList();
      }

      final map = _asStringMap(rawResponse);
      if (map != null) {
        final dynamic nestedList =
            map['data'] ??
            map['items'] ??
            map['slots'] ??
            map['availableSlots'];
        return parseAvailableSlots(nestedList);
      }

      return const <BookingSlotModel>[];
    }

    return parseAvailableSlots(response);
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

  @override
  Future<BookingSlotDetailsModel> onFetchSlotDetails({
    required String slotId,
    required String clubSlug,
    required String date,
    required String playType,
    required int playerCount,
    String? selectedNine,
  }) async {
    final response = await _apiService.onFetchSlotDetails(
      slotId: slotId,
      clubSlug: clubSlug,
      date: date,
      playType: playType,
      playerCount: playerCount,
      selectedNine: selectedNine,
    );
    final payload = _extractPayload(response);
    if (payload == null) {
      throw ApiException(message: 'Invalid slot details response.');
    }

    return BookingSlotDetailsModel.fromJson(payload);
  }

  @override
  Future<dynamic> onCreateBookingHold({
    required BookingHoldRequestModel request,
  }) async {
    final response = await _apiService.onCreateBookingHold(request: request);
    return _normalizeBookingHoldResponse(response);
  }

  @override
  Future<dynamic> onExtendBookingHold({
    required String bookingRef,
    required String accessToken,
  }) async {
    final response = await _apiService.onExtendBookingHold(
      bookingRef: bookingRef,
      accessToken: accessToken,
    );
    return _normalizeBookingHoldResponse(response);
  }

  @override
  Future<dynamic> onPreviewBooking({
    required String accessToken,
    required Map<String, dynamic> request,
  }) async {
    final response = await _apiService.onPreviewBooking(
      accessToken: accessToken,
      request: request,
    );
    final payload = _extractPayload(response);
    if (payload == null) {
      throw ApiException(message: 'Invalid booking preview response.');
    }
    return payload;
  }

  @override
  Future<dynamic> onCreateBookingSubmission({
    required BookingSubmissionRequestModel request,
  }) async {
    final response = await _apiService.onCreateBookingSubmission(
      request: request,
    );
    return _normalizeSubmissionResponse(response);
  }

  @override
  Future<dynamic> onFetchBookingDetails({required String bookingRef}) {
    return _apiService.onFetchBookingDetails(bookingRef: bookingRef);
  }

  Map<String, dynamic> _normalizeSubmissionResponse(dynamic response) {
    final payload = _extractPayload(response);
    if (payload == null) {
      throw ApiException(message: 'Invalid booking submission response.');
    }

    final bookingReference =
        payload['bookingId'] ??
        payload['booking_id'] ??
        payload['id'] ??
        payload['bookingRef'] ??
        payload['booking_ref'];
    if ((bookingReference?.toString() ?? '').trim().isEmpty) {
      throw ApiException(
        message: 'Booking submission response is missing booking reference.',
      );
    }

    return payload;
  }

  Map<String, dynamic> _normalizeBookingHoldResponse(dynamic response) {
    final payload = _extractPayload(response);
    if (payload == null) {
      throw ApiException(message: 'Invalid booking hold response.');
    }

    final bookingId =
        payload['bookingId']?.toString() ??
        payload['booking_id']?.toString() ??
        payload['holdId']?.toString() ??
        payload['hold_id']?.toString() ??
        payload['id']?.toString() ??
        payload['bookingRef']?.toString() ??
        payload['booking_ref']?.toString() ??
        '';
    final status = payload['status']?.toString().toLowerCase() ?? '';

    if (bookingId.trim().isEmpty ||
        (status.isNotEmpty && status != 'held' && status != 'hold')) {
      throw ApiException(message: 'Booking hold was not completed.');
    }

    return payload;
  }

  Map<String, dynamic>? _extractPayload(dynamic response) {
    final responseMap = _asStringMap(response);
    if (responseMap == null) {
      return null;
    }

    final nested =
        responseMap['data'] ??
        responseMap['details'] ??
        responseMap['hold'] ??
        responseMap['bookingHold'] ??
        responseMap['booking_hold'] ??
        responseMap['quote'] ??
        responseMap['booking'] ??
        responseMap['item'];
    final nestedMap = _asStringMap(nested);
    if (nestedMap != null) {
      return nestedMap;
    }

    return responseMap;
  }
}
