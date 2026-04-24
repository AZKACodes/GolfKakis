import 'package:golf_kakis/features/foundation/model/booking/booking_hold_request_model.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_submission_request_model.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_slot_model.dart';
import 'package:golf_kakis/features/foundation/model/booking/golf_club_model.dart';
import 'package:golf_kakis/features/foundation/model/data_status_model.dart';

abstract class BookingSubmissionSlotUseCase {
  Stream<DataStatusModel<List<GolfClubModel>>> onFetchGolfClubList();

  Stream<DataStatusModel<List<BookingSlotModel>>> onFetchAvailableSlots({
    required String clubSlug,
    required String date,
    required String playType,
    String? selectedNine,
  });

  Stream<DataStatusModel<dynamic>> onCreateBookingHold({
    required BookingHoldRequestModel request,
  });

  Stream<DataStatusModel<dynamic>> onCreateBookingSubmission({
    required BookingSubmissionRequestModel request,
  });

  Stream<DataStatusModel<dynamic>> onFetchBookingDetails({
    required String bookingRef,
  });
}
