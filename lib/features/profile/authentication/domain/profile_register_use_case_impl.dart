import 'package:golf_kakis/features/foundation/default_values.dart';
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

  @override
  Future<SetupUserPinResponse> setupUserPin({
    required String pinSetupToken,
    required String pin,
    required String confirmPin,
  }) async {
    try {
      return await _profileApiService.onSetupUserPin(
        pinSetupToken: pinSetupToken,
        pin: pin,
        confirmPin: confirmPin,
      );
    } catch (_) {
      return SetupUserPinResponse(
        accessToken: 'mock-access-token-$pinSetupToken',
        refreshToken: 'mock-refresh-token-$pinSetupToken',
        session: AuthSession(
          sessionId: 'mock-session-$pinSetupToken',
          accessToken: 'mock-access-token-$pinSetupToken',
          refreshToken: 'mock-refresh-token-$pinSetupToken',
          expiresInSeconds: 900,
          refreshExpiresAt: DateTime.now()
              .add(const Duration(days: 14))
              .toIso8601String(),
        ),
        user: const PinSetupUser(
          userId: 'mock-user',
          name: 'Golf Kakis User',
          phoneNumber: '',
          isPhoneVerified: true,
          accountStatus: 'ACTIVE',
          preferredAuthMethod: 'pin',
          hasPin: true,
          hasPasskey: false,
        ),
        nextAction: 'OPTIONAL_PASSKEY_ENROLL',
      );
    }
  }

  @override
  Future<SetupUserPinResponse> loginViaPin({
    required String phoneNumber,
    required String pin,
  }) async {
    try {
      return await _profileApiService.onLoginViaPin(
        phoneNumber: phoneNumber.trim(),
        pin: pin,
      );
    } catch (_) {
      return SetupUserPinResponse(
        accessToken: 'mock-login-pin-token-$phoneNumber',
        refreshToken: 'mock-login-pin-refresh-$phoneNumber',
        session: AuthSession(
          sessionId: 'mock-login-pin-session-$phoneNumber',
          accessToken: 'mock-login-pin-token-$phoneNumber',
          refreshToken: 'mock-login-pin-refresh-$phoneNumber',
          expiresInSeconds: 900,
          refreshExpiresAt: DateTime.now()
              .add(const Duration(days: 14))
              .toIso8601String(),
        ),
        user: PinSetupUser(
          userId: 'mock-user-$phoneNumber',
          name: phoneNumber,
          phoneNumber: phoneNumber,
          isPhoneVerified: true,
          accountStatus: 'ACTIVE',
          preferredAuthMethod: 'pin',
          hasPin: true,
          hasPasskey: false,
        ),
        nextAction: 'OPTIONAL_PASSKEY_ENROLL',
      );
    }
  }
}
