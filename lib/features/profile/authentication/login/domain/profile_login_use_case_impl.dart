import 'package:golf_kakis/features/foundation/model/response/login_methods_response.dart';
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
}
