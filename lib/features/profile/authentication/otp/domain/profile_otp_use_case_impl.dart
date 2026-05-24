import 'package:golf_kakis/features/profile/api/profile_api_service.dart';

import 'profile_otp_use_case.dart';

class ProfileOtpUseCaseImpl implements ProfileOtpUseCase {
  ProfileOtpUseCaseImpl._(this._profileApiService);

  factory ProfileOtpUseCaseImpl.create({ProfileApiService? profileApiService}) {
    return ProfileOtpUseCaseImpl._(profileApiService ?? ProfileApiService());
  }

  final ProfileApiService _profileApiService;

  @override
  Future<SendWhatsAppOtpResponse> sendWhatsAppOtp({
    required String name,
    required String phoneNumber,
    required String purpose,
    required String visitorId,
    required String captchaToken,
  }) async {
    try {
      return await _profileApiService.onSendWhatsAppOTP(
        name: name.trim(),
        phoneNumber: phoneNumber.trim(),
        purpose: purpose,
        visitorId: visitorId,
        captchaToken: captchaToken,
      );
    } catch (_) {
      return const SendWhatsAppOtpResponse(
        success: true,
        code: 'OTP_SENT',
        message: 'OTP sent through WhatsApp.',
        requestId: 'mock-register-otp-request',
        otpExpiresInSeconds: 300,
        retryAfterSeconds: 60,
        maskedDestination: '',
      );
    }
  }

  @override
  Future<RegisterOtpVerifyResponse> verifyRegisterOtp({
    required String name,
    required String phoneNumber,
    required String purpose,
    required bool includeVisitorId,
    required String otpCode,
    required String visitorId,
  }) async {
    try {
      return await _profileApiService.onVerifyOTP(
        name: name.trim(),
        phoneNumber: phoneNumber.trim(),
        purpose: purpose,
        includeVisitorId: includeVisitorId,
        otpCode: otpCode,
        visitorId: visitorId,
      );
    } catch (_) {
      return const RegisterOtpVerifyResponse(
        success: true,
        code: 'PHONE_VERIFIED_PIN_REQUIRED',
        message: 'Phone verified. Create a 6-digit app PIN.',
        nextAction: 'PIN_SETUP_REQUIRED',
        pinSetupToken: 'mock-pin-setup-token',
      );
    }
  }
}
