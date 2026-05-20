import 'package:golf_kakis/features/profile/api/profile_api_service.dart';

abstract class ProfileRegisterUseCase {
  Future<RequestOtpResponse> requestOtp({
    required String username,
    required String password,
    required String phoneNumber,
    required String visitorId,
  });

  Future<SendWhatsAppOtpResponse> sendWhatsAppOtp({
    required String name,
    required String phoneNumber,
    required String purpose,
    required String visitorId,
    required String captchaToken,
  });

  Future<VerifyOtpResponse> verifyOtp({
    required String username,
    required String phoneNumber,
    required String otp,
    required String visitorId,
  });

  Future<RegisterOtpVerifyResponse> verifyRegisterOtp({
    required String name,
    required String phoneNumber,
    required String purpose,
    required bool includeVisitorId,
    required String otpCode,
    required String visitorId,
  });

  Future<SetupUserPinResponse> setupUserPin({
    required String pinSetupToken,
    required String pin,
    required String confirmPin,
  });

  Future<SetupUserPinResponse> loginViaPin({
    required String phoneNumber,
    required String pin,
  });
}
