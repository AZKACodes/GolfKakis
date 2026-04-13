import 'package:golf_kakis/features/booking/edit/data/booking_edit_repository.dart';
import 'package:golf_kakis/features/booking/api/booking_api_service.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_model.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_submission_player_model.dart';
import 'package:golf_kakis/features/foundation/network/network.dart';

class BookingEditRepositoryImpl implements BookingEditRepository {
  BookingEditRepositoryImpl({
    ApiClient? apiClient,
    BookingApiService? apiService,
  }) : _apiService =
           apiService ?? BookingApiService(apiClient: apiClient ?? ApiClient());

  final BookingApiService _apiService;

  @override
  Future<BookingEditSaveResult> onSaveBooking({
    required BookingModel booking,
  }) async {
    final response = await _apiService.onUpdateBookingDetails(
      bookingId: booking.bookingId,
      request: <String, dynamic>{
        'playerDetails': booking.playerDetails
            .map((player) => player.toJson())
            .toList(),
      },
    );

    final payload = response is Map<String, dynamic>
        ? response['data'] is Map<String, dynamic>
              ? response['data'] as Map<String, dynamic>
              : response
        : const <String, dynamic>{};

    final updatedPlayers = _parsePlayers(payload['playerDetails']);

    return BookingEditSaveResult(
      booking: booking.copyWith(
        playerDetails: updatedPlayers.isEmpty
            ? booking.playerDetails
            : updatedPlayers,
      ),
    );
  }

  List<BookingSubmissionPlayerModel> _parsePlayers(dynamic response) {
    if (response is! List) {
      return const <BookingSubmissionPlayerModel>[];
    }

    return response.whereType<Map<dynamic, dynamic>>().map((item) {
      final data = item.map((key, value) => MapEntry(key.toString(), value));
      return BookingSubmissionPlayerModel(
        name: data['name']?.toString() ?? data['playerName']?.toString() ?? '',
        phoneNumber:
            data['phoneNumber']?.toString() ??
            data['phone_number']?.toString() ??
            data['phone']?.toString() ??
            '',
      );
    }).toList();
  }
}
