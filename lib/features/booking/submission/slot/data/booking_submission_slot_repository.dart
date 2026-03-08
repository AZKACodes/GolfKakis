import 'package:xxx_demo_app/features/foundation/model/booking/booking_slot_model.dart';
import 'package:xxx_demo_app/features/foundation/model/booking/golf_club_model.dart';

abstract class BookingSubmissionSlotRepository {
  Future<List<GolfClubModel>> onFetchGolfClubList();

  Future<List<BookingSlotModel>> onFetchAvailableSlots({
    required String clubSlug,
    required String date,
  });

  Future<dynamic> onCreateBookingSubmission();
}
