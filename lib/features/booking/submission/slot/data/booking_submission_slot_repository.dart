import 'package:golf_kakis/features/foundation/model/booking/booking_hold_request_model.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_submission_request_model.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_slot_model.dart';
import 'package:golf_kakis/features/foundation/model/booking/golf_club_model.dart';

abstract class BookingSubmissionSlotRepository {
  Future<List<GolfClubModel>> onFetchGolfClubList();

  Future<List<BookingSlotModel>> onFetchAvailableSlots({
    required String clubSlug,
    required String date,
    required String playType,
    String? selectedNine,
  });

  Future<dynamic> onCreateBookingHold({
    required BookingHoldRequestModel request,
  });

  Future<dynamic> onCreateBookingSubmission({
    required BookingSubmissionRequestModel request,
  });

  Future<dynamic> onFetchBookingDetails({required String bookingSlug});
}
