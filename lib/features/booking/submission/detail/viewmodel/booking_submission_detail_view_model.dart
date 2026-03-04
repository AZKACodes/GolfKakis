import 'dart:async';

import 'package:flutter/foundation.dart';

import 'booking_submission_detail_view_contract.dart';

class BookingSubmissionDetailViewModel extends ChangeNotifier
    implements BookingSubmissionDetailViewContract {
  BookingSubmissionDetailViewModel({
    required String golfClubSlug,
    required String teeTimeSlot,
    String? guestId,
  }) : _viewState = BookingSubmissionDetailDataLoaded(
         golfClubSlug: golfClubSlug,
         teeTimeSlot: teeTimeSlot,
         guestId: guestId,
       );

  final StreamController<BookingSubmissionDetailNavEffect>
  _navEffectsController =
      StreamController<BookingSubmissionDetailNavEffect>.broadcast();

  BookingSubmissionDetailViewState _viewState;

  @override
  BookingSubmissionDetailViewState get viewState => _viewState;

  @override
  Stream<BookingSubmissionDetailNavEffect> get navEffects =>
      _navEffectsController.stream;

  @override
  void onUserIntent(BookingSubmissionDetailUserIntent intent) {
    switch (intent) {
      case OnHostNameChanged():
        _updateState(_currentState.copyWith(hostName: intent.value));
      case OnHostPhoneNumberChanged():
        _updateState(_currentState.copyWith(hostPhoneNumber: intent.value));
      case OnPlayerCountChanged():
        _updateState(_currentState.copyWith(playerCount: intent.value));
      case OnCaddieCountChanged():
        _updateState(_currentState.copyWith(caddieCount: intent.value));
      case OnGolfCartCountChanged():
        _updateState(_currentState.copyWith(golfCartCount: intent.value));
    }
  }

  BookingSubmissionDetailDataLoaded get _currentState {
    final state = _viewState;
    if (state is BookingSubmissionDetailDataLoaded) {
      return state;
    }

    return const BookingSubmissionDetailDataLoaded();
  }

  void _updateState(BookingSubmissionDetailViewState state) {
    _viewState = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _navEffectsController.close();
    super.dispose();
  }
}
