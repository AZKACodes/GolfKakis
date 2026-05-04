import 'package:golf_kakis/features/booking/edit/data/booking_edit_repository.dart';
import 'package:golf_kakis/features/booking/edit/data/booking_edit_repository_impl.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_model.dart';

import 'booking_edit_use_case.dart';

class BookingEditUseCaseImpl implements BookingEditUseCase {
  const BookingEditUseCaseImpl();

  @override
  Future<BookingEditSaveResult> saveBooking({required BookingModel booking}) {
    return BookingEditRepositoryImpl().onSaveBooking(booking: booking);
  }
}
