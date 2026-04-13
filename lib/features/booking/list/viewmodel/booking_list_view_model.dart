import 'dart:async';

import 'package:golf_kakis/features/booking/list/data/booking_list_repository.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_view_model.dart';

import 'booking_list_view_contract.dart';

class BookingListViewModel
    extends
        MviViewModel<
          BookingListUserIntent,
          BookingListViewState,
          BookingListNavEffect
        >
    implements BookingListViewContract {
  BookingListViewModel({required BookingListRepository repository})
    : _repository = repository;

  final BookingListRepository _repository;

  @override
  BookingListViewState createInitialState() {
    return BookingListViewState.initial;
  }

  @override
  Future<void> handleIntent(BookingListUserIntent intent) async {
    switch (intent) {
      case OnInit():
        unawaited(_loadTab(BookingListTab.upcoming));
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
  Future<void> onRefresh(BookingListTab tab) {
    return _loadTab(tab, forceRefresh: true);
  }

  bool _shouldLoad(BookingListTab tab) {
    return switch (tab) {
      BookingListTab.upcoming => !viewState.hasLoadedUpcoming,
      BookingListTab.past => !viewState.hasLoadedPast,
    };
  }

  Future<void> _loadTab(BookingListTab tab, {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final isLoading = switch (tab) {
        BookingListTab.upcoming => viewState.isUpcomingLoading,
        BookingListTab.past => viewState.isPastLoading,
      };
      if (isLoading) {
        return;
      }
    }

    emitViewState((state) {
      return switch (tab) {
        BookingListTab.upcoming => state.copyWith(isUpcomingLoading: true),
        BookingListTab.past => state.copyWith(isPastLoading: true),
      };
    });

    try {
      final data = switch (tab) {
        BookingListTab.upcoming =>
          await _repository.onFetchUpcomingBookingList(),
        BookingListTab.past => await _repository.onFetchPastBookingList(),
      };

      emitViewState((state) {
        return switch (tab) {
          BookingListTab.upcoming => state.copyWith(
            upcomingBookings: data.bookings,
            isUpcomingLoading: false,
            hasLoadedUpcoming: true,
          ),
          BookingListTab.past => state.copyWith(
            pastBookings: data.bookings,
            isPastLoading: false,
            hasLoadedPast: true,
          ),
        };
      });
    } catch (_) {
      sendNavEffect(
        () => ShowBookingListError(
          tab == BookingListTab.upcoming
              ? 'Failed to load upcoming bookings.'
              : 'Failed to load past bookings.',
        ),
      );
      emitViewState((state) {
        return switch (tab) {
          BookingListTab.upcoming => state.copyWith(isUpcomingLoading: false),
          BookingListTab.past => state.copyWith(isPastLoading: false),
        };
      });
    }
  }
}
