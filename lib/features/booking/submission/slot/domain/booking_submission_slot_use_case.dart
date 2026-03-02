import 'package:xxx_demo_app/features/foundation/model/booking/booking_slot_model.dart';
import 'package:xxx_demo_app/features/foundation/model/data_status_model.dart';

abstract class BookingSubmissionSlotUseCase {
  Stream<DataStatusModel<List<String>>> onFetchGolfClubList();

  Stream<DataStatusModel<List<BookingSlotModel>>> onFetchAvailableSlots({
    required String clubSlug,
    required String date,
  });

  Stream<DataStatusModel<dynamic>> onCreateBookingSubmission();
}
