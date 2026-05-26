import 'package:golf_kakis/features/foundation/default_values.dart';

class AuthUser {
  const AuthUser({
    required this.userId,
    required this.authId,
    required this.name,
    required this.username,
    required this.gender,
    required this.dateOfBirth,
    required this.email,
    required this.phoneNumber,
    required this.isPhoneVerified,
    required this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  final String userId;
  final String? authId;
  final String name;
  final String username;
  final String gender;
  final String dateOfBirth;
  final String email;
  final String phoneNumber;
  final bool isPhoneVerified;
  final String? avatarUrl;
  final String createdAt;
  final String updatedAt;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      userId: (json['userId'] as String?).getValueOrEmpty(),
      authId: json['authId'] as String?,
      name: (json['name'] as String?).getValueOrEmpty(),
      username: (json['username'] as String?).getValueOrEmpty(),
      gender: (json['gender'] as String?).getValueOrEmpty(),
      dateOfBirth: (json['dateOfBirth'] as String?).getValueOrEmpty().isNotEmpty
          ? (json['dateOfBirth'] as String?).getValueOrEmpty()
          : (json['dob'] as String?).getValueOrEmpty(),
      email: (json['email'] as String?).getValueOrEmpty(),
      phoneNumber: (json['phoneNumber'] as String?).getValueOrEmpty(),
      isPhoneVerified: (json['isPhoneVerified'] as bool?).getValueOrFalse(),
      avatarUrl: json['avatar_url'] as String? ?? json['avatarUrl'] as String?,
      createdAt: (json['createdAt'] as String?).getValueOrEmpty(),
      updatedAt: (json['updatedAt'] as String?).getValueOrEmpty(),
    );
  }
}
