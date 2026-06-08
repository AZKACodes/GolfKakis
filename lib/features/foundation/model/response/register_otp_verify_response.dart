import 'package:golf_kakis/features/foundation/default_values.dart';
import 'package:golf_kakis/features/foundation/model/auth/auth_session.dart';
import 'package:golf_kakis/features/foundation/model/auth/pin_setup_user.dart';

class RegisterOtpVerifyResponse {
  const RegisterOtpVerifyResponse({
    required this.success,
    required this.code,
    required this.message,
    required this.nextAction,
    required this.pinSetupToken,
    this.accessToken = emptyString,
    this.refreshToken = emptyString,
    this.session,
    this.user,
  });

  final bool success;
  final String code;
  final String message;
  final String nextAction;
  final String pinSetupToken;
  final String accessToken;
  final String refreshToken;
  final AuthSession? session;
  final PinSetupUser? user;

  bool get hasSessionDetails {
    final resolvedAccessToken = session?.accessToken ?? accessToken;
    final resolvedRefreshToken = session?.refreshToken ?? refreshToken;
    return resolvedAccessToken.isNotEmpty && resolvedRefreshToken.isNotEmpty;
  }

  factory RegisterOtpVerifyResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final dataJson = data is Map<String, dynamic>
        ? data
        : const <String, dynamic>{};
    final sessionJson =
        _readMap(dataJson['session']) ?? _readMap(json['session']);
    final userJson = _readMap(dataJson['user']) ?? _readMap(json['user']);

    return RegisterOtpVerifyResponse(
      success: json['success'] as bool? ?? false,
      code: (json['code'] as String?).getValueOrEmpty(),
      message: (json['message'] as String?).getValueOrEmpty(),
      nextAction: (dataJson['nextAction'] as String?).getValueOrEmpty(),
      pinSetupToken: (dataJson['pinSetupToken'] as String?).getValueOrEmpty(),
      accessToken:
          (dataJson['accessToken'] as String? ?? json['accessToken'] as String?)
              .getValueOrEmpty(),
      refreshToken:
          (dataJson['refreshToken'] as String? ??
                  json['refreshToken'] as String?)
              .getValueOrEmpty(),
      session: sessionJson == null ? null : AuthSession.fromJson(sessionJson),
      user: userJson == null ? null : PinSetupUser.fromJson(userJson),
    );
  }

  static Map<String, dynamic>? _readMap(dynamic value) {
    return value is Map<String, dynamic> ? value : null;
  }
}
