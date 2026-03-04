import 'dart:async';

import 'package:flutter/foundation.dart';

import 'activity_overview_view_contract.dart';

class ActivityOverviewViewModel extends ChangeNotifier
    implements ActivityOverviewViewContract {
  final StreamController<ActivityOverviewNavEffect> _navEffectsController =
      StreamController<ActivityOverviewNavEffect>.broadcast();

  final ActivityOverviewViewState _viewState = ActivityOverviewViewState.initial;

  @override
  ActivityOverviewViewState get viewState => _viewState;

  @override
  Stream<ActivityOverviewNavEffect> get navEffects =>
      _navEffectsController.stream;

  @override
  void onUserIntent(ActivityOverviewUserIntent intent) {
    switch (intent) {
      case OnBookingListClick():
        _navEffectsController.add(const NavigateToActivityBookingList());
    }
  }

  @override
  void dispose() {
    _navEffectsController.close();
    super.dispose();
  }
}
