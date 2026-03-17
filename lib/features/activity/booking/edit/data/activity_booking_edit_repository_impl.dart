import 'package:golf_kakis/features/activity/booking/edit/data/activity_booking_edit_repository.dart';
import 'package:golf_kakis/features/booking/api/booking_api_service.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_model.dart';
import 'package:golf_kakis/features/foundation/network/network.dart';

class ActivityBookingEditRepositoryImpl
    implements ActivityBookingEditRepository {
  ActivityBookingEditRepositoryImpl({
    ApiClient? apiClient,
    BookingApiService? apiService,
  });

  @override
  Future<ActivityBookingEditSaveResult> onSaveBooking({
    required BookingModel booking,
  }) async {
    return ActivityBookingEditSaveResult(booking: booking, isFallback: true);
  }
}
