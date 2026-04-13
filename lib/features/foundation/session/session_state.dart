import '../enums/session/session_status.dart';
import '../enums/session/user_role.dart';
import 'session_visitor.dart';

class SessionState {
  const SessionState({
    required this.status,
    required this.deviceId,
    this.accessToken,
    this.authUserId,
    this.authId,
    this.isPhoneVerified,
    this.authCreatedAt,
    this.authUpdatedAt,
    this.authenticatedUsername,
    this.authenticatedUserRole,
    this.profileFullName,
    this.profileNickname,
    this.profileOccupation,
    this.profileEmail,
    this.profilePhoneNumber,
    this.profileAvatarIndex,
    this.visitor,
  });

  final SessionStatus status;
  final String deviceId;
  final String? accessToken;
  final String? authUserId;
  final String? authId;
  final bool? isPhoneVerified;
  final String? authCreatedAt;
  final String? authUpdatedAt;
  final String? authenticatedUsername;
  final UserRole? authenticatedUserRole;
  final String? profileFullName;
  final String? profileNickname;
  final String? profileOccupation;
  final String? profileEmail;
  final String? profilePhoneNumber;
  final int? profileAvatarIndex;
  final SessionVisitor? visitor;

  bool get isLoggedIn => status == SessionStatus.loggedIn;

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
    String? accessToken,
    String? authUserId,
    String? authId,
    bool? isPhoneVerified,
    String? authCreatedAt,
    String? authUpdatedAt,
    String? authenticatedUsername,
    UserRole? authenticatedUserRole,
    String? profileFullName,
    String? profileNickname,
    String? profileOccupation,
    String? profileEmail,
    String? profilePhoneNumber,
    int? profileAvatarIndex,
    SessionVisitor? visitor,
    bool clearAuthenticatedUsername = false,
    bool clearAuthenticatedUserRole = false,
    bool clearAuthSession = false,
    bool clearProfileDetails = false,
    bool clearVisitor = false,
  }) {
    return SessionState(
      status: status ?? this.status,
      deviceId: deviceId ?? this.deviceId,
      accessToken: clearAuthSession ? null : (accessToken ?? this.accessToken),
      authUserId: clearAuthSession ? null : (authUserId ?? this.authUserId),
      authId: clearAuthSession ? null : (authId ?? this.authId),
      isPhoneVerified: clearAuthSession
          ? null
          : (isPhoneVerified ?? this.isPhoneVerified),
      authCreatedAt: clearAuthSession
          ? null
          : (authCreatedAt ?? this.authCreatedAt),
      authUpdatedAt: clearAuthSession
          ? null
          : (authUpdatedAt ?? this.authUpdatedAt),
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
      visitor: clearVisitor ? null : (visitor ?? this.visitor),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'status': status.name,
      'deviceId': deviceId,
      'accessToken': accessToken,
      'authUserId': authUserId,
      'authId': authId,
      'isPhoneVerified': isPhoneVerified,
      'authCreatedAt': authCreatedAt,
      'authUpdatedAt': authUpdatedAt,
      'authenticatedUsername': authenticatedUsername,
      'authenticatedUserRole': authenticatedUserRole?.name,
      'profileFullName': profileFullName,
      'profileNickname': profileNickname,
      'profileOccupation': profileOccupation,
      'profileEmail': profileEmail,
      'profilePhoneNumber': profilePhoneNumber,
      'profileAvatarIndex': profileAvatarIndex,
      'visitor': visitor?.toJson(),
    };
  }

  factory SessionState.fromJson(Map<String, dynamic> json) {
    return SessionState(
      status: _sessionStatusFromName(json['status'] as String?),
      deviceId: json['deviceId'] as String? ?? SessionState.initial.deviceId,
      accessToken: json['accessToken'] as String?,
      authUserId: json['authUserId'] as String?,
      authId: json['authId'] as String?,
      isPhoneVerified: json['isPhoneVerified'] as bool?,
      authCreatedAt: json['authCreatedAt'] as String?,
      authUpdatedAt: json['authUpdatedAt'] as String?,
      authenticatedUsername: json['authenticatedUsername'] as String?,
      authenticatedUserRole: _userRoleFromName(
        json['authenticatedUserRole'] as String?,
      ),
      profileFullName: json['profileFullName'] as String?,
      profileNickname: json['profileNickname'] as String?,
      profileOccupation: json['profileOccupation'] as String?,
      profileEmail: json['profileEmail'] as String?,
      profilePhoneNumber: json['profilePhoneNumber'] as String?,
      profileAvatarIndex: json['profileAvatarIndex'] as int?,
      visitor: _visitorFromJson(json['visitor']),
    );
  }

  static SessionStatus _sessionStatusFromName(String? name) {
    if (name == null || name.isEmpty) {
      return SessionStatus.loggedOut;
    }

    for (final status in SessionStatus.values) {
      if (status.name == name) {
        return status;
      }
    }

    return SessionStatus.loggedOut;
  }

  static UserRole? _userRoleFromName(String? name) {
    if (name == null || name.isEmpty) {
      return null;
    }

    for (final role in UserRole.values) {
      if (role.name == name) {
        return role;
      }
    }

    return null;
  }

  static SessionVisitor? _visitorFromJson(dynamic value) {
    if (value is Map) {
      return SessionVisitor.fromJson(Map<String, dynamic>.from(value));
    }
    return null;
  }

  static const SessionState initial = SessionState(
    status: SessionStatus.loggedOut,
    deviceId: 'unknown-device',
  );
}
