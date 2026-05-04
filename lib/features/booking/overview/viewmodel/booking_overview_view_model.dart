import 'package:golf_kakis/features/foundation/viewmodel/mvi_view_model.dart';

import '../domain/booking_overview_use_case.dart';
import 'booking_overview_view_contract.dart';

class BookingOverviewViewModel
    extends
        MviViewModel<
          BookingOverviewUserIntent,
          BookingOverviewViewState,
          BookingOverviewNavEffect
        >
    implements BookingOverviewViewContract {
  BookingOverviewViewModel(this._useCase);
  final BookingOverviewUseCase _useCase;

  String? _lastAccessToken;
  bool _lastIsLoggedIn = false;

  BookingOverviewDataLoaded get _currentDataState {
    return switch (currentState) {
      BookingOverviewDataLoaded() => currentState as BookingOverviewDataLoaded,
    };
  }

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
      final upcomingBooking = await _useCase.onFetchUpcomingBooking(
        accessToken: normalizedToken,
      );
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
}
