import 'package:golf_kakis/features/foundation/enums/session/user_role.dart';

class UserProfileModel {
  const UserProfileModel({
    required this.userId,
    required this.userSlug,
    required this.displayName,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.membershipLabel,
    required this.isLoggedIn,
  });

  final String userId;
  final String userSlug;
  final String displayName;
  final String email;
  final String phoneNumber;
  final UserRole role;
  final String membershipLabel;
  final bool isLoggedIn;

  bool get isGuest => role == UserRole.guest;
  bool get isUser => role == UserRole.user;
  bool get isAgent => role == UserRole.agent;
  bool get isAdmin => role == UserRole.admin;

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
