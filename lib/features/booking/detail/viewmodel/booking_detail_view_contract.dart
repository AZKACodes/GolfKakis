import 'package:golf_kakis/features/foundation/model/booking/booking_model.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_contract.dart';

abstract class BookingDetailViewContract {
  BookingDetailViewState get viewState;
  Stream<BookingDetailNavEffect> get navEffects;
  void onUserIntent(BookingDetailUserIntent intent);
}

class BookingDetailViewState extends ViewState {
  const BookingDetailViewState({
    required this.booking,
    required this.isLoading,
    required this.isDeleting,
    this.errorMessage,
  }) : super();

  factory BookingDetailViewState.initial(BookingModel booking) {
    return BookingDetailViewState(
      booking: booking,
      isLoading: true,
      isDeleting: false,
    );
  }

  final BookingModel booking;
  final bool isLoading;
  final bool isDeleting;
  final String? errorMessage;

  BookingDetailViewState copyWith({
    BookingModel? booking,
    bool? isLoading,
    bool? isDeleting,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return BookingDetailViewState(
      booking: booking ?? this.booking,
      isLoading: isLoading ?? this.isLoading,
      isDeleting: isDeleting ?? this.isDeleting,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}

sealed class BookingDetailUserIntent extends UserIntent {
  const BookingDetailUserIntent() : super();
}

class OnInit extends BookingDetailUserIntent {
  const OnInit();
}

class OnRefresh extends BookingDetailUserIntent {
  const OnRefresh();
}

class OnBackClick extends BookingDetailUserIntent {
  const OnBackClick();
}

class OnDeleteClick extends BookingDetailUserIntent {
  const OnDeleteClick();
}

class OnEditDetailsClick extends BookingDetailUserIntent {
  const OnEditDetailsClick();
}

class OnBookingUpdated extends BookingDetailUserIntent {
  const OnBookingUpdated(this.booking);

  final BookingModel booking;
}

sealed class BookingDetailNavEffect extends NavEffect {
  const BookingDetailNavEffect() : super();
}

class NavigateBack extends BookingDetailNavEffect {
  const NavigateBack({this.updatedBooking});

  final BookingModel? updatedBooking;
}

class NavigateToBookingEdit extends BookingDetailNavEffect {
  const NavigateToBookingEdit(this.booking);

  final BookingModel booking;
}
