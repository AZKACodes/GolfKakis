import 'dart:async';

import 'package:flutter/foundation.dart';

import '../device/device_id_service.dart';
import '../enums/session/session_status.dart';
import '../enums/session/user_role.dart';
import 'session_state.dart';
import 'session_storage.dart';
import 'visitor_api_service.dart';

class SessionManager extends ChangeNotifier {
  SessionManager({
    required DeviceIdService deviceIdService,
    SessionStorage? sessionStorage,
    VisitorApiService? visitorApiService,
  }) : _deviceIdService = deviceIdService,
       _sessionStorage = sessionStorage ?? SessionStorage(),
       _visitorApiService = visitorApiService ?? VisitorApiService();

  final DeviceIdService _deviceIdService;
  final SessionStorage _sessionStorage;
  final VisitorApiService _visitorApiService;

  SessionState _state = SessionState.initial;
  SessionState get state => _state;
  String get deviceId => _state.deviceId;

  bool _initialized = false;
  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    final restoredState = await _sessionStorage.read();
    if (restoredState != null) {
      _state = restoredState;
    }

    final deviceId = await _deviceIdService.getDeviceId();
    _state = _state.copyWith(deviceId: deviceId);

    if (_shouldSyncVisitor(deviceId)) {
      await _syncVisitor(deviceId);
    }

    await _persistState();
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
    unawaited(_persistState());
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
    unawaited(_persistState());
    notifyListeners();
  }

  void logout() {
    _state = _state.copyWith(
      status: SessionStatus.loggedOut,
      clearAuthenticatedUsername: true,
      clearAuthenticatedUserRole: true,
      clearProfileDetails: true,
    );
    unawaited(_persistState());
    notifyListeners();
  }

  bool _shouldSyncVisitor(String deviceId) {
    if (deviceId.trim().isEmpty || deviceId == SessionState.initial.deviceId) {
      return false;
    }

    final visitor = _state.visitor;
    return visitor == null || visitor.id != deviceId;
  }

  Future<void> _syncVisitor(String deviceId) async {
    try {
      final visitor = await _visitorApiService.onSetVisitorHeartbeat(
        visitorId: deviceId,
        platform: _visitorApiService.resolvePlatform(),
      );
      _state = _state.copyWith(visitor: visitor);
    } catch (error, stackTrace) {
      debugPrint('Failed to set visitor heartbeat: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _persistState() {
    return _sessionStorage.write(_state);
  }
}
