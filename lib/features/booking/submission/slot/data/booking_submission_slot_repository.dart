import 'package:golf_kakis/features/foundation/model/request/booking_hold_request_model.dart';
import 'package:golf_kakis/features/foundation/model/booking_slot_details_model.dart';
import 'package:golf_kakis/features/foundation/model/request/booking_submission_request_model.dart';
import 'package:golf_kakis/features/foundation/model/booking_slot_model.dart';
import 'package:golf_kakis/features/foundation/model/golf_club_model.dart';

abstract class BookingSubmissionSlotRepository {
  Future<List<GolfClubModel>> onFetchGolfClubList();

  Future<List<BookingSlotModel>> onFetchAvailableSlots({
    required String clubSlug,
    required String date,
    required String playType,
    required int playerCount,
    String? selectedNine,
  });

  Future<BookingSlotDetailsModel> onFetchSlotDetails({
    required String slotId,
    required String clubSlug,
    required String date,
    required String playType,
    required int playerCount,
    String? selectedNine,
  });

  Future<dynamic> onCreateBookingHold({
    required BookingHoldRequestModel request,
  });

  Future<dynamic> onExtendBookingHold({
    required String bookingRef,
    required String accessToken,
  });

  Future<dynamic> onPreviewBooking({
    required String accessToken,
    required Map<String, dynamic> request,
  });

  Future<dynamic> onCreateBookingSubmission({
    required BookingSubmissionRequestModel request,
  });

  Future<dynamic> onFetchBookingDetails({required String bookingRef});
}
