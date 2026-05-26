import 'package:golf_kakis/features/foundation/default_values.dart';

class RegisterOtpVerifyResponse {
  const RegisterOtpVerifyResponse({
    required this.success,
    required this.code,
    required this.message,
    required this.nextAction,
    required this.pinSetupToken,
  });

  final bool success;
  final String code;
  final String message;
  final String nextAction;
  final String pinSetupToken;

  factory RegisterOtpVerifyResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final dataJson = data is Map<String, dynamic>
        ? data
        : const <String, dynamic>{};

    return RegisterOtpVerifyResponse(
      success: json['success'] as bool? ?? false,
      code: (json['code'] as String?).getValueOrEmpty(),
      message: (json['message'] as String?).getValueOrEmpty(),
      nextAction: (dataJson['nextAction'] as String?).getValueOrEmpty(),
      pinSetupToken: (dataJson['pinSetupToken'] as String?).getValueOrEmpty(),
    );
  }
}
