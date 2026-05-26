import 'package:golf_kakis/features/foundation/default_values.dart';

class PinSetupUser {
  const PinSetupUser({
    required this.userId,
    required this.name,
    required this.phoneNumber,
    required this.isPhoneVerified,
    required this.accountStatus,
    required this.preferredAuthMethod,
    required this.hasPin,
    required this.hasPasskey,
  });

  final String userId;
  final String name;
  final String phoneNumber;
  final bool isPhoneVerified;
  final String accountStatus;
  final String preferredAuthMethod;
  final bool hasPin;
  final bool hasPasskey;

  factory PinSetupUser.fromJson(Map<String, dynamic> json) {
    return PinSetupUser(
      userId: (json['userId'] as String?).getValueOrEmpty(),
      name: (json['name'] as String?).getValueOrEmpty(),
      phoneNumber: (json['phoneNumber'] as String?).getValueOrEmpty(),
      isPhoneVerified: (json['isPhoneVerified'] as bool?).getValueOrFalse(),
      accountStatus: (json['accountStatus'] as String?).getValueOrEmpty(),
      preferredAuthMethod: (json['preferredAuthMethod'] as String?)
          .getValueOrEmpty(),
      hasPin: (json['hasPin'] as bool?).getValueOrFalse(),
      hasPasskey: (json['hasPasskey'] as bool?).getValueOrFalse(),
    );
  }
}
