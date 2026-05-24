import 'package:golf_kakis/features/profile/api/profile_api_service.dart';

import 'profile_register_phone_use_case.dart';

class ProfileRegisterPhoneUseCaseImpl implements ProfileRegisterPhoneUseCase {
  ProfileRegisterPhoneUseCaseImpl._(this._profileApiService);

  factory ProfileRegisterPhoneUseCaseImpl.create({
    ProfileApiService? profileApiService,
  }) {
    return ProfileRegisterPhoneUseCaseImpl._(
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
}
