import 'package:golf_kakis/features/profile/api/profile_api_service.dart';

abstract class ProfilePinUseCase {
  Future<SetupUserPinResponse> setupUserPin({
    required String pinSetupToken,
    required String pin,
    required String confirmPin,
  });

  Future<SetupUserPinResponse> loginViaPin({
    required String phoneNumber,
    required String pin,
  });
}
