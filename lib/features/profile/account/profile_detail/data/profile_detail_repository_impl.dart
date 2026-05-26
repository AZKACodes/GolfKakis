import 'package:golf_kakis/features/foundation/model/user_profile_model.dart';
import 'package:golf_kakis/features/foundation/network/network.dart';
import 'package:golf_kakis/features/foundation/session/session_state.dart';
import 'package:golf_kakis/features/profile/account/profile_detail/data/profile_detail_repository.dart';
import 'package:golf_kakis/features/profile/api/profile_api_service.dart';

class ProfileDetailRepositoryImpl implements ProfileDetailRepository {
  ProfileDetailRepositoryImpl({
    ApiClient? apiClient,
    ProfileApiService? apiService,
  }) : _apiService = apiService ?? ProfileApiService(apiClient: apiClient);

  final ProfileApiService _apiService;

  @override
  Future<UserProfileModel> onFetchUserDetails({
    required SessionState session,
    required UserProfileModel fallbackProfile,
  }) async {
    final accessToken = session.accessToken?.trim();
    if (accessToken == null || accessToken.isEmpty) {
      return fallbackProfile;
    }

    final user = await _apiService.onFetchUserDetails(accessToken: accessToken);
    return fallbackProfile.copyWith(
      userId: user.userId,
      userSlug: user.userId,
      displayName: user.name,
      nickname: user.username.isNotEmpty
          ? user.username
          : (session.profileNickname ?? fallbackProfile.nickname),
      occupation: user.gender.isNotEmpty
          ? user.gender
          : (session.profileOccupation ?? fallbackProfile.occupation),
      email: user.email.isNotEmpty
          ? user.email
          : (session.profileEmail ?? fallbackProfile.email),
      phoneNumber: user.phoneNumber,
      avatarIndex: session.profileAvatarIndex ?? fallbackProfile.avatarIndex,
      avatarImagePath:
          session.profileAvatarImagePath ?? fallbackProfile.avatarImagePath,
      isLoggedIn: true,
    );
  }

  @override
  Future<UserProfileModel> onUpdateProfile({
    required SessionState session,
    required UserProfileModel profile,
  }) async {
    final accessToken = session.accessToken?.trim();
    if (accessToken == null || accessToken.isEmpty) {
      throw ApiException(message: 'Missing access token for update profile.');
    }

    final updatedUser = await _apiService.onUpdateProfile(
      accessToken: accessToken,
      name: profile.displayName,
      username: profile.nickname,
      gender: profile.occupation == '-' ? '' : profile.occupation,
      dateOfBirth: profile.userSlug.startsWith('dob:')
          ? profile.userSlug.substring(4)
          : '',
      email: profile.email,
    );

    return profile.copyWith(
      userId: updatedUser.userId,
      userSlug: updatedUser.dateOfBirth.isNotEmpty
          ? 'dob:${updatedUser.dateOfBirth}'
          : profile.userSlug,
      displayName: updatedUser.name,
      nickname: updatedUser.username.isNotEmpty
          ? updatedUser.username
          : profile.nickname,
      occupation: updatedUser.gender.isNotEmpty
          ? updatedUser.gender
          : profile.occupation,
      email: updatedUser.email.isNotEmpty ? updatedUser.email : profile.email,
      phoneNumber: updatedUser.phoneNumber,
    );
  }

  @override
  Future<UserProfileModel> onUpdateProfilePicture({
    required SessionState session,
    required UserProfileModel profile,
  }) async {
    final accessToken = session.accessToken?.trim();
    if (accessToken == null || accessToken.isEmpty) {
      throw ApiException(
        message: 'Missing access token for update profile picture.',
      );
    }

    final imagePath = profile.avatarImagePath?.trim();
    if (imagePath == null || imagePath.isEmpty) {
      return profile;
    }

    await _apiService.onUpdateProfilePicture(
      accessToken: accessToken,
      imagePath: imagePath,
    );
    return profile;
  }

  @override
  Future<String> onDeactivateAccount({
    required SessionState session,
    required String phoneNumber,
  }) async {
    final accessToken = session.accessToken?.trim();
    if (accessToken == null || accessToken.isEmpty) {
      throw ApiException(message: 'Missing access token for deactivate account.');
    }

    return _apiService.onDeactivateAccount(
      accessToken: accessToken,
      phoneNumber: phoneNumber,
    );
  }
}
