import 'package:golf_kakis/features/foundation/default_values.dart';

class LoginMethodsResponse {
  const LoginMethodsResponse({
    required this.success,
    required this.code,
    required this.message,
    required this.accountState,
    required this.methods,
  });

  final bool success;
  final String code;
  final String message;
  final String accountState;
  final List<String> methods;

  bool get hasPin => methods.contains('pin');
  bool get hasPasskey => methods.contains('passkey');
  bool get hasOTPFallback => methods.contains('otp_fallback');

  factory LoginMethodsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final dataJson = data is Map<String, dynamic>
        ? data
        : const <String, dynamic>{};
    final methods = dataJson['methods'];

    return LoginMethodsResponse(
      success: json['success'] as bool? ?? false,
      code: (json['code'] as String?).getValueOrEmpty(),
      message: (json['message'] as String?).getValueOrEmpty(),
      accountState: (dataJson['accountState'] as String?).getValueOrEmpty(),
      methods: methods is List
          ? methods
                .whereType<String>()
                .map((method) => method.trim())
                .where((method) => method.isNotEmpty)
                .toList()
          : const <String>[],
    );
  }
}
