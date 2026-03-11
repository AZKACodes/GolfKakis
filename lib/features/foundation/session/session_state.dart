import '../enums/session/session_status.dart';
import '../enums/session/user_role.dart';

class SessionState {
  const SessionState({
    required this.status,
    required this.deviceId,
    this.authenticatedUsername,
    this.authenticatedUserRole,
  });

  final SessionStatus status;
  final String deviceId;
  final String? authenticatedUsername;
  final UserRole? authenticatedUserRole;

  String get effectiveUsername {
    if (status == SessionStatus.loggedIn && authenticatedUsername != null) {
      return authenticatedUsername!;
    }
    return 'Guest User';
  }

  UserRole get effectiveUserRole {
    if (status == SessionStatus.loggedIn && authenticatedUserRole != null) {
      return authenticatedUserRole!;
    }
    return UserRole.guest;
  }

  SessionState copyWith({
    SessionStatus? status,
    String? deviceId,
    String? authenticatedUsername,
    UserRole? authenticatedUserRole,
    bool clearAuthenticatedUsername = false,
    bool clearAuthenticatedUserRole = false,
  }) {
    return SessionState(
      status: status ?? this.status,
      deviceId: deviceId ?? this.deviceId,
      authenticatedUsername: clearAuthenticatedUsername
          ? null
          : (authenticatedUsername ?? this.authenticatedUsername),
      authenticatedUserRole: clearAuthenticatedUserRole
          ? null
          : (authenticatedUserRole ?? this.authenticatedUserRole),
    );
  }

  static const SessionState initial = SessionState(
    status: SessionStatus.loggedOut,
    deviceId: 'unknown-device',
  );
}
