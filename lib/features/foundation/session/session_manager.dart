import 'dart:async';
import 'dart:convert';

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
  static const Duration _refreshSkew = Duration(seconds: 60);

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
    final resolvedAccessTokenExpiresAt = _resolveAccessTokenExpiresAt(
      accessToken: accessToken,
      expiresInSeconds: sessionExpiresInSeconds,
    );
    _state = _state.copyWith(
      status: SessionStatus.loggedIn,
      accessToken: accessToken,
      refreshToken: refreshToken,
      sessionId: sessionId,
      sessionExpiresInSeconds: sessionExpiresInSeconds,
      accessTokenExpiresAt: resolvedAccessTokenExpiresAt,
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

  Future<bool> logout() async {
    final loggedOutRemotely = await _notifyRemoteLogout();
    if (!loggedOutRemotely) {
      return false;
    }

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
    return true;
  }

  Future<bool> _notifyRemoteLogout() async {
    final accessToken = _state.accessToken?.trim();
    if (accessToken == null || accessToken.isEmpty) {
      return false;
    }

    try {
      final response = await _apiClient.postJson(
        '/auth/logout',
        headers: <String, String>{'Authorization': 'Bearer $accessToken'},
      );
      debugPrint('onLogout response: $response');
      return true;
    } catch (error, stackTrace) {
      debugPrint('onLogout error: $error');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    }
  }

  Future<bool> refreshSession() {
    return _refreshSessionFuture ??= _refreshSession().whenComplete(() {
      _refreshSessionFuture = null;
    });
  }

  bool shouldRefreshSession() {
    final refreshToken = _state.refreshToken?.trim();
    final accessToken = _state.accessToken?.trim();
    if (!_state.isLoggedIn ||
        refreshToken == null ||
        refreshToken.isEmpty ||
        accessToken == null ||
        accessToken.isEmpty) {
      return false;
    }

    final expiresAt = _accessTokenExpiresAt();
    if (expiresAt == null) {
      return false;
    }

    return !DateTime.now().toUtc().add(_refreshSkew).isBefore(expiresAt);
  }

  Future<bool> _refreshSession() async {
    final refreshToken = _state.refreshToken?.trim();
    if (refreshToken == null || refreshToken.isEmpty) {
      if (_state.isLoggedIn) {
        await _expireLocalAuthSession();
      }
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

      final expiresInSeconds = _readInt(
        sessionJson['expiresInSeconds'] ??
            sessionJson['sessionExpiresInSeconds'] ??
            response['expiresInSeconds'] ??
            response['sessionExpiresInSeconds'],
      );

      if (nextAccessToken.isEmpty || nextRefreshToken.isEmpty) {
        return false;
      }

      final userJson = _extractRefreshUserJson(response);
      _state = _state.copyWith(
        accessToken: nextAccessToken,
        refreshToken: nextRefreshToken,
        sessionId: _readString(sessionJson, <String>[
          'sessionId',
        ], fallback: _state.sessionId ?? ''),
        sessionExpiresInSeconds:
            expiresInSeconds ?? _state.sessionExpiresInSeconds,
        accessTokenExpiresAt:
            _resolveAccessTokenExpiresAt(
              accessToken: nextAccessToken,
              expiresInSeconds: expiresInSeconds,
            ) ??
            _state.accessTokenExpiresAt,
        refreshExpiresAt: _readString(sessionJson, <String>[
          'refreshExpiresAt',
        ], fallback: _state.refreshExpiresAt ?? ''),
        authUserId: _readString(userJson, <String>[
          'userId',
        ], fallback: _state.authUserId ?? ''),
        authId: _readString(userJson, <String>[
          'authId',
        ], fallback: _state.authId ?? ''),
        isPhoneVerified:
            _readBool(userJson['isPhoneVerified']) ?? _state.isPhoneVerified,
        authCreatedAt: _readString(userJson, <String>[
          'createdAt',
        ], fallback: _state.authCreatedAt ?? ''),
        authUpdatedAt: _readString(userJson, <String>[
          'updatedAt',
        ], fallback: _state.authUpdatedAt ?? ''),
        authenticatedUsername: _readString(userJson, <String>[
          'name',
          'username',
        ], fallback: _state.authenticatedUsername ?? ''),
        authenticatedUserRole:
            _userRoleFromName(_readString(userJson, <String>['roleName'])) ??
            _state.authenticatedUserRole,
        profileFullName: _readString(userJson, <String>[
          'name',
        ], fallback: _state.profileFullName ?? ''),
        profilePhoneNumber: _readString(userJson, <String>[
          'phoneNumber',
        ], fallback: _state.profilePhoneNumber ?? ''),
        hasPin: _readBool(userJson['hasPin']) ?? _state.hasPin,
        hasPasskey: _readBool(userJson['hasPasskey']) ?? _state.hasPasskey,
      );
      await _persistState();
      notifyListeners();
      return true;
    } on ApiException catch (error, stackTrace) {
      debugPrint('Failed to refresh app session: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (error.statusCode == 401) {
        await _expireLocalAuthSession();
      }
      return false;
    } catch (error, stackTrace) {
      debugPrint('Failed to refresh app session: $error');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    }
  }

  Future<void> _expireLocalAuthSession() async {
    if (!_state.isLoggedIn &&
        (_state.accessToken?.isEmpty ?? true) &&
        (_state.refreshToken?.isEmpty ?? true)) {
      return;
    }

    _state = _state.copyWith(
      status: SessionStatus.loggedOut,
      clearAuthSession: true,
      clearAuthenticatedUsername: true,
      clearAuthenticatedUserRole: true,
      clearProfileDetails: true,
    );
    await _persistState();
    notifyListeners();
    unawaited(_refreshVisitorAfterLogout());
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

  Map<String, dynamic> _extractRefreshUserJson(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is Map<String, dynamic>) {
      final user = data['user'];
      if (user is Map<String, dynamic>) {
        return user;
      }
    }

    final user = json['user'];
    if (user is Map<String, dynamic>) {
      return user;
    }

    return const <String, dynamic>{};
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

  int? _readInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '');
  }

  bool? _readBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    final text = value?.toString().toLowerCase();
    if (text == 'true') {
      return true;
    }
    if (text == 'false') {
      return false;
    }
    return null;
  }

  UserRole? _userRoleFromName(String name) {
    if (name.trim().isEmpty) {
      return null;
    }
    for (final role in UserRole.values) {
      if (role.name == name.trim().toLowerCase()) {
        return role;
      }
    }
    return null;
  }

  DateTime? _accessTokenExpiresAt() {
    final stored = DateTime.tryParse(_state.accessTokenExpiresAt ?? '');
    if (stored != null) {
      return stored.toUtc();
    }
    final fromJwt = _expiresAtFromJwt(_state.accessToken);
    if (fromJwt != null) {
      return fromJwt;
    }
    return null;
  }

  String? _resolveAccessTokenExpiresAt({
    required String? accessToken,
    required int? expiresInSeconds,
  }) {
    final fromJwt = _expiresAtFromJwt(accessToken);
    if (fromJwt != null) {
      return fromJwt.toIso8601String();
    }
    if (expiresInSeconds != null && expiresInSeconds > 0) {
      return DateTime.now()
          .toUtc()
          .add(Duration(seconds: expiresInSeconds))
          .toIso8601String();
    }
    return null;
  }

  DateTime? _expiresAtFromJwt(String? token) {
    final parts = token?.split('.') ?? const <String>[];
    if (parts.length < 2) {
      return null;
    }

    try {
      final normalizedPayload = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(normalizedPayload));
      final payload = jsonDecode(decoded);
      if (payload is! Map) {
        return null;
      }
      final exp = _readInt(payload['exp']);
      if (exp == null || exp <= 0) {
        return null;
      }
      return DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true);
    } catch (_) {
      return null;
    }
  }
}
