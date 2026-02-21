import 'dart:async';

import 'package:flutter/foundation.dart';

import '../domain/get_home_message_use_case.dart';
import 'home_view_contract.dart';

class HomeViewModel extends ChangeNotifier implements HomeViewContract {
  HomeViewModel(this._getHomeMessage);

  final GetHomeMessageUseCase _getHomeMessage;

  HomeViewState _viewState = HomeViewState.initial;
  final StreamController<HomeNavEffect> _navEffectsController =
      StreamController<HomeNavEffect>.broadcast();

  @override
  HomeViewState get viewState => _viewState;

  @override
  Stream<HomeNavEffect> get navEffects => _navEffectsController.stream;

  @override
  void onUserIntent(HomeUserIntent intent) {
    switch (intent) {
      case LoadHomeDataIntent():
        _loadData();
    }
  }

  Future<void> _loadData() async {
    _viewState = _viewState.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      final message = await _getHomeMessage();
      _viewState = _viewState.copyWith(
        message: message,
        isLoading: false,
        clearError: true,
      );
    } catch (_) {
      _viewState = _viewState.copyWith(
        isLoading: false,
        error: 'Failed to load home data',
      );
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _navEffectsController.close();
    super.dispose();
  }
}
