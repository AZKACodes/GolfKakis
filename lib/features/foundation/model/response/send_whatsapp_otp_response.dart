import 'package:golf_kakis/features/foundation/default_values.dart';

class SendWhatsAppOtpResponse {
  const SendWhatsAppOtpResponse({
    required this.success,
    required this.code,
    required this.message,
    required this.requestId,
    required this.otpExpiresInSeconds,
    required this.retryAfterSeconds,
    required this.maskedDestination,
  });

  final bool success;
  final String code;
  final String message;
  final String requestId;
  final int otpExpiresInSeconds;
  final int retryAfterSeconds;
  final String maskedDestination;

  factory SendWhatsAppOtpResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final dataJson = data is Map<String, dynamic>
        ? data
        : const <String, dynamic>{};

    return SendWhatsAppOtpResponse(
      success: json['success'] as bool? ?? false,
      code: (json['code'] as String?).getValueOrEmpty(),
      message: (json['message'] as String?).getValueOrEmpty().isNotEmpty
          ? (json['message'] as String?).getValueOrEmpty()
          : 'OTP sent through WhatsApp.',
      requestId: (dataJson['requestId'] as String?).getValueOrEmpty(),
      otpExpiresInSeconds: dataJson['otpExpiresInSeconds'] as int? ?? 0,
      retryAfterSeconds: dataJson['retryAfterSeconds'] as int? ?? 0,
      maskedDestination: (dataJson['maskedDestination'] as String?)
          .getValueOrEmpty(),
    );
  }
}
