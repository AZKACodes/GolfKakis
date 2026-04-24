import 'package:golf_kakis/features/booking/api/booking_api_service.dart';
import 'package:golf_kakis/features/booking/submission/slot/data/booking_submission_slot_repository.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_hold_request_model.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_slot_model.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_submission_request_model.dart';
import 'package:golf_kakis/features/foundation/model/booking/golf_club_model.dart';
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
    String? selectedNine,
  }) async {
    final response = await _apiService.onFetchAvailableSlots(
      clubSlug: clubSlug,
      date: date,
      playType: playType,
      selectedNine: selectedNine,
    );

    List<BookingSlotModel> parseAvailableSlots(dynamic rawResponse) {
      if (rawResponse is List) {
        return rawResponse
            .whereType<Map<String, dynamic>>()
            .map(BookingSlotModel.fromJson)
            .where((slot) => slot.time.isNotEmpty)
            .toList();
      }

      if (rawResponse is Map<String, dynamic>) {
        final dynamic nestedList =
            rawResponse['data'] ??
            rawResponse['items'] ??
            rawResponse['slots'] ??
            rawResponse['availableSlots'];
        if (nestedList is List) {
          return nestedList
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

        return parseAvailableSlots(nestedList);
      }

      return const <BookingSlotModel>[];
    }

    return parseAvailableSlots(response);
  }

  @override
  Future<dynamic> onCreateBookingHold({
    required BookingHoldRequestModel request,
  }) async {
    final response = await _apiService.onCreateBookingHold(request: request);
    return _normalizeBookingHoldResponse(response);
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

    final bookingId =
        payload['bookingId'] ?? payload['booking_id'] ?? payload['id'];
    if ((bookingId?.toString() ?? '').trim().isEmpty) {
      throw ApiException(
        message: 'Booking submission response is missing bookingId.',
      );
    }

    return payload;
  }

  Map<String, dynamic> _normalizeBookingHoldResponse(dynamic response) {
    final payload = _extractPayload(response);
    if (payload == null) {
      throw ApiException(message: 'Invalid booking hold response.');
    }

    final bookingId = payload['bookingId']?.toString() ?? '';
    final status = payload['status']?.toString().toLowerCase() ?? '';

    if (bookingId.trim().isEmpty || status != 'held') {
      throw ApiException(message: 'Booking hold was not completed.');
    }

    return payload;
  }

  Map<String, dynamic>? _extractPayload(dynamic response) {
    if (response is! Map<String, dynamic>) {
      return null;
    }

    final nested = response['data'] ?? response['booking'] ?? response['item'];
    if (nested is Map<String, dynamic>) {
      return nested;
    }

    return response;
  }
}
