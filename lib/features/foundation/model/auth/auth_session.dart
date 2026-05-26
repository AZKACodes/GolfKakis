import 'package:golf_kakis/features/foundation/default_values.dart';

class AuthSession {
  const AuthSession({
    required this.sessionId,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresInSeconds,
    required this.refreshExpiresAt,
  });

  final String sessionId;
  final String accessToken;
  final String refreshToken;
  final int expiresInSeconds;
  final String refreshExpiresAt;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      sessionId: (json['sessionId'] as String?).getValueOrEmpty(),
      accessToken: (json['accessToken'] as String?).getValueOrEmpty(),
      refreshToken: (json['refreshToken'] as String?).getValueOrEmpty(),
      expiresInSeconds: json['expiresInSeconds'] as int? ?? 0,
      refreshExpiresAt: (json['refreshExpiresAt'] as String?).getValueOrEmpty(),
    );
  }
}
