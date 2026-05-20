import 'package:flutter/foundation.dart';
import 'package:golf_kakis/features/foundation/default_values.dart';
import 'package:golf_kakis/features/foundation/network/network.dart';

class ProfileApiService {
  ProfileApiService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<dynamic> onFetchUserProfile() {
    return _apiClient.getJson('/profile/me');
  }

  Future<AuthUser> onFetchUserDetails({required String accessToken}) async {
    final response = await _apiClient.getJson(
      '/auth/me',
      headers: <String, String>{'Authorization': 'Bearer $accessToken'},
    );
    debugPrint('onFetchUserDetails /auth/me response: $response');

    if (response is! Map<String, dynamic>) {
      throw ApiException(
        statusCode: 500,
        message: 'Fetch user details returned an invalid response.',
      );
    }

    return AuthUser.fromJson(response);
  }

  Future<AuthUser> onUpdateProfile({
    required String accessToken,
    required String name,
    required String username,
    required String gender,
    required String dateOfBirth,
    required String email,
  }) async {
    final response = await _apiClient.patchJson(
      '/auth/me',
      headers: <String, String>{'Authorization': 'Bearer $accessToken'},
      body: <String, dynamic>{
        'name': name,
        'username': username,
        'gender': gender,
        'dateOfBirth': dateOfBirth,
        'email': email,
      },
    );

    if (response is! Map<String, dynamic>) {
      throw ApiException(
        statusCode: 500,
        message: 'Update profile returned an invalid response.',
      );
    }

    final user = response['user'];
    if (user is Map<String, dynamic>) {
      return AuthUser.fromJson(user);
    }

    return AuthUser.fromJson(response);
  }

  Future<String> onUpdateProfilePicture({
    required String accessToken,
    required String imagePath,
  }) async {
    final response = await _apiClient.postMultipart(
      '/auth/me/avatar',
      headers: <String, String>{'Authorization': 'Bearer $accessToken'},
      fields: const <String, String>{},
      files: <MultipartFilePayload>[
        MultipartFilePayload(field: 'file', path: imagePath),
      ],
    );

    if (response is Map<String, dynamic>) {
      final avatarUrl =
          response['avatar_url'] as String? ?? response['avatarUrl'] as String?;
      if (avatarUrl != null && avatarUrl.trim().isNotEmpty) {
        return avatarUrl;
      }
    }

    return emptyString;
  }

  Future<RequestOtpResponse> onRequestOtp({
    required String name,
    required String phoneNumber,
    required String visitorId,
  }) async {
    final response = await _apiClient.postJson(
      '/auth/request-otp',
      body: <String, dynamic>{
        'name': name,
        'phoneNumber': phoneNumber,
        'visitorId': visitorId,
      },
    );

    if (response is! Map<String, dynamic>) {
      throw ApiException(
        statusCode: 500,
        message: 'OTP request returned an invalid response.',
      );
    }

    return RequestOtpResponse.fromJson(response);
  }

  Future<LoginMethodsResponse> onFetchLoginMethods({
    required String phoneNumber,
  }) async {
    final response = await _apiClient.postJson(
      '/api/auth/login/options',
      body: <String, dynamic>{'phoneNumber': phoneNumber},
    );

    if (response is! Map<String, dynamic>) {
      throw ApiException(
        statusCode: 500,
        message: 'Login options returned an invalid response.',
      );
    }

    return LoginMethodsResponse.fromJson(response);
  }

  Future<SendWhatsAppOtpResponse> onSendWhatsAppOTP({
    required String name,
    required String phoneNumber,
    required String purpose,
    required String visitorId,
    required String captchaToken,
  }) async {
    final response = await _apiClient.postJson(
      '/api/auth/otp/send',
      body: <String, dynamic>{
        if (name.trim().isNotEmpty) 'name': name,
        'phoneNumber': phoneNumber,
        'purpose': purpose,
        if (visitorId.trim().isNotEmpty) 'visitorId': visitorId,
        'channel': 'whatsapp',
        'captchaToken': captchaToken,
      },
    );

    if (response is! Map<String, dynamic>) {
      throw ApiException(
        statusCode: 500,
        message: 'WhatsApp OTP request returned an invalid response.',
      );
    }

    return SendWhatsAppOtpResponse.fromJson(response);
  }

  Future<VerifyOtpResponse> onVerifyOtp({
    required String name,
    required String phoneNumber,
    required String otp,
    required String visitorId,
  }) async {
    final response = await _apiClient.postJson(
      '/auth/verify-otp',
      body: <String, dynamic>{
        'name': name,
        'phoneNumber': phoneNumber,
        'otp': otp,
        'visitorId': visitorId,
      },
    );

    if (response is! Map<String, dynamic>) {
      throw ApiException(
        statusCode: 500,
        message: 'OTP verification returned an invalid response.',
      );
    }

    return VerifyOtpResponse.fromJson(response);
  }

