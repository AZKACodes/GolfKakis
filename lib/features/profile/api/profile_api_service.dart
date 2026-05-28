import 'dart:io';

import 'package:golf_kakis/features/foundation/default_values.dart';
import 'package:golf_kakis/features/foundation/model/auth/auth_user.dart';
import 'package:golf_kakis/features/foundation/model/profile_friend_model.dart';
import 'package:golf_kakis/features/foundation/model/response/login_methods_response.dart';
import 'package:golf_kakis/features/foundation/model/response/register_otp_verify_response.dart';
import 'package:golf_kakis/features/foundation/model/response/send_whatsapp_otp_response.dart';
import 'package:golf_kakis/features/foundation/model/response/setup_user_pin_response.dart';
import 'package:golf_kakis/features/foundation/network/network.dart';
import 'package:http/http.dart' as http;

class ProfileApiService {
  ProfileApiService({ApiClient? apiClient, http.Client? uploadClient})
    : _apiClient = apiClient ?? ApiClient(),
      _uploadClient = uploadClient ?? http.Client();

  final ApiClient _apiClient;
  final http.Client _uploadClient;

  Future<dynamic> onFetchUserProfile() {
    return _apiClient.getJson('/profile/me');
  }

  Future<List<ProfileFriendModel>> onFetchFriendList({
    required String accessToken,
  }) async {
    final response = await _apiClient.getJson(
      '/profile/friends',
      headers: <String, String>{'Authorization': 'Bearer $accessToken'},
    );

    return _friendListFromResponse(response);
  }

  Future<ProfileFriendModel> onAddFriend({
    required String accessToken,
    required ProfileFriendModel friend,
  }) async {
    final response = await _apiClient.postJson(
      '/profile/friends',
      headers: <String, String>{'Authorization': 'Bearer $accessToken'},
      body: <String, dynamic>{
        'contactKey': friend.contactKey,
        'displayName': friend.displayName,
        'phoneNumber': friend.phoneNumber,
        if (friend.nickname.trim().isNotEmpty)
          'nickname': friend.nickname.trim(),
      },
    );

    return _friendFromResponse(response, fallback: friend);
  }

  Future<void> onDeleteFriend({
    required String accessToken,
    required String contactKey,
  }) {
    return _apiClient.deleteJson(
      '/profile/friends/${Uri.encodeComponent(contactKey)}',
      headers: <String, String>{'Authorization': 'Bearer $accessToken'},
    );
  }

  Future<ProfileFriendModel> onUpdateFriendDetails({
    required String accessToken,
    required String contactKey,
    required String nickname,
  }) async {
    final response = await _apiClient.patchJson(
      '/profile/friends/${Uri.encodeComponent(contactKey)}',
      headers: <String, String>{'Authorization': 'Bearer $accessToken'},
      body: <String, dynamic>{'nickname': nickname.trim()},
    );

    return _friendFromResponse(
      response,
      fallback: ProfileFriendModel(
        contactKey: contactKey,
        displayName: '',
        phoneNumber: '',
        nickname: nickname.trim(),
      ),
    );
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

    return AuthUser.fromJson(_extractUserJson(response));
  }

  Future<AuthUser> onUpdateProfile({
    required String accessToken,
    required String name,
    required String username,
    required String dateOfBirth,
    required String email,
  }) async {
    final response = await _apiClient.patchJson(
      '/auth/me',
      headers: <String, String>{'Authorization': 'Bearer $accessToken'},
      body: <String, dynamic>{
        'name': name,
        'email': email,
        'dateOfBirth': dateOfBirth,
        'username': username,
      },
    );

    if (response is! Map<String, dynamic>) {
      throw ApiException(
        statusCode: 500,
        message: 'Update profile returned an invalid response.',
      );
    }

    return AuthUser.fromJson(_extractUserJson(response));
  }

  Map<String, dynamic> _extractUserJson(Map<String, dynamic> response) {
    final nestedUser = response['user'];
    if (nestedUser is Map<String, dynamic>) {
      return nestedUser;
    }

    final nestedData = response['data'];
    if (nestedData is Map<String, dynamic>) {
      final dataUser = nestedData['user'];
      if (dataUser is Map<String, dynamic>) {
        return dataUser;
      }

      final dataProfile = nestedData['profile'];
      if (dataProfile is Map<String, dynamic>) {
        return dataProfile;
      }

      return nestedData;
    }

    final nestedProfile = response['profile'];
    if (nestedProfile is Map<String, dynamic>) {
      return nestedProfile;
    }

    return response;
  }

  Future<String> onUpdateProfilePicture({
    required String accessToken,
    required String imagePath,
  }) async {
    final imageFile = File(imagePath);
    final fileName = _fileNameFromPath(imagePath);
    final contentType = _contentTypeFromFileName(fileName);

    final response = await _apiClient.postJson(
      '/auth/me/profile-image/upload-url',
      headers: <String, String>{'Authorization': 'Bearer $accessToken'},
      body: <String, dynamic>{'fileName': fileName, 'contentType': contentType},
    );

    if (response is! Map<String, dynamic>) {
      throw ApiException(
        statusCode: 500,
        message: 'Profile image upload URL returned an invalid response.',
      );
    }

    final uploadPayload = _extractUploadUrlJson(response);
    final uploadUrl = _readString(uploadPayload, const <String>[
      'uploadUrl',
      'upload_url',
      'signedUrl',
      'signed_url',
      'presignedUrl',
      'presigned_url',
      'presignedUploadUrl',
      'presigned_upload_url',
      'url',
    ]);

    if (uploadUrl.isEmpty) {
      throw ApiException(
        statusCode: 500,
        message: 'Profile image upload URL is missing.',
      );
    }

    await _uploadProfileImage(
      uploadUrl: uploadUrl,
      imageFile: imageFile,
      contentType: contentType,
    );

    final imageUrl = _readString(uploadPayload, const <String>[
      'imageUrl',
      'image_url',
      'profileImageUrl',
      'profile_image_url',
      'profilePictureUrl',
      'profile_picture_url',
      'avatarUrl',
      'avatar_url',
      'publicUrl',
      'public_url',
      'fileUrl',
      'file_url',
      'objectUrl',
      'object_url',
    ]);

    return imageUrl;
  }

