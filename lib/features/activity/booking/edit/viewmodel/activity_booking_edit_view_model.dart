import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:xxx_demo_app/features/foundation/model/booking/booking_model.dart';

import 'activity_booking_edit_view_contract.dart';

class ActivityBookingEditViewModel extends ChangeNotifier
    implements ActivityBookingEditViewContract {
  ActivityBookingEditViewModel({required BookingModel booking})
    : _viewState = ActivityBookingEditViewState(booking: booking);

  final StreamController<ActivityBookingEditNavEffect> _navEffectsController =
      StreamController<ActivityBookingEditNavEffect>.broadcast();

  ActivityBookingEditViewState _viewState;

  @override
  ActivityBookingEditViewState get viewState => _viewState;

  @override
  Stream<ActivityBookingEditNavEffect> get navEffects =>
      _navEffectsController.stream;

  @override
  void onUserIntent(ActivityBookingEditUserIntent intent) {
    switch (intent) {
      case OnBackClick():
        _navEffectsController.add(const NavigateBack());
      case OnPlayerNameChanged():
        _updatePlayer(index: intent.index, name: intent.value);
      case OnPlayerPhoneChanged():
        _updatePlayer(index: intent.index, phone: intent.value);
      case OnSaveClick():
        _navEffectsController.add(
          NavigateBack(updatedBooking: _viewState.booking),
        );
    }
  }

  void _updatePlayer({required int index, String? name, String? phone}) {
    final players = [..._viewState.booking.playerDetails];
    final current = players[index];
    players[index] = current.copyWith(
      name: name ?? current.name,
      phoneNumber: phone ?? current.phoneNumber,
    );
    _viewState = ActivityBookingEditViewState(
      booking: _viewState.booking.copyWith(playerDetails: players),
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _navEffectsController.close();
    super.dispose();
  }
}
