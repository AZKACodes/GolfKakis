import 'package:xxx_demo_app/features/foundation/model/booking/booking_submission_request_model.dart';
import 'package:xxx_demo_app/features/foundation/model/booking/booking_slot_model.dart';
import 'package:xxx_demo_app/features/foundation/model/booking/golf_club_model.dart';
import 'package:xxx_demo_app/features/foundation/model/data_status_model.dart';

abstract class BookingSubmissionSlotUseCase {
  Stream<DataStatusModel<List<GolfClubModel>>> onFetchGolfClubList();

  Stream<DataStatusModel<List<BookingSlotModel>>> onFetchAvailableSlots({
    required String clubSlug,
    required String date,
  });

  Stream<DataStatusModel<dynamic>> onCreateBookingSubmission({
    required BookingSubmissionRequestModel request,
  });

  Stream<DataStatusModel<dynamic>> onFetchBookingDetails({
    required String bookingSlug,
  });
}