  Future<void> _uploadProfileImage({
    required String uploadUrl,
    required File imageFile,
    required String contentType,
  }) async {
    final uri = Uri.parse(uploadUrl);
    final response = await _uploadClient.put(
      uri,
      headers: <String, String>{'Content-Type': contentType},
      body: await imageFile.readAsBytes(),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Unable to upload profile image.',
      );
    }
  }

  Map<String, dynamic> _extractUploadUrlJson(Map<String, dynamic> response) {
    final nestedData = response['data'];
    if (nestedData is Map<String, dynamic>) {
      return nestedData;
    }

    final nestedUpload = response['upload'];
    if (nestedUpload is Map<String, dynamic>) {
      return nestedUpload;
    }

    return response;
  }

  String _fileNameFromPath(String path) {
    final segments = Uri.file(path).pathSegments;
    if (segments.isEmpty || segments.last.trim().isEmpty) {
      return 'avatar.jpg';
    }
    return segments.last;
  }

  String _contentTypeFromFileName(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) {
      return 'image/png';
    }
    if (lower.endsWith('.webp')) {
      return 'image/webp';
    }
    if (lower.endsWith('.heic')) {
      return 'image/heic';
    }
    return 'image/jpeg';
  }

  String _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return emptyString;
  }

  Future<LoginMethodsResponse> onFetchLoginMethods({
    required String phoneNumber,
  }) async {
    final response = await _apiClient.postJson(
      '/auth/login/options',
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
      '/auth/otp/send',
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

  Future<RegisterOtpVerifyResponse> onVerifyOTP({
    required String name,
    required String phoneNumber,
    required String purpose,
    required bool includeVisitorId,
    required String otpCode,
    required String visitorId,
  }) async {
    final response = await _apiClient.postJson(
      '/auth/otp/verify',
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
      '/auth/pin/setup',
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
    final response = await _apiClient.postJsonWithoutSharedHeaders(
      '/auth/login/pin',
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

  List<ProfileFriendModel> _friendListFromResponse(dynamic response) {
    final list = switch (response) {
      List() => response,
      Map<String, dynamic>() => _extractFriendList(response),
      _ => null,
    };

    if (list is! List) {
      throw ApiException(
        statusCode: 500,
        message: 'Friend list returned an invalid response.',
      );
    }

    return list
        .whereType<Map>()
        .map((item) => _friendFromJson(Map<String, dynamic>.from(item)))
        .whereType<ProfileFriendModel>()
        .toList();
  }

  dynamic _extractFriendList(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is List) {
      return data;
    }
    if (data is Map<String, dynamic>) {
      return data['friends'] ?? data['items'] ?? data['friendList'];
    }

    return response['friends'] ?? response['items'] ?? response['friendList'];
  }

  ProfileFriendModel _friendFromResponse(
    dynamic response, {
    required ProfileFriendModel fallback,
  }) {
    final json = switch (response) {
      Map<String, dynamic>() => _extractFriendJson(response),
      _ => null,
    };

    if (json is Map<String, dynamic>) {
      return _friendFromJson(json) ?? fallback;
    }

    return fallback;
  }

  Map<String, dynamic>? _extractFriendJson(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      final friend = data['friend'];
      if (friend is Map<String, dynamic>) {
        return friend;
      }
      return data;
    }

    final friend = response['friend'];
    if (friend is Map<String, dynamic>) {
      return friend;
    }

    return response;
  }

  ProfileFriendModel? _friendFromJson(Map<String, dynamic> json) {
    final phoneNumber =
        (json['phoneNumber'] ??
                json['phone_number'] ??
                json['phone'] ??
                json['mobileNumber'] ??
                '')
            .toString()
            .trim();
    final contactKey =
        (json['contactKey'] ??
                json['contact_key'] ??
                json['friendId'] ??
                json['friend_id'] ??
                json['id'] ??
                phoneNumber)
            .toString()
            .trim();

    if (contactKey.isEmpty && phoneNumber.isEmpty) {
      return null;
    }

    final displayName =
        (json['displayName'] ??
                json['display_name'] ??
                json['name'] ??
                json['fullName'] ??
                json['full_name'] ??
                'Golf Kaki')
            .toString()
            .trim();

    return ProfileFriendModel(
      contactKey: contactKey.isEmpty ? phoneNumber : contactKey,
      displayName: displayName.isEmpty ? 'Golf Kaki' : displayName,
      phoneNumber: phoneNumber,
      nickname: (json['nickname'] ?? json['nickName'] ?? '').toString().trim(),
    );
  }
}
