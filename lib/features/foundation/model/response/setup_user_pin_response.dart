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
    final payload = _payload(json);
    final session = payload['session'];
    final user = payload['user'];
    if (session is! Map<String, dynamic> || user is! Map<String, dynamic>) {
      throw ApiException(
        statusCode: 500,
        message: 'PIN setup response is missing session or user data.',
      );
    }

    return SetupUserPinResponse(
      accessToken: (payload['accessToken'] as String?).getValueOrEmpty(),
      refreshToken: (payload['refreshToken'] as String?).getValueOrEmpty(),
      session: AuthSession.fromJson(session),
      user: PinSetupUser.fromJson(user),
      nextAction: (payload['nextAction'] as String?).getValueOrEmpty(),
    );
  }

  static Map<String, dynamic> _payload(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }
    return json;
  }
}
