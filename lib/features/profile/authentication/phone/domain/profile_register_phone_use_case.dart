import 'package:golf_kakis/features/profile/api/profile_api_service.dart';

abstract class ProfileRegisterPhoneUseCase {
  Future<RequestOtpResponse> requestOtp({
    required String username,
    required String password,
    required String phoneNumber,
    required String visitorId,
  });
}
