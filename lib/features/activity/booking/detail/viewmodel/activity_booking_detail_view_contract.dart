import 'package:xxx_demo_app/features/foundation/model/booking/booking_model.dart';
import 'package:xxx_demo_app/features/foundation/viewmodel/mvi_contract.dart';

abstract class ActivityBookingDetailViewContract {
  ActivityBookingDetailViewState get viewState;
  Stream<ActivityBookingDetailNavEffect> get navEffects;
  void onUserIntent(ActivityBookingDetailUserIntent intent);
}

class ActivityBookingDetailViewState extends ViewState {
  const ActivityBookingDetailViewState({
    required this.booking,
    required this.isLoading,
    required this.isDeleting,
    required this.isUsingFallback,
    this.errorMessage,
  }) : super();

  factory ActivityBookingDetailViewState.initial(BookingModel booking) {
    return ActivityBookingDetailViewState(
      booking: booking,
      isLoading: false,
      isDeleting: false,
      isUsingFallback: false,
    );
  }

  final BookingModel booking;
  final bool isLoading;
  final bool isDeleting;
  final bool isUsingFallback;
  final String? errorMessage;

  ActivityBookingDetailViewState copyWith({
    BookingModel? booking,
    bool? isLoading,
    bool? isDeleting,
    bool? isUsingFallback,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ActivityBookingDetailViewState(
      booking: booking ?? this.booking,
      isLoading: isLoading ?? this.isLoading,
      isDeleting: isDeleting ?? this.isDeleting,
      isUsingFallback: isUsingFallback ?? this.isUsingFallback,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}

sealed class ActivityBookingDetailUserIntent extends UserIntent {
  const ActivityBookingDetailUserIntent() : super();
}

class OnInit extends ActivityBookingDetailUserIntent {
  const OnInit();
}

class OnRefresh extends ActivityBookingDetailUserIntent {
  const OnRefresh();
}

class OnBackClick extends ActivityBookingDetailUserIntent {
  const OnBackClick();
}

class OnDeleteClick extends ActivityBookingDetailUserIntent {
  const OnDeleteClick();
}

class OnEditDetailsClick extends ActivityBookingDetailUserIntent {
  const OnEditDetailsClick();
}

class OnBookingUpdated extends ActivityBookingDetailUserIntent {
  const OnBookingUpdated(this.booking);

  final BookingModel booking;
}

sealed class ActivityBookingDetailNavEffect extends NavEffect {
  const ActivityBookingDetailNavEffect() : super();
}

class NavigateBack extends ActivityBookingDetailNavEffect {
  const NavigateBack({this.updatedBooking});

  final BookingModel? updatedBooking;
}

class NavigateToActivityBookingEdit extends ActivityBookingDetailNavEffect {
  const NavigateToActivityBookingEdit(this.booking);

  final BookingModel booking;
}
