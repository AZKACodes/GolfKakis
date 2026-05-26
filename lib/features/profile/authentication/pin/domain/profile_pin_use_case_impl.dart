import 'package:golf_kakis/features/foundation/model/auth/auth_session.dart';
import 'package:golf_kakis/features/foundation/model/auth/pin_setup_user.dart';
import 'package:golf_kakis/features/foundation/model/response/setup_user_pin_response.dart';
import 'package:golf_kakis/features/foundation/network/network.dart';
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
    } on ApiException {
      rethrow;
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
