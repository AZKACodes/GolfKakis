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

    if (response is! Map<String, dynamic>) {
      throw ApiException(
        statusCode: 500,
        message: 'Fetch user details returned an invalid response.',
      );
    }

    return AuthUser.fromJson(response);
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
}

class AuthUser {
  const AuthUser({
    required this.userId,
    required this.authId,
    required this.name,
    required this.phoneNumber,
    required this.isPhoneVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  final String userId;
  final String? authId;
  final String name;
  final String phoneNumber;
  final bool isPhoneVerified;
  final String createdAt;
  final String updatedAt;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      userId: json['userId'] as String? ?? '',
      authId: json['authId'] as String?,
      name: json['name'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      isPhoneVerified: json['isPhoneVerified'] as bool? ?? false,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
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
      mockOtpCode: json['mockOtpCode'] as String? ?? '',
      message: json['message'] as String? ?? 'OTP requested.',
      name: json['name'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      normalizedPhoneNumber: json['normalizedPhoneNumber'] as String? ?? '',
      visitorId: json['visitorId'] as String? ?? '',
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
      accessToken: json['accessToken'] as String? ?? '',
      user: AuthUser.fromJson(user),
      visitorId: json['visitorId'] as String? ?? '',
    );
  }
}
