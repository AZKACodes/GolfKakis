import 'package:golf_kakis/features/foundation/model/response/setup_user_pin_response.dart';
import 'package:golf_kakis/features/profile/api/profile_api_service.dart';

import 'profile_pin_use_case.dart';

class ProfilePinUseCaseImpl implements ProfilePinUseCase {
  ProfilePinUseCaseImpl._(this._profileApiService);

  factory ProfilePinUseCaseImpl.create({ProfileApiService? profileApiService}) {
    return ProfilePinUseCaseImpl._(profileApiService ?? ProfileApiService());
  }

  final ProfileApiService _profileApiService;

  @override
  Future<SetupUserPinResponse> setupUserPin({
    required String pinSetupToken,
    required String pin,
    required String confirmPin,
  }) async {
    return _profileApiService.onSetupUserPin(
      pinSetupToken: pinSetupToken,
      pin: pin,
      confirmPin: confirmPin,
    );
  }

  @override
  Future<SetupUserPinResponse> loginViaPin({
    required String phoneNumber,
    required String pin,
  }) async {
    return _profileApiService.onLoginViaPin(
      phoneNumber: phoneNumber.trim(),
      pin: pin,
    );
  }
}
