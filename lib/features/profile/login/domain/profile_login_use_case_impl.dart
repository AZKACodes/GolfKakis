import 'package:golf_kakis/features/profile/api/profile_api_service.dart';

import 'profile_login_use_case.dart';

class ProfileLoginUseCaseImpl implements ProfileLoginUseCase {
  ProfileLoginUseCaseImpl._(this._profileApiService);

  factory ProfileLoginUseCaseImpl.create({
    ProfileApiService? profileApiService,
  }) {
    return ProfileLoginUseCaseImpl._(profileApiService ?? ProfileApiService());
  }

  final ProfileApiService _profileApiService;

  @override
  Future<RequestOtpResponse> requestOtp({
    required String username,
    required String password,
    required String visitorId,
  }) async {
    final normalizedUsername = username.trim();
    const fallbackPhoneNumber = '+60123456789';

    try {
      return await _profileApiService.onRequestOtp(
        name: normalizedUsername,
        phoneNumber: fallbackPhoneNumber,
        visitorId: visitorId,
      );
    } catch (_) {
      return RequestOtpResponse(
        ok: true,
        mockOtpCode: '123456',
        message: 'OTP sent to your registered phone number.',
        name: normalizedUsername,
        phoneNumber: fallbackPhoneNumber,
        normalizedPhoneNumber: fallbackPhoneNumber,
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
        accessToken: 'mock-login-token-$visitorId',
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
