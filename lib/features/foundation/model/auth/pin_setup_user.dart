import 'package:golf_kakis/features/foundation/default_values.dart';

class PinSetupUser {
  const PinSetupUser({
    required this.userId,
    required this.authId,
    required this.name,
    required this.username,
    required this.phoneNumber,
    required this.roleName,
    required this.isPhoneVerified,
    required this.accountStatus,
    required this.preferredAuthMethod,
    required this.hasPin,
    required this.hasPasskey,
    required this.createdAt,
    required this.updatedAt,
  });

  final String userId;
  final String authId;
  final String name;
  final String username;
  final String phoneNumber;
  final String roleName;
  final bool isPhoneVerified;
  final String accountStatus;
  final String preferredAuthMethod;
  final bool hasPin;
  final bool hasPasskey;
  final String createdAt;
  final String updatedAt;

  factory PinSetupUser.fromJson(Map<String, dynamic> json) {
    return PinSetupUser(
      userId: (json['userId'] as String?).getValueOrEmpty(),
      authId: (json['authId'] as String?).getValueOrEmpty(),
      name: (json['name'] as String?).getValueOrEmpty(),
      username: (json['username'] as String?).getValueOrEmpty(),
      phoneNumber: (json['phoneNumber'] as String?).getValueOrEmpty(),
      roleName: (json['roleName'] as String?).getValueOrEmpty(),
      isPhoneVerified: (json['isPhoneVerified'] as bool?).getValueOrFalse(),
      accountStatus: (json['accountStatus'] as String?).getValueOrEmpty(),
      preferredAuthMethod: (json['preferredAuthMethod'] as String?)
          .getValueOrEmpty(),
      hasPin: (json['hasPin'] as bool?).getValueOrFalse(),
      hasPasskey: (json['hasPasskey'] as bool?).getValueOrFalse(),
      createdAt: (json['createdAt'] as String?).getValueOrEmpty(),
      updatedAt: (json['updatedAt'] as String?).getValueOrEmpty(),
    );
  }
}
