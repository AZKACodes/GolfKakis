import 'dart:async';

import 'package:flutter/foundation.dart';

import 'root_view_contract.dart';

class RootViewModel extends ChangeNotifier implements RootViewContract {
  RootViewState _viewState = RootViewState.initial;
  final StreamController<RootNavEffect> _navEffectsController =
      StreamController<RootNavEffect>.broadcast();

  @override
  RootViewState get viewState => _viewState;

  @override
  Stream<RootNavEffect> get navEffects => _navEffectsController.stream;

  @override
  void onUserIntent(RootUserIntent intent) {
    switch (intent) {
      case RootTabSelectedIntent(:final index):
        if (_viewState.currentIndex == index) {
          return;
        }
        _viewState = _viewState.copyWith(currentIndex: index);
        _navEffectsController.add(RootTabChangedNavEffect(index));
        notifyListeners();
    }
  }

  @override
  void dispose() {
    _navEffectsController.close();
    super.dispose();
  }
}
