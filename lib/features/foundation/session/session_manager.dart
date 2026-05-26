import 'dart:async';

import 'package:flutter/foundation.dart';

import '../device/device_id_service.dart';
import '../enums/session/session_status.dart';
import '../enums/session/user_role.dart';
import '../network/network.dart';
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
       _visitorApiService = visitorApiService ?? VisitorApiService(),
       _apiClient = ApiClient();

  final DeviceIdService _deviceIdService;
  final SessionStorage _sessionStorage;
  final VisitorApiService _visitorApiService;
  final ApiClient _apiClient;

  SessionState _state = SessionState.initial;
  SessionState get state => _state;
  String get deviceId => _state.deviceId;
  String get clientPlatform => _state.clientPlatform ?? 'android';
  bool get isLoggedIn => _state.isLoggedIn;

  bool _initialized = false;
  bool get isInitialized => _initialized;
  Future<bool>? _refreshSessionFuture;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    final restoredState = await _sessionStorage.read();
    if (restoredState != null) {
      _state = restoredState;
    }

    final deviceId = await _deviceIdService.getDeviceId();
    final clientPlatform = _visitorApiService.resolvePlatform();
    _state = _state.copyWith(
      deviceId: deviceId,
      clientPlatform: clientPlatform,
    );

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
    String? accessToken,
    String? refreshToken,
    String? sessionId,
    int? sessionExpiresInSeconds,
    String? refreshExpiresAt,
    String? authUserId,
    String? authId,
    bool? isPhoneVerified,
    String? authCreatedAt,
    String? authUpdatedAt,
    String? profileFullName,
    String? profileNickname,
    String? profileOccupation,
    String? profileEmail,
    String? profilePhoneNumber,
    int? profileAvatarIndex,
    String? profileAvatarImagePath,
    bool? hasPin,
    bool? hasPasskey,
    bool? hasOTPFallback,
  }) {
    _state = _state.copyWith(
      status: SessionStatus.loggedIn,
      accessToken: accessToken,
      refreshToken: refreshToken,
      sessionId: sessionId,
      sessionExpiresInSeconds: sessionExpiresInSeconds,
      refreshExpiresAt: refreshExpiresAt,
      authUserId: authUserId,
      authId: authId,
      isPhoneVerified: isPhoneVerified,
      authCreatedAt: authCreatedAt,
      authUpdatedAt: authUpdatedAt,
      authenticatedUsername: username,
      authenticatedUserRole: role,
      profileFullName: profileFullName,
      profileNickname: profileNickname,
      profileOccupation: profileOccupation,
      profileEmail: profileEmail,
      profilePhoneNumber: profilePhoneNumber,
      profileAvatarIndex: profileAvatarIndex,
      profileAvatarImagePath: profileAvatarImagePath,
      hasPin: hasPin,
      hasPasskey: hasPasskey,
      hasOTPFallback: hasOTPFallback,
    );
    unawaited(_persistState());
    notifyListeners();
  }

  void updateLoginMethods({
    required bool hasPin,
    required bool hasPasskey,
    required bool hasOTPFallback,
  }) {
    _state = _state.copyWith(
      hasPin: hasPin,
      hasPasskey: hasPasskey,
      hasOTPFallback: hasOTPFallback,
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
    String? avatarImagePath,
  }) {
    _state = _state.copyWith(
      authenticatedUsername: fullName,
      profileFullName: fullName,
      profileNickname: nickname,
      profileOccupation: occupation,
      profileEmail: email,
      profilePhoneNumber: phoneNumber,
      profileAvatarIndex: avatarIndex,
      profileAvatarImagePath: avatarImagePath,
    );
    unawaited(_persistState());
    notifyListeners();
  }

  void logout() {
    _state = _state.copyWith(
      status: SessionStatus.loggedOut,
      clearAuthSession: true,
      clearAuthenticatedUsername: true,
      clearAuthenticatedUserRole: true,
      clearProfileDetails: true,
      clearVisitor: true,
    );
    unawaited(_persistState());
    notifyListeners();
    unawaited(_refreshVisitorAfterLogout());
  }

  Future<bool> refreshSession() {
    return _refreshSessionFuture ??= _refreshSession().whenComplete(() {
      _refreshSessionFuture = null;
    });
  }

  Future<bool> _refreshSession() async {
    final refreshToken = _state.refreshToken?.trim();
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    try {
      final response = await _apiClient.postJsonWithoutSharedHeaders(
        '/auth/session/refresh',
        headers: <String, String>{'x-client-platform': clientPlatform},
        body: <String, dynamic>{'refreshToken': refreshToken},
      );

      if (response is! Map<String, dynamic>) {
        return false;
      }

      final sessionJson = _extractRefreshSessionJson(response);
      final nextAccessToken = _readString(response, <String>[
        'accessToken',
      ], fallback: _readString(sessionJson, <String>['accessToken']));
      final nextRefreshToken = _readString(response, <String>[
        'refreshToken',
      ], fallback: _readString(sessionJson, <String>['refreshToken']));

      if (nextAccessToken.isEmpty || nextRefreshToken.isEmpty) {
        return false;
      }

      _state = _state.copyWith(
        accessToken: nextAccessToken,
        refreshToken: nextRefreshToken,
        sessionId: _readString(sessionJson, <String>[
          'sessionId',
        ], fallback: _state.sessionId ?? ''),
        sessionExpiresInSeconds:
            sessionJson['expiresInSeconds'] as int? ??
            sessionJson['sessionExpiresInSeconds'] as int? ??
            _state.sessionExpiresInSeconds,
        refreshExpiresAt: _readString(sessionJson, <String>[
          'refreshExpiresAt',
        ], fallback: _state.refreshExpiresAt ?? ''),
      );
      await _persistState();
      notifyListeners();
      return true;
    } catch (error, stackTrace) {
      debugPrint('Failed to refresh app session: $error');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    }
  }

  Future<void> _refreshVisitorAfterLogout() async {
    final currentDeviceId = _state.deviceId;
    if (!_shouldSyncVisitor(currentDeviceId)) {
      return;
    }

    await _syncVisitor(currentDeviceId);
    await _persistState();
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
      final visitor = await _visitorApiService.onInitVisitorHeartbeat(
        visitorId: deviceId,
        platform: clientPlatform,
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

  Map<String, dynamic> _extractRefreshSessionJson(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is Map<String, dynamic>) {
      final session = data['session'];
      if (session is Map<String, dynamic>) {
        return session;
      }
      return data;
    }

    final session = json['session'];
    if (session is Map<String, dynamic>) {
      return session;
    }

    return json;
  }

  String _readString(
    Map<String, dynamic> json,
    List<String> keys, {
    String fallback = '',
  }) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return fallback;
  }
}
