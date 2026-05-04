import 'package:golf_kakis/features/booking/edit/data/booking_edit_repository.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_model.dart';

abstract class BookingEditUseCase {
  Future<BookingEditSaveResult> saveBooking({required BookingModel booking});
}
