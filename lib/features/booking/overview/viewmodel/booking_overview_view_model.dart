import 'dart:async';

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
  String _accessToken = '';

  @override
  BookingOverviewViewState createInitialState() =>
      BookingOverviewViewState.initial;

  @override
  Future<void> handleIntent(BookingOverviewUserIntent intent) async {
    switch (intent) {
      case OnInitBookingOverview():
        final normalizedAccessToken = intent.accessToken.trim();
        if (!intent.isLoggedIn || normalizedAccessToken.isEmpty) {
          _accessToken = '';
          emitViewState((_) => BookingOverviewViewState.initial);
          return;
        }

        if (_accessToken == normalizedAccessToken) {
          return;
        }
        _accessToken = normalizedAccessToken;
        emitViewState((_) => BookingOverviewViewState.initial);
        unawaited(_loadTab(BookingOverviewTab.upcoming, forceRefresh: true));
      case OnTabChanged():
        if (_shouldLoad(intent.tab)) {
          unawaited(_loadTab(intent.tab));
        }
      case OnViewBookingDetailClick():
        sendNavEffect(() => NavigateToBookingDetail(intent.booking));
    }
  }

  @override
  Future<void> onRefresh(BookingOverviewTab tab) {
    return _loadTab(tab, forceRefresh: true);
  }

  bool _shouldLoad(BookingOverviewTab tab) {
    return switch (tab) {
      BookingOverviewTab.upcoming => !viewState.hasLoadedUpcoming,
      BookingOverviewTab.past => !viewState.hasLoadedPast,
    };
  }

  Future<void> _loadTab(
    BookingOverviewTab tab, {
    bool forceRefresh = false,
  }) async {
    if (_accessToken.isEmpty) {
      return;
    }

    if (!forceRefresh) {
      final isLoading = switch (tab) {
        BookingOverviewTab.upcoming => viewState.isUpcomingLoading,
        BookingOverviewTab.past => viewState.isPastLoading,
      };
      if (isLoading) {
        return;
      }
    }

    emitViewState((state) {
      return switch (tab) {
        BookingOverviewTab.upcoming => state.copyWith(isUpcomingLoading: true),
        BookingOverviewTab.past => state.copyWith(isPastLoading: true),
      };
    });

    try {
      final data = switch (tab) {
        BookingOverviewTab.upcoming =>
          await _useCase.onFetchUpcomingBookingList(accessToken: _accessToken),
        BookingOverviewTab.past => await _useCase.onFetchPastBookingList(
          accessToken: _accessToken,
        ),
      };

      emitViewState((state) {
        return switch (tab) {
          BookingOverviewTab.upcoming => state.copyWith(
            upcomingBookings: data.bookings,
            isUpcomingLoading: false,
            hasLoadedUpcoming: true,
          ),
          BookingOverviewTab.past => state.copyWith(
            pastBookings: data.bookings,
            isPastLoading: false,
            hasLoadedPast: true,
          ),
        };
      });
    } catch (_) {
      sendNavEffect(
        () => ShowBookingOverviewError(
          tab == BookingOverviewTab.upcoming
              ? 'Failed to load upcoming bookings.'
              : 'Failed to load past bookings.',
        ),
      );
      emitViewState((state) {
        return switch (tab) {
          BookingOverviewTab.upcoming => state.copyWith(
            isUpcomingLoading: false,
          ),
          BookingOverviewTab.past => state.copyWith(isPastLoading: false),
        };
      });
    }
  }
}
