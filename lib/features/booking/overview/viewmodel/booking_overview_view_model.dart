import 'package:golf_kakis/features/booking/list/data/booking_list_repository_impl.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_view_model.dart';

import 'booking_overview_view_contract.dart';

class BookingOverviewViewModel
    extends
        MviViewModel<
          BookingOverviewUserIntent,
          BookingOverviewViewState,
          BookingOverviewNavEffect
        >
    implements BookingOverviewViewContract {
  BookingOverviewViewModel();
  String? _lastAccessToken;
  bool _lastIsLoggedIn = false;

  @override
  BookingOverviewViewState createInitialState() =>
      BookingOverviewDataLoaded.initial;

  @override
  Future<void> handleIntent(BookingOverviewUserIntent intent) async {
    switch (intent) {
      case OnInit():
        await _handleInit(
          isLoggedIn: intent.isLoggedIn,
          accessToken: intent.accessToken,
        );
      case OnBookingSubmissionClick():
        sendNavEffect(() => const NavigateToBookingSubmission());
      case OnPopularClubClick():
        sendNavEffect(() => NavigateToGolfClubDetail(intent.club));
      case OnBookingListClick():
        sendNavEffect(() => const NavigateToBookingList());
      case OnUpcomingBookingDetailClick():
        final booking = _currentDataState.upcomingBooking;
        if (booking != null) {
          sendNavEffect(() => NavigateToBookingDetail(booking));
        }
    }
  }

  Future<void> _handleInit({
    required bool isLoggedIn,
    String? accessToken,
  }) async {
    final normalizedToken = accessToken?.trim() ?? '';
    if (_lastIsLoggedIn == isLoggedIn && _lastAccessToken == normalizedToken) {
      return;
    }

    _lastIsLoggedIn = isLoggedIn;
    _lastAccessToken = normalizedToken;

    if (!isLoggedIn || normalizedToken.isEmpty) {
      emitViewState(
        (_) => _currentDataState.copyWith(
          isLoggedIn: false,
          isUpcomingLoading: false,
          clearUpcomingBooking: true,
        ),
      );
      return;
    }

    emitViewState(
      (_) =>
          _currentDataState.copyWith(isLoggedIn: true, isUpcomingLoading: true),
    );

    try {
      final repository = BookingListRepositoryImpl(
        accessToken: normalizedToken,
      );
      final result = await repository.onFetchUpcomingBookingList();
      final upcomingBooking = result.bookings.isEmpty
          ? null
          : result.bookings.first;
      emitViewState(
        (_) => _currentDataState.copyWith(
          isLoggedIn: true,
          isUpcomingLoading: false,
          upcomingBooking: upcomingBooking,
          clearUpcomingBooking: upcomingBooking == null,
        ),
      );
    } catch (_) {
      emitViewState(
        (_) => _currentDataState.copyWith(
          isLoggedIn: true,
          isUpcomingLoading: false,
          clearUpcomingBooking: true,
        ),
      );
    }
  }

  BookingOverviewDataLoaded get _currentDataState {
    return switch (currentState) {
      BookingOverviewDataLoaded() => currentState as BookingOverviewDataLoaded,
    };
  }
}
