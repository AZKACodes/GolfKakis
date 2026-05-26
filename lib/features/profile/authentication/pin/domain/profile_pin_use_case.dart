import 'package:golf_kakis/features/foundation/model/response/setup_user_pin_response.dart';

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
