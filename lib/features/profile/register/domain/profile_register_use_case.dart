import 'package:golf_kakis/features/profile/api/profile_api_service.dart';

abstract class ProfileRegisterUseCase {
  Future<RequestOtpResponse> requestOtp({
    required String username,
    required String password,
    required String phoneNumber,
    required String visitorId,
  });

  Future<VerifyOtpResponse> verifyOtp({
    required String username,
    required String phoneNumber,
    required String otp,
    required String visitorId,
  });
}
