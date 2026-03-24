import 'dart:async';

import 'package:golf_kakis/features/activity/booking/list/data/activity_booking_list_repository.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_view_model.dart';

import 'activity_booking_list_view_contract.dart';

class ActivityBookingListViewModel
    extends
        MviViewModel<
          ActivityBookingListUserIntent,
          ActivityBookingListViewState,
          ActivityBookingListNavEffect
        >
    implements ActivityBookingListViewContract {
  ActivityBookingListViewModel({
    required ActivityBookingListRepository repository,
  }) : _repository = repository;

  final ActivityBookingListRepository _repository;

  @override
  ActivityBookingListViewState createInitialState() {
    return ActivityBookingListViewState.initial;
  }

  @override
  Future<void> handleIntent(ActivityBookingListUserIntent intent) async {
    switch (intent) {
      case OnInit():
        unawaited(_loadTab(ActivityBookingListTab.upcoming));
      case OnTabChanged():
        if (_shouldLoad(intent.tab)) {
          unawaited(_loadTab(intent.tab));
        }
      case OnRetryClick():
        unawaited(_loadTab(intent.tab, forceRefresh: true));
      case OnViewBookingDetailClick():
        sendNavEffect(() => NavigateToBookingDetails(intent.booking));
    }
  }

  @override
  Future<void> onRefresh(ActivityBookingListTab tab) {
    return _loadTab(tab, forceRefresh: true);
  }

  bool _shouldLoad(ActivityBookingListTab tab) {
    return switch (tab) {
      ActivityBookingListTab.upcoming => !viewState.hasLoadedUpcoming,
      ActivityBookingListTab.past => !viewState.hasLoadedPast,
    };
  }

  Future<void> _loadTab(
    ActivityBookingListTab tab, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final isLoading = switch (tab) {
        ActivityBookingListTab.upcoming => viewState.isUpcomingLoading,
        ActivityBookingListTab.past => viewState.isPastLoading,
      };
      if (isLoading) {
        return;
      }
    }

    emitViewState((state) {
      return switch (tab) {
        ActivityBookingListTab.upcoming => state.copyWith(
          isUpcomingLoading: true,
          clearUpcomingErrorMessage: true,
        ),
        ActivityBookingListTab.past => state.copyWith(
          isPastLoading: true,
          clearPastErrorMessage: true,
        ),
      };
    });

    try {
      final data = switch (tab) {
        ActivityBookingListTab.upcoming =>
          await _repository.onFetchUpcomingBookingList(),
        ActivityBookingListTab.past =>
          await _repository.onFetchPastBookingList(),
      };

      emitViewState((state) {
        return switch (tab) {
          ActivityBookingListTab.upcoming => state.copyWith(
            upcomingBookings: data.bookings,
            isUpcomingLoading: false,
            hasLoadedUpcoming: true,
            isUsingUpcomingFallback: data.isFallback,
            clearUpcomingErrorMessage: true,
          ),
          ActivityBookingListTab.past => state.copyWith(
            pastBookings: data.bookings,
            isPastLoading: false,
            hasLoadedPast: true,
            isUsingPastFallback: data.isFallback,
            clearPastErrorMessage: true,
          ),
        };
      });
    } catch (_) {
      emitViewState((state) {
        return switch (tab) {
          ActivityBookingListTab.upcoming => state.copyWith(
            isUpcomingLoading: false,
            isUsingUpcomingFallback: false,
            upcomingErrorMessage: 'Unable to load upcoming bookings right now.',
          ),
          ActivityBookingListTab.past => state.copyWith(
            isPastLoading: false,
            isUsingPastFallback: false,
            pastErrorMessage: 'Unable to load past bookings right now.',
          ),
        };
      });
    }
  }
}