  Future<RegisterOtpVerifyResponse> onVerifyOTP({
    required String name,
    required String phoneNumber,
    required String purpose,
    required bool includeVisitorId,
    required String otpCode,
    required String visitorId,
  }) async {
    final response = await _apiClient.postJson(
      '/api/auth/otp/verify',
      body: <String, dynamic>{
        if (name.trim().isNotEmpty && purpose != 'pin_reset') 'name': name,
        'phoneNumber': phoneNumber,
        'purpose': purpose,
        'otpCode': otpCode,
        if (includeVisitorId) 'visitorId': visitorId,
      },
    );

    if (response is! Map<String, dynamic>) {
      throw ApiException(
        statusCode: 500,
        message: 'OTP verification returned an invalid response.',
      );
    }

    return RegisterOtpVerifyResponse.fromJson(response);
  }

  Future<SetupUserPinResponse> onSetupUserPin({
    required String pinSetupToken,
    required String pin,
    required String confirmPin,
  }) async {
    final response = await _apiClient.postJson(
      '/api/auth/pin/setup',
      body: <String, dynamic>{
        'pinSetupToken': pinSetupToken,
        'pin': pin,
        'confirmPin': confirmPin,
      },
    );

    if (response is! Map<String, dynamic>) {
      throw ApiException(
        statusCode: 500,
        message: 'PIN setup returned an invalid response.',
      );
    }

    return SetupUserPinResponse.fromJson(response);
  }

  Future<SetupUserPinResponse> onLoginViaPin({
    required String phoneNumber,
    required String pin,
  }) async {
    final response = await _apiClient.postJson(
      '/api/auth/login/pin',
      body: <String, dynamic>{'phoneNumber': phoneNumber, 'pin': pin},
    );

    if (response is! Map<String, dynamic>) {
      throw ApiException(
        statusCode: 500,
        message: 'PIN login returned an invalid response.',
      );
    }

    return SetupUserPinResponse.fromJson(response);
  }

  Future<String> onDeactivateAccount({
    required String accessToken,
    required String phoneNumber,
  }) async {
    final response = await _apiClient.deleteJson(
      '/auth/me',
      headers: <String, String>{'Authorization': 'Bearer $accessToken'},
      body: <String, dynamic>{'phoneNumber': phoneNumber},
    );

    if (response is Map<String, dynamic>) {
      final message = response['message'] as String?;
      if (message != null && message.trim().isNotEmpty) {
        return message;
      }
    }

    return 'Account deactivated successfully.';
  }
}

class SendWhatsAppOtpResponse {
  const SendWhatsAppOtpResponse({
    required this.success,
    required this.code,
    required this.message,
    required this.requestId,
    required this.otpExpiresInSeconds,
    required this.retryAfterSeconds,
    required this.maskedDestination,
  });

  final bool success;
  final String code;
  final String message;
  final String requestId;
  final int otpExpiresInSeconds;
  final int retryAfterSeconds;
  final String maskedDestination;

  factory SendWhatsAppOtpResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final dataJson = data is Map<String, dynamic>
        ? data
        : const <String, dynamic>{};

    return SendWhatsAppOtpResponse(
      success: json['success'] as bool? ?? false,
      code: (json['code'] as String?).getValueOrEmpty(),
      message: (json['message'] as String?).getValueOrEmpty().isNotEmpty
          ? (json['message'] as String?).getValueOrEmpty()
          : 'OTP sent through WhatsApp.',
      requestId: (dataJson['requestId'] as String?).getValueOrEmpty(),
      otpExpiresInSeconds: dataJson['otpExpiresInSeconds'] as int? ?? 0,
      retryAfterSeconds: dataJson['retryAfterSeconds'] as int? ?? 0,
      maskedDestination: (dataJson['maskedDestination'] as String?)
          .getValueOrEmpty(),
    );
  }
}

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

class RegisterOtpVerifyResponse {
  const RegisterOtpVerifyResponse({
    required this.success,
    required this.code,
    required this.message,
    required this.nextAction,
    required this.pinSetupToken,
  });

  final bool success;
  final String code;
  final String message;
  final String nextAction;
  final String pinSetupToken;

  factory RegisterOtpVerifyResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final dataJson = data is Map<String, dynamic>
        ? data
        : const <String, dynamic>{};

    return RegisterOtpVerifyResponse(
      success: json['success'] as bool? ?? false,
      code: (json['code'] as String?).getValueOrEmpty(),
      message: (json['message'] as String?).getValueOrEmpty(),
      nextAction: (dataJson['nextAction'] as String?).getValueOrEmpty(),
      pinSetupToken: (dataJson['pinSetupToken'] as String?).getValueOrEmpty(),
    );
  }
}

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

