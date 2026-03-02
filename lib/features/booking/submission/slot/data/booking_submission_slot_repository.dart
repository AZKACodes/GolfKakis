import '../../../../foundation/model/booking/booking_slot_model.dart';

abstract class BookingSubmissionSlotRepository {
  Future<List<String>> onFetchGolfClubList();

  Future<List<BookingSlotModel>> onFetchAvailableSlots({
    required String clubSlug,
    required String date,
  });

  Future<dynamic> onCreateBookingSubmission();
}
