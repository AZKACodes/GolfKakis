import 'dart:async';

import 'package:flutter/foundation.dart';

import 'booking_submission_view_contract.dart';

class BookingSubmissionViewModel extends ChangeNotifier
    implements BookingSubmissionViewContract {
  final StreamController<BookingSubmissionNavEffect> _navEffectsController =
      StreamController<BookingSubmissionNavEffect>.broadcast();

  final BookingSubmissionViewState _viewState =
      BookingSubmissionViewState.initial;

  @override
  BookingSubmissionViewState get viewState => _viewState;

  @override
  Stream<BookingSubmissionNavEffect> get navEffects =>
      _navEffectsController.stream;

  @override
  void onUserIntent(BookingSubmissionUserIntent intent) {
    switch (intent) {
      case BookingSubmissionBackTappedIntent():
        _navEffectsController.add(const BookingSubmissionPopNavEffect());
    }
  }

  @override
  void dispose() {
    _navEffectsController.close();
    super.dispose();
  }
}
