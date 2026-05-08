import 'package:golf_kakis/features/foundation/default_values.dart';
import 'package:golf_kakis/features/foundation/enums/session/user_role.dart';
import 'package:golf_kakis/features/foundation/model/profile/user_profile_model.dart';
import 'package:golf_kakis/features/foundation/network/network.dart';
import 'package:golf_kakis/features/foundation/session/session_state.dart';
import 'package:golf_kakis/features/profile/api/profile_api_service.dart';
import 'package:golf_kakis/features/profile/overview/data/profile_overview_repository.dart';

class ProfileOverviewRepositoryImpl implements ProfileOverviewRepository {
  ProfileOverviewRepositoryImpl({
    ApiClient? apiClient,
    ProfileApiService? apiService,
  }) : _apiService = apiService ?? ProfileApiService(apiClient: apiClient);

  final ProfileApiService _apiService;

  @override
  Future<ProfileOverviewResult> onFetchUserDetails({
    required SessionState session,
  }) async {
    final accessToken = session.accessToken?.trim();
    if (accessToken == null || accessToken.isEmpty) {
      throw ApiException(message: 'Missing access token for user profile.');
    }

    final user = await _apiService.onFetchUserDetails(
      accessToken: accessToken,
    );
    return ProfileOverviewResult(
      profile: _buildAuthenticatedProfile(session, user),
      isFallback: false,
    );
  }

  @override
  Future<ProfileOverviewResult> onBuildGuestProfile({
    required SessionState session,
  }) async {
    return ProfileOverviewResult(
      profile: _buildGuestProfile(session),
      isFallback: false,
    );
  }

  UserProfileModel _buildAuthenticatedProfile(
    SessionState session,
    AuthUser user,
  ) {
    final role = session.effectiveUserRole;
    return UserProfileModel(
      userId: user.userId,
      userSlug: user.userId,
      displayName: user.name,
      nickname: session.profileNickname ?? user.name.split(' ').first,
      occupation: session.profileOccupation ?? 'Golfer',
      email: session.profileEmail ?? '-',
      phoneNumber: user.phoneNumber,
      avatarIndex: session.profileAvatarIndex ?? emptyInt,
      avatarImagePath: session.profileAvatarImagePath,
      role: role,
      membershipLabel: _defaultMembershipLabel(role),
      isLoggedIn: true,
    );
  }

  UserProfileModel _buildGuestProfile(SessionState session) {
    return UserProfileModel(
      userId: 'guest-${session.deviceId}',
      userSlug: 'guest-${session.deviceId}',
      displayName: 'Guest User',
      nickname: 'Guest',
      occupation: '-',
      email: '-',
      phoneNumber: '-',
      avatarIndex: 0,
      avatarImagePath: session.profileAvatarImagePath,
      role: UserRole.guest,
      membershipLabel: _defaultMembershipLabel(UserRole.guest),
      isLoggedIn: false,
    );
  }

  String _defaultMembershipLabel(UserRole role) {
    switch (role) {
      case UserRole.user:
        return 'Standard Member';
      case UserRole.agent:
        return 'Agent Account';
      case UserRole.admin:
        return 'Admin Access';
      case UserRole.guest:
        return 'Guest User';
    }
  }
}
