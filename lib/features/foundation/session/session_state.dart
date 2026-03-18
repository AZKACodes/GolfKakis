import '../enums/session/session_status.dart';
import '../enums/session/user_role.dart';

class SessionState {
  const SessionState({
    required this.status,
    required this.deviceId,
    this.authenticatedUsername,
    this.authenticatedUserRole,
    this.profileFullName,
    this.profileNickname,
    this.profileOccupation,
    this.profileEmail,
    this.profilePhoneNumber,
    this.profileAvatarIndex,
  });

  final SessionStatus status;
  final String deviceId;
  final String? authenticatedUsername;
  final UserRole? authenticatedUserRole;
  final String? profileFullName;
  final String? profileNickname;
  final String? profileOccupation;
  final String? profileEmail;
  final String? profilePhoneNumber;
  final int? profileAvatarIndex;

  String get effectiveUsername {
    if (status == SessionStatus.loggedIn && profileFullName != null) {
      return profileFullName!;
    }
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
    String? profileFullName,
    String? profileNickname,
    String? profileOccupation,
    String? profileEmail,
    String? profilePhoneNumber,
    int? profileAvatarIndex,
    bool clearAuthenticatedUsername = false,
    bool clearAuthenticatedUserRole = false,
    bool clearProfileDetails = false,
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
      profileFullName: clearProfileDetails
          ? null
          : (profileFullName ?? this.profileFullName),
      profileNickname: clearProfileDetails
          ? null
          : (profileNickname ?? this.profileNickname),
      profileOccupation: clearProfileDetails
          ? null
          : (profileOccupation ?? this.profileOccupation),
      profileEmail: clearProfileDetails
          ? null
          : (profileEmail ?? this.profileEmail),
      profilePhoneNumber: clearProfileDetails
          ? null
          : (profilePhoneNumber ?? this.profilePhoneNumber),
      profileAvatarIndex: clearProfileDetails
          ? null
          : (profileAvatarIndex ?? this.profileAvatarIndex),
    );
  }

  static const SessionState initial = SessionState(
    status: SessionStatus.loggedOut,
    deviceId: 'unknown-device',
  );
}
