import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golf_kakis/features/activity/booking/list/data/activity_booking_list_repository.dart';

import 'activity_booking_list_view_contract.dart';

class ActivityBookingListViewModel extends ChangeNotifier
    implements ActivityBookingListViewContract {
  ActivityBookingListViewModel({
    required ActivityBookingListRepository repository,
  }) : _repository = repository;

  final ActivityBookingListRepository _repository;
  final StreamController<ActivityBookingListNavEffect> _navEffectsController =
      StreamController<ActivityBookingListNavEffect>.broadcast();

  ActivityBookingListViewState _viewState =
      ActivityBookingListViewState.initial;

  @override
  ActivityBookingListViewState get viewState => _viewState;

  @override
  Stream<ActivityBookingListNavEffect> get navEffects =>
      _navEffectsController.stream;

  @override
  void onUserIntent(ActivityBookingListUserIntent intent) {
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
        _navEffectsController.add(
          NavigateToActivityBookingDetail(intent.booking),
        );
    }
  }

  @override
  Future<void> onRefresh(ActivityBookingListTab tab) {
    return _loadTab(tab, forceRefresh: true);
  }

  bool _shouldLoad(ActivityBookingListTab tab) {
    return switch (tab) {
      ActivityBookingListTab.upcoming => !_viewState.hasLoadedUpcoming,
      ActivityBookingListTab.past => !_viewState.hasLoadedPast,
    };
  }

  Future<void> _loadTab(
    ActivityBookingListTab tab, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final isLoading = switch (tab) {
        ActivityBookingListTab.upcoming => _viewState.isUpcomingLoading,
        ActivityBookingListTab.past => _viewState.isPastLoading,
      };
      if (isLoading) {
        return;
      }
    }

    _viewState = switch (tab) {
      ActivityBookingListTab.upcoming => _viewState.copyWith(
        isUpcomingLoading: true,
        clearUpcomingErrorMessage: true,
      ),
      ActivityBookingListTab.past => _viewState.copyWith(
        isPastLoading: true,
        clearPastErrorMessage: true,
      ),
    };
    notifyListeners();

    try {
      final data = switch (tab) {
        ActivityBookingListTab.upcoming =>
          await _repository.onFetchUpcomingBookingList(),
        ActivityBookingListTab.past =>
          await _repository.onFetchPastBookingList(),
      };

      _viewState = switch (tab) {
        ActivityBookingListTab.upcoming => _viewState.copyWith(
          upcomingBookings: data.bookings,
          isUpcomingLoading: false,
          hasLoadedUpcoming: true,
          isUsingUpcomingFallback: data.isFallback,
          clearUpcomingErrorMessage: true,
        ),
        ActivityBookingListTab.past => _viewState.copyWith(
          pastBookings: data.bookings,
          isPastLoading: false,
          hasLoadedPast: true,
          isUsingPastFallback: data.isFallback,
          clearPastErrorMessage: true,
        ),
      };
    } catch (_) {
      _viewState = switch (tab) {
        ActivityBookingListTab.upcoming => _viewState.copyWith(
          isUpcomingLoading: false,
          isUsingUpcomingFallback: false,
          upcomingErrorMessage: 'Unable to load upcoming bookings right now.',
        ),
        ActivityBookingListTab.past => _viewState.copyWith(
          isPastLoading: false,
          isUsingPastFallback: false,
          pastErrorMessage: 'Unable to load past bookings right now.',
        ),
      };
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _navEffectsController.close();
    super.dispose();
  }
}
