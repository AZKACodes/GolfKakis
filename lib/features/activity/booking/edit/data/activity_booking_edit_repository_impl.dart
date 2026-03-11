import 'package:xxx_demo_app/features/activity/booking/edit/data/activity_booking_edit_repository.dart';
import 'package:xxx_demo_app/features/booking/api/booking_api_service.dart';
import 'package:xxx_demo_app/features/foundation/model/booking/booking_model.dart';
import 'package:xxx_demo_app/features/foundation/network/network.dart';

class ActivityBookingEditRepositoryImpl
    implements ActivityBookingEditRepository {
  ActivityBookingEditRepositoryImpl({
    ApiClient? apiClient,
    BookingApiService? apiService,
  }) : _apiService =
           apiService ?? BookingApiService(apiClient: apiClient ?? ApiClient());

  final BookingApiService _apiService;

  @override
  Future<ActivityBookingEditSaveResult> onSaveBooking({
    required BookingModel booking,
  }) async {
    try {
      final response = await _apiService.onUpdateBookingDetails(
        bookingId: booking.bookingId,
        request: <String, dynamic>{
          'hostName': booking.hostName,
          'hostPhoneNumber': booking.hostPhoneNumber,
          'playerCount': booking.playerCount,
          'caddieCount': booking.caddieCount,
          'golfCartCount': booking.golfCartCount,
          'playerDetails': booking.playerDetails
              .map((player) => player.toJson())
              .toList(),
        },
      );

      final payload = response is Map<String, dynamic>
          ? response['data'] is Map<String, dynamic>
                ? response['data'] as Map<String, dynamic>
                : response['booking'] is Map<String, dynamic>
                ? response['booking'] as Map<String, dynamic>
                : response
          : null;
      final responsePlayers = payload?['playerDetails'] is List
          ? payload!['playerDetails'] as List<dynamic>
          : null;

      final savedBooking = payload == null
          ? booking
          : booking.copyWith(
              hostName:
                  payload['hostName']?.toString() ??
                  payload['bookedByName']?.toString() ??
                  booking.hostName,
              hostPhoneNumber:
                  payload['hostPhoneNumber']?.toString() ??
                  payload['contactPhone']?.toString() ??
                  booking.hostPhoneNumber,
              playerDetails: responsePlayers != null
                  ? booking.playerDetails.asMap().entries.map((entry) {
                      final index = entry.key;
                      final current = entry.value;
                      final item = index < responsePlayers.length
                          ? responsePlayers[index]
                          : null;
                      if (item is! Map<dynamic, dynamic>) {
                        return current;
                      }
                      return current.copyWith(
                        name: item['name']?.toString() ?? current.name,
                        phoneNumber:
                            item['phoneNumber']?.toString() ??
                            current.phoneNumber,
                      );
                    }).toList()
                  : booking.playerDetails,
            );

      return ActivityBookingEditSaveResult(
        booking: savedBooking,
        isFallback: false,
      );
    } catch (_) {
      return ActivityBookingEditSaveResult(booking: booking, isFallback: true);
    }
  }
}
