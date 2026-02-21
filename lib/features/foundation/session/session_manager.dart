import 'package:flutter/foundation.dart';

import '../device/device_id_service.dart';
import '../enums/session/session_status.dart';
import 'session_state.dart';

class SessionManager extends ChangeNotifier {
  SessionManager({required DeviceIdService deviceIdService})
    : _deviceIdService = deviceIdService;

  final DeviceIdService _deviceIdService;

  SessionState _state = SessionState.initial;
  SessionState get state => _state;

  bool _initialized = false;
  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    final deviceId = await _deviceIdService.getDeviceId();
    _state = _state.copyWith(deviceId: deviceId);
    _initialized = true;
    notifyListeners();
  }

  void login({required String username}) {
    _state = _state.copyWith(
      status: SessionStatus.loggedIn,
      authenticatedUsername: username,
    );
    notifyListeners();
  }

  void logout() {
    _state = _state.copyWith(
      status: SessionStatus.loggedOut,
      clearAuthenticatedUsername: true,
    );
    notifyListeners();
  }
}