class PinSetupUser {
  const PinSetupUser({
    required this.userId,
    required this.name,
    required this.phoneNumber,
    required this.isPhoneVerified,
    required this.accountStatus,
    required this.preferredAuthMethod,
    required this.hasPin,
    required this.hasPasskey,
  });

  final String userId;
  final String name;
  final String phoneNumber;
  final bool isPhoneVerified;
  final String accountStatus;
  final String preferredAuthMethod;
  final bool hasPin;
  final bool hasPasskey;

  factory PinSetupUser.fromJson(Map<String, dynamic> json) {
    return PinSetupUser(
      userId: (json['userId'] as String?).getValueOrEmpty(),
      name: (json['name'] as String?).getValueOrEmpty(),
      phoneNumber: (json['phoneNumber'] as String?).getValueOrEmpty(),
      isPhoneVerified: (json['isPhoneVerified'] as bool?).getValueOrFalse(),
      accountStatus: (json['accountStatus'] as String?).getValueOrEmpty(),
      preferredAuthMethod: (json['preferredAuthMethod'] as String?)
          .getValueOrEmpty(),
      hasPin: (json['hasPin'] as bool?).getValueOrFalse(),
      hasPasskey: (json['hasPasskey'] as bool?).getValueOrFalse(),
    );
  }
}

class AuthUser {
  const AuthUser({
    required this.userId,
    required this.authId,
    required this.name,
    required this.username,
    required this.gender,
    required this.dateOfBirth,
    required this.email,
    required this.phoneNumber,
    required this.isPhoneVerified,
    required this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  final String userId;
  final String? authId;
  final String name;
  final String username;
  final String gender;
  final String dateOfBirth;
  final String email;
  final String phoneNumber;
  final bool isPhoneVerified;
  final String? avatarUrl;
  final String createdAt;
  final String updatedAt;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      userId: (json['userId'] as String?).getValueOrEmpty(),
      authId: json['authId'] as String?,
      name: (json['name'] as String?).getValueOrEmpty(),
      username: (json['username'] as String?).getValueOrEmpty(),
      gender: (json['gender'] as String?).getValueOrEmpty(),
      dateOfBirth: (json['dateOfBirth'] as String?).getValueOrEmpty().isNotEmpty
          ? (json['dateOfBirth'] as String?).getValueOrEmpty()
          : (json['dob'] as String?).getValueOrEmpty(),
      email: (json['email'] as String?).getValueOrEmpty(),
      phoneNumber: (json['phoneNumber'] as String?).getValueOrEmpty(),
      isPhoneVerified: (json['isPhoneVerified'] as bool?).getValueOrFalse(),
      avatarUrl: json['avatar_url'] as String? ?? json['avatarUrl'] as String?,
      createdAt: (json['createdAt'] as String?).getValueOrEmpty(),
      updatedAt: (json['updatedAt'] as String?).getValueOrEmpty(),
    );
  }
}

class RequestOtpResponse {
  const RequestOtpResponse({
    required this.ok,
    required this.mockOtpCode,
    required this.message,
    required this.name,
    required this.phoneNumber,
    required this.normalizedPhoneNumber,
    required this.visitorId,
  });

  final bool ok;
  final String mockOtpCode;
  final String message;
  final String name;
  final String phoneNumber;
  final String normalizedPhoneNumber;
  final String visitorId;

  factory RequestOtpResponse.fromJson(Map<String, dynamic> json) {
    return RequestOtpResponse(
      ok: json['ok'] as bool? ?? false,
      mockOtpCode: (json['mockOtpCode'] as String?).getValueOrEmpty(),
      message: (json['message'] as String?).getValueOrEmpty().isNotEmpty
          ? (json['message'] as String?).getValueOrEmpty()
          : 'OTP requested.',
      name: (json['name'] as String?).getValueOrEmpty(),
      phoneNumber: (json['phoneNumber'] as String?).getValueOrEmpty(),
      normalizedPhoneNumber: (json['normalizedPhoneNumber'] as String?)
          .getValueOrEmpty(),
      visitorId: (json['visitorId'] as String?).getValueOrEmpty(),
    );
  }
}

class VerifyOtpResponse {
  const VerifyOtpResponse({
    required this.accessToken,
    required this.user,
    required this.visitorId,
  });

  final String accessToken;
  final AuthUser user;
  final String visitorId;

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    if (user is! Map<String, dynamic>) {
      throw ApiException(
        statusCode: 500,
        message: 'OTP verification response is missing user data.',
      );
    }

    return VerifyOtpResponse(
      accessToken: (json['accessToken'] as String?).getValueOrEmpty(),
      user: AuthUser.fromJson(user),
      visitorId: (json['visitorId'] as String?).getValueOrEmpty(),
    );
  }
}
