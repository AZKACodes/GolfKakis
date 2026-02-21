import 'dart:async';

import 'package:flutter/foundation.dart';

import 'booking_overview_view_contract.dart';

class BookingOverviewViewModel extends ChangeNotifier
    implements BookingOverviewViewContract {
  final StreamController<BookingOverviewNavEffect> _navEffectsController =
      StreamController<BookingOverviewNavEffect>.broadcast();

  final BookingOverviewViewState _viewState = BookingOverviewViewState.initial;

  @override
  BookingOverviewViewState get viewState => _viewState;

  @override
  Stream<BookingOverviewNavEffect> get navEffects =>
      _navEffectsController.stream;

  @override
  void onUserIntent(BookingOverviewUserIntent intent) {
    switch (intent) {
      case OnBookingSubmissionClick():
        _navEffectsController.add(const NavigateToBookingSubmission());
    }
  }

  @override
  void dispose() {
    _navEffectsController.close();
    super.dispose();
  }
}
