import 'package:flutter/foundation.dart';

import '../domain/get_home_message_use_case.dart';
import 'home_view_contract.dart';

class HomeViewModel extends ChangeNotifier implements HomeViewContract {
  HomeViewModel(this._getHomeMessage);

  final GetHomeMessageUseCase _getHomeMessage;

  String? _message;
  bool _isLoading = false;
  String? _error;

  @override
  String? get message => _message;

  @override
  bool get isLoading => _isLoading;

  @override
  String? get error => _error;

  @override
  Future<void> loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _message = await _getHomeMessage();
    } catch (e) {
      _error = 'Failed to load home data';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
