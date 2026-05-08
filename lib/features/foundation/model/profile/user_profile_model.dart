import 'package:golf_kakis/features/foundation/enums/session/user_role.dart';

class UserProfileModel {
  const UserProfileModel({
    required this.userId,
    required this.userSlug,
    required this.displayName,
    required this.nickname,
    required this.occupation,
    required this.email,
    required this.phoneNumber,
    int? avatarIndex,
    this.avatarImagePath,
    required this.role,
    required this.membershipLabel,
    required this.isLoggedIn,
  }) : _avatarIndex = avatarIndex;

  final String userId;
  final String userSlug;
  final String displayName;
  final String nickname;
  final String occupation;
  final String email;
  final String phoneNumber;
  final int? _avatarIndex;
  final String? avatarImagePath;
  final UserRole role;
  final String membershipLabel;
  final bool isLoggedIn;

  int get avatarIndex => _avatarIndex ?? 0;

  bool get isGuest => role == UserRole.guest;
  bool get isUser => role == UserRole.user;
  bool get isAgent => role == UserRole.agent;
  bool get isAdmin => role == UserRole.admin;

  UserProfileModel copyWith({
    String? userId,
    String? userSlug,
    String? displayName,
    String? nickname,
    String? occupation,
    String? email,
    String? phoneNumber,
    int? avatarIndex,
    String? avatarImagePath,
    UserRole? role,
    String? membershipLabel,
    bool? isLoggedIn,
  }) {
    return UserProfileModel(
      userId: userId ?? this.userId,
      userSlug: userSlug ?? this.userSlug,
      displayName: displayName ?? this.displayName,
      nickname: nickname ?? this.nickname,
      occupation: occupation ?? this.occupation,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarIndex: avatarIndex ?? this.avatarIndex,
      avatarImagePath: avatarImagePath ?? this.avatarImagePath,
      role: role ?? this.role,
      membershipLabel: membershipLabel ?? this.membershipLabel,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }

  String get roleLabel {
    switch (role) {
      case UserRole.guest:
        return 'Guest';
      case UserRole.user:
        return 'User';
      case UserRole.agent:
        return 'Agent';
      case UserRole.admin:
        return 'Admin';
    }
  }

  String get initials {
    final parts = displayName
        .split(' ')
        .where((part) => part.trim().isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return 'U';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}
