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
      dateOfBirth:
          (json['dateOfBirth'] as String?).getValueOrEmpty().isNotEmpty
          ? (json['dateOfBirth'] as String?).getValueOrEmpty()
          : (json['dob'] as String?).getValueOrEmpty(),
      email: (json['email'] as String?).getValueOrEmpty(),
      phoneNumber: (json['phoneNumber'] as String?).getValueOrEmpty(),
      isPhoneVerified: (json['isPhoneVerified'] as bool?).getValueOrFalse(),
      avatarUrl:
          json['avatar_url'] as String? ??
          json['avatarUrl'] as String?,
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
      message:
          (json['message'] as String?).getValueOrEmpty().isNotEmpty
          ? (json['message'] as String?).getValueOrEmpty()
          : 'OTP requested.',
      name: (json['name'] as String?).getValueOrEmpty(),
      phoneNumber: (json['phoneNumber'] as String?).getValueOrEmpty(),
      normalizedPhoneNumber:
          (json['normalizedPhoneNumber'] as String?).getValueOrEmpty(),
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
