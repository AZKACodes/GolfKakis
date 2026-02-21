import '../enums/session/session_status.dart';

class SessionState {
  const SessionState({
    required this.status,
    required this.deviceId,
    this.authenticatedUsername,
  });

  final SessionStatus status;
  final String deviceId;
  final String? authenticatedUsername;

  String get effectiveUsername {
    if (status == SessionStatus.loggedIn && authenticatedUsername != null) {
      return authenticatedUsername!;
    }
    return deviceId;
  }

  SessionState copyWith({
    SessionStatus? status,
    String? deviceId,
    String? authenticatedUsername,
    bool clearAuthenticatedUsername = false,
  }) {
    return SessionState(
      status: status ?? this.status,
      deviceId: deviceId ?? this.deviceId,
      authenticatedUsername: clearAuthenticatedUsername
          ? null
          : (authenticatedUsername ?? this.authenticatedUsername),
    );
  }

  static const SessionState initial = SessionState(
    status: SessionStatus.loggedOut,
    deviceId: 'unknown-device',
  );
}
