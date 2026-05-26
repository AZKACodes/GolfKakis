import 'package:golf_kakis/features/foundation/model/response/register_otp_verify_response.dart';
import 'package:golf_kakis/features/foundation/model/response/send_whatsapp_otp_response.dart';

abstract class ProfileOtpUseCase {
  Future<SendWhatsAppOtpResponse> sendWhatsAppOtp({
    required String name,
    required String phoneNumber,
    required String purpose,
    required String visitorId,
    required String captchaToken,
  });

  Future<RegisterOtpVerifyResponse> verifyRegisterOtp({
    required String name,
    required String phoneNumber,
    required String purpose,
    required bool includeVisitorId,
    required String otpCode,
    required String visitorId,
  });
}
