import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:xxx_demo_app/features/foundation/model/booking/booking_model.dart';

import 'activity_booking_detail_view_contract.dart';

class ActivityBookingDetailViewModel extends ChangeNotifier
    implements ActivityBookingDetailViewContract {
  ActivityBookingDetailViewModel({required BookingModel booking})
    : _viewState = ActivityBookingDetailViewState(booking: booking);

  final StreamController<ActivityBookingDetailNavEffect> _navEffectsController =
      StreamController<ActivityBookingDetailNavEffect>.broadcast();

  ActivityBookingDetailViewState _viewState;

  @override
  ActivityBookingDetailViewState get viewState => _viewState;

  @override
  Stream<ActivityBookingDetailNavEffect> get navEffects =>
      _navEffectsController.stream;

  @override
  void onUserIntent(ActivityBookingDetailUserIntent intent) {
    switch (intent) {
      case OnBackClick():
        _navEffectsController.add(const NavigateBack());
      case OnDeleteClick():
        _navEffectsController.add(const NavigateBack());
      case OnEditDetailsClick():
        _navEffectsController.add(
          NavigateToActivityBookingEdit(_viewState.booking),
        );
      case OnBookingUpdated():
        _viewState = ActivityBookingDetailViewState(booking: intent.booking);
        notifyListeners();
    }
  }

  @override
  void dispose() {
    _navEffectsController.close();
    super.dispose();
  }
}
