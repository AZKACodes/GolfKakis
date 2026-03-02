import 'package:xxx_demo_app/features/booking/api/booking_api_service.dart';
import 'package:xxx_demo_app/features/foundation/model/booking/booking_slot_model.dart';
import 'package:xxx_demo_app/features/foundation/network/network.dart';

import 'package:xxx_demo_app/features/booking/submission/slot/data/booking_submission_slot_repository.dart';

class BookingSubmissionSlotRepositoryImpl
    implements BookingSubmissionSlotRepository {
  BookingSubmissionSlotRepositoryImpl({
    ApiClient? apiClient,
    BookingApiService? apiService,
  }) : _apiService =
           apiService ?? BookingApiService(apiClient: apiClient ?? ApiClient());

  final BookingApiService _apiService;

  @override
  Future<List<String>> onFetchGolfClubList() async {
    // Temporary fallback until the golf club list endpoint contract is ready.
    return const <String>[
      'kinrara-golf-club',
      'saujana-golf-country-club',
      'kota-permai-golf-country-club',
      'mines-resort-golf-club',
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

      if (response is Map<String, dynamic>) {
        return <BookingSlotModel>[BookingSlotModel.fromJson(response)];
      }

      if (response is String) {
        return <BookingSlotModel>[BookingSlotModel(slotList: response)];
      }

      if (response is List) {
        return response
            .map(
              (slot) => slot is Map<String, dynamic>
                  ? BookingSlotModel.fromJson(slot)
                  : BookingSlotModel(slotList: slot.toString()),
            )
            .toList();
      }
    } catch (_) {
      // Temporary fallback until the available slots endpoint contract is ready.
    }

    return _buildFallbackSlots()
        .map((slot) => BookingSlotModel(slotList: slot))
        .toList();
  }

  @override
  Future<dynamic> onCreateBookingSubmission() {
    return _apiService.onCreateBookingSubmission();
  }

  List<String> _buildFallbackSlots() {
    const int startMinutes = 7 * 60;
    const int endMinutes = (17 * 60) + 30;
    const int intervalMinutes = 15;
    final int slotCount = ((endMinutes - startMinutes) ~/ intervalMinutes) + 1;

    return List<String>.generate(slotCount, (index) {
      final int minutesFromMidnight = startMinutes + (index * intervalMinutes);
      final int hour24 = minutesFromMidnight ~/ 60;
      final int minute = minutesFromMidnight % 60;
      final bool isPm = hour24 >= 12;
      final int hour12 = (hour24 % 12 == 0) ? 12 : hour24 % 12;
      final String period = isPm ? 'PM' : 'AM';

      return '${hour12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
    });
  }
}
