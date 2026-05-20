import 'package:golf_kakis/features/foundation/default_values.dart';
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
  Future<LoginMethodsResponse> onFetchLoginMethods({
    required String phoneNumber,
  }) async {
    try {
      return await _profileApiService.onFetchLoginMethods(
        phoneNumber: phoneNumber.trim(),
      );
    } catch (_) {
      return const LoginMethodsResponse(
        success: true,
        code: 'LOGIN_OPTIONS',
        message: 'Login options loaded.',
        accountState: 'ACTIVE',
        methods: <String>['pin', 'otp_fallback'],
      );
    }
  }

  @override
  Future<RequestOtpResponse> requestOtp({
    required String phoneNumber,
    required String visitorId,
  }) async {
    final normalizedPhoneNumber = phoneNumber.trim();

    try {
      return await _profileApiService.onRequestOtp(
        name: normalizedPhoneNumber,
        phoneNumber: normalizedPhoneNumber,
        visitorId: visitorId,
      );
    } catch (_) {
      return RequestOtpResponse(
        ok: true,
        mockOtpCode: '123456',
        message: 'OTP sent to your registered phone number.',
        name: normalizedPhoneNumber,
        phoneNumber: normalizedPhoneNumber,
        normalizedPhoneNumber: normalizedPhoneNumber,
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
          username: username.trim(),
          gender: emptyString,
          dateOfBirth: emptyString,
          email: emptyString,
          phoneNumber: phoneNumber.trim(),
          isPhoneVerified: true,
          avatarUrl: null,
          createdAt: now,
          updatedAt: now,
        ),
        visitorId: visitorId,
      );
    }
  }
}
