abstract class CaptchaTokenProvider {
  Future<String> execute(CaptchaTokenAction action);
}

enum CaptchaTokenAction {
  requestOtp('request_otp');

  const CaptchaTokenAction(this.value);

  final String value;
}

class CaptchaTokenException implements Exception {
  const CaptchaTokenException(this.message);

  final String message;

  @override
  String toString() => message;
}
