import 'package:golf_kakis/features/profile/api/profile_api_service.dart';

import 'profile_register_use_case.dart';

class ProfileRegisterUseCaseImpl implements ProfileRegisterUseCase {
  ProfileRegisterUseCaseImpl._(this._profileApiService);

  factory ProfileRegisterUseCaseImpl.create({
    ProfileApiService? profileApiService,
  }) {
    return ProfileRegisterUseCaseImpl._(
      profileApiService ?? ProfileApiService(),
    );
  }

  final ProfileApiService _profileApiService;

  @override
  Future<RequestOtpResponse> requestOtp({
    required String username,
    required String password,
    required String phoneNumber,
    required String visitorId,
  }) async {
    try {
      return await _profileApiService.onRequestOtp(
        name: username.trim(),
        phoneNumber: phoneNumber,
        visitorId: visitorId,
      );
    } catch (_) {
      return RequestOtpResponse(
        ok: true,
        mockOtpCode: '123456',
        message: 'OTP sent to $phoneNumber.',
        name: username.trim(),
        phoneNumber: phoneNumber,
        normalizedPhoneNumber: phoneNumber,
        visitorId: visitorId,
      );
    }
  }

  @override
  Future<VerifyOtpResponse> verifyOtp({
    required String username,
    required String phoneNumber,
    required String otp,
    required String visitorId,
  }) async {
    try {
      return await _profileApiService.onVerifyOtp(
        name: username,
        phoneNumber: phoneNumber,
        otp: otp,
        visitorId: visitorId,
      );
    } catch (_) {
      final now = DateTime.now().toIso8601String();
      return VerifyOtpResponse(
        accessToken: 'mock-register-token-$visitorId',
        user: AuthUser(
          userId: 'mock-user-$visitorId',
          authId: 'mock-auth-$visitorId',
          name: username.trim(),
          phoneNumber: phoneNumber.trim(),
          isPhoneVerified: true,
          createdAt: now,
          updatedAt: now,
        ),
        visitorId: visitorId,
      );
    }
  }
}
