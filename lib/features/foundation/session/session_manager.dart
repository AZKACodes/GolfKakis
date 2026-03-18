import 'package:flutter/foundation.dart';

import '../device/device_id_service.dart';
import '../enums/session/session_status.dart';
import '../enums/session/user_role.dart';
import 'session_state.dart';

class SessionManager extends ChangeNotifier {
  SessionManager({required DeviceIdService deviceIdService})
    : _deviceIdService = deviceIdService;

  final DeviceIdService _deviceIdService;

  SessionState _state = SessionState.initial;
  SessionState get state => _state;
  String get deviceId => _state.deviceId;

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

  void login({
    required String username,
    required UserRole role,
    String? profileFullName,
    String? profileNickname,
    String? profileOccupation,
    String? profileEmail,
    String? profilePhoneNumber,
    int? profileAvatarIndex,
  }) {
    _state = _state.copyWith(
      status: SessionStatus.loggedIn,
      authenticatedUsername: username,
      authenticatedUserRole: role,
      profileFullName: profileFullName,
      profileNickname: profileNickname,
      profileOccupation: profileOccupation,
      profileEmail: profileEmail,
      profilePhoneNumber: profilePhoneNumber,
      profileAvatarIndex: profileAvatarIndex,
    );
    notifyListeners();
  }

  void updateProfile({
    required String fullName,
    required String nickname,
    required String occupation,
    required String email,
    required String phoneNumber,
    required int avatarIndex,
  }) {
    _state = _state.copyWith(
      authenticatedUsername: fullName,
      profileFullName: fullName,
      profileNickname: nickname,
      profileOccupation: occupation,
      profileEmail: email,
      profilePhoneNumber: phoneNumber,
      profileAvatarIndex: avatarIndex,
    );
    notifyListeners();
  }

  void logout() {
    _state = _state.copyWith(
      status: SessionStatus.loggedOut,
      clearAuthenticatedUsername: true,
      clearAuthenticatedUserRole: true,
      clearProfileDetails: true,
    );
    notifyListeners();
  }
}
