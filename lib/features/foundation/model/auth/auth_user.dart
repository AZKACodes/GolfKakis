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
      userId: (json['userId'] as String? ?? json['user_id'] as String?)
          .getValueOrEmpty(),
      authId: json['authId'] as String? ?? json['auth_id'] as String?,
      name: (json['name'] as String?).getValueOrEmpty(),
      username: (json['username'] as String?).getValueOrEmpty(),
      gender: (json['gender'] as String?).getValueOrEmpty(),
      dateOfBirth:
          (json['dateOfBirth'] as String? ??
                  json['date_of_birth'] as String? ??
                  json['dob'] as String?)
              .getValueOrEmpty(),
      email: (json['email'] as String?).getValueOrEmpty(),
      phoneNumber:
          (json['phoneNumber'] as String? ?? json['phone_number'] as String?)
              .getValueOrEmpty(),
      isPhoneVerified:
          (json['isPhoneVerified'] as bool? ??
                  json['is_phone_verified'] as bool?)
              .getValueOrFalse(),
      avatarUrl:
          json['avatar_url'] as String? ??
          json['avatarUrl'] as String? ??
          json['profilePictureUrl'] as String? ??
          json['profile_picture_url'] as String?,
      createdAt: (json['createdAt'] as String? ?? json['created_at'] as String?)
          .getValueOrEmpty(),
      updatedAt: (json['updatedAt'] as String? ?? json['updated_at'] as String?)
          .getValueOrEmpty(),
    );
  }
}
