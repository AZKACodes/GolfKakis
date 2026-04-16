import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golf_kakis/features/booking/list/data/booking_list_repository_impl.dart';

import 'booking_overview_view_contract.dart';

class BookingOverviewViewModel extends ChangeNotifier
    implements BookingOverviewViewContract {
  BookingOverviewViewModel();

  final StreamController<BookingOverviewNavEffect> _navEffectsController =
      StreamController<BookingOverviewNavEffect>.broadcast();

  BookingOverviewViewState _viewState = BookingOverviewViewState.initial;

  @override
  BookingOverviewViewState get viewState => _viewState;

  @override
  Stream<BookingOverviewNavEffect> get navEffects =>
      _navEffectsController.stream;

  @override
  Future<void> onUserIntent(BookingOverviewUserIntent intent) async {
    switch (intent) {
      case OnInit():
        await _handleInit(intent.accessToken);
      case OnBookingSubmissionClick():
        _navEffectsController.add(const NavigateToBookingSubmission());
      case OnPopularClubClick():
        _navEffectsController.add(NavigateToGolfClubDetail(intent.club));
      case OnBookingListClick():
        _navEffectsController.add(const NavigateToBookingList());
      case OnUpcomingBookingDetailClick():
        final booking = _viewState.upcomingBooking;
        if (booking != null) {
          _navEffectsController.add(NavigateToBookingDetail(booking));
        }
    }
  }

  Future<void> _handleInit(String? accessToken) async {
    final normalizedToken = accessToken?.trim() ?? '';
    if (normalizedToken.isEmpty) {
      _updateState(
        _viewState.copyWith(
          isLoggedIn: false,
          isUpcomingLoading: false,
          clearUpcomingBooking: true,
        ),
      );
      return;
    }

    _updateState(
      _viewState.copyWith(isLoggedIn: true, isUpcomingLoading: true),
    );

    try {
      final repository = BookingListRepositoryImpl(
        accessToken: normalizedToken,
      );
      final result = await repository.onFetchUpcomingBookingList();
      final upcomingBooking = result.bookings.isEmpty
          ? null
          : result.bookings.first;
      _updateState(
        _viewState.copyWith(
          isLoggedIn: true,
          isUpcomingLoading: false,
          upcomingBooking: upcomingBooking,
          clearUpcomingBooking: upcomingBooking == null,
        ),
      );
    } catch (_) {
      _updateState(
        _viewState.copyWith(
          isLoggedIn: true,
          isUpcomingLoading: false,
          clearUpcomingBooking: true,
        ),
      );
    }
  }

  void _updateState(BookingOverviewViewState nextState) {
    _viewState = nextState;
    notifyListeners();
  }

  @override
  void dispose() {
    _navEffectsController.close();
    super.dispose();
  }
}
