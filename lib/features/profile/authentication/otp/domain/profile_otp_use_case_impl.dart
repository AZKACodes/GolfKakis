import 'package:golf_kakis/features/foundation/model/response/register_otp_verify_response.dart';
import 'package:golf_kakis/features/foundation/model/response/send_whatsapp_otp_response.dart';
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
    return _profileApiService.onSendWhatsAppOTP(
      name: name.trim(),
      phoneNumber: phoneNumber.trim(),
      purpose: purpose,
      visitorId: visitorId,
      captchaToken: captchaToken,
    );
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
    return _profileApiService.onVerifyOTP(
      name: name.trim(),
      phoneNumber: phoneNumber.trim(),
      purpose: purpose,
      includeVisitorId: includeVisitorId,
      otpCode: otpCode,
      visitorId: visitorId,
    );
  }
}
