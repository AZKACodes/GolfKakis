import 'package:golf_kakis/features/profile/api/profile_api_service.dart';

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
