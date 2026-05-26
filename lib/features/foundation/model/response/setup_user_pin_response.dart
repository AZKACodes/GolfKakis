import 'package:golf_kakis/features/foundation/default_values.dart';
import 'package:golf_kakis/features/foundation/model/auth/auth_session.dart';
import 'package:golf_kakis/features/foundation/model/auth/pin_setup_user.dart';
import 'package:golf_kakis/features/foundation/network/network.dart';

class SetupUserPinResponse {
  const SetupUserPinResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.session,
    required this.user,
    required this.nextAction,
  });

  final String accessToken;
  final String refreshToken;
  final AuthSession session;
  final PinSetupUser user;
  final String nextAction;

  factory SetupUserPinResponse.fromJson(Map<String, dynamic> json) {
    final session = json['session'];
    final user = json['user'];
    if (session is! Map<String, dynamic> || user is! Map<String, dynamic>) {
      throw ApiException(
        statusCode: 500,
        message: 'PIN setup response is missing session or user data.',
      );
    }

    return SetupUserPinResponse(
      accessToken: (json['accessToken'] as String?).getValueOrEmpty(),
      refreshToken: (json['refreshToken'] as String?).getValueOrEmpty(),
      session: AuthSession.fromJson(session),
      user: PinSetupUser.fromJson(user),
      nextAction: (json['nextAction'] as String?).getValueOrEmpty(),
    );
  }
}
