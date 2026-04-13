import 'package:golf_kakis/features/booking/detail/data/booking_detail_repository.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_model.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_view_model.dart';

import 'booking_detail_view_contract.dart';

class BookingDetailViewModel
    extends
        MviViewModel<
          BookingDetailUserIntent,
          BookingDetailViewState,
          BookingDetailNavEffect
        >
    implements BookingDetailViewContract {
  BookingDetailViewModel({
    required BookingModel initialBooking,
    required BookingDetailRepository repository,
  }) : _initialBooking = initialBooking,
       _repository = repository;

  final BookingModel _initialBooking;
  final BookingDetailRepository _repository;

  @override
  BookingDetailViewState createInitialState() {
    return BookingDetailViewState.initial(_initialBooking);
  }

  @override
  Future<void> handleIntent(BookingDetailUserIntent intent) async {
    switch (intent) {
      case OnInit():
      case OnRefresh():
        await _loadBookingDetail();
      case OnBackClick():
        sendNavEffect(() => const NavigateBack());
      case OnDeleteClick():
        await _deleteBooking();
      case OnEditDetailsClick():
        sendNavEffect(() => NavigateToBookingEdit(currentState.booking));
      case OnBookingUpdated():
        emitViewState(
          (state) =>
              state.copyWith(booking: intent.booking, clearErrorMessage: true),
        );
    }
  }

  Future<void> _loadBookingDetail() async {
    emitViewState(
      (state) => state.copyWith(isLoading: true, clearErrorMessage: true),
    );

    try {
      final result = await _repository.onFetchBookingDetail(
        booking: currentState.booking,
      );
      emitViewState(
        (state) => state.copyWith(
          booking: result.booking,
          isLoading: false,
          clearErrorMessage: true,
        ),
      );
    } catch (_) {
      emitViewState(
        (state) => state.copyWith(
          isLoading: false,
          errorMessage: 'Unable to load booking details right now.',
        ),
      );
    }
  }

  Future<void> _deleteBooking() async {
    emitViewState(
      (state) => state.copyWith(isDeleting: true, clearErrorMessage: true),
    );

    try {
      await _repository.onDeleteBooking(booking: currentState.booking);
      emitViewState((state) => state.copyWith(isDeleting: false));
      sendNavEffect(() => const NavigateBack());
    } catch (_) {
      emitViewState(
        (state) => state.copyWith(
          isDeleting: false,
          errorMessage: 'Unable to delete this booking right now.',
        ),
      );
    }
  }
}
