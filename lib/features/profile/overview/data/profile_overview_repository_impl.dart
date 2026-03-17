import 'package:golf_kakis/features/foundation/enums/session/session_status.dart';
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
  });

  @override
  Future<ProfileOverviewResult> onFetchUserProfile({
    required SessionState session,
  }) async {
    return ProfileOverviewResult(
      profile: _buildFallbackProfile(session),
      isFallback: true,
    );
  }

  UserProfileModel _buildFallbackProfile(SessionState session) {
    final isLoggedIn = session.status == SessionStatus.loggedIn;
    final role = session.effectiveUserRole;
    return UserProfileModel(
      userId: isLoggedIn ? 'USR-1001' : 'guest-${session.deviceId}',
      userSlug: isLoggedIn ? 'zack-green' : 'guest-${session.deviceId}',
      displayName: isLoggedIn ? session.effectiveUsername : 'Guest User',
      email: isLoggedIn ? 'zack.green@example.com' : '-',
      phoneNumber: isLoggedIn ? '+60 12-310 4472' : '-',
      role: role,
      membershipLabel: _defaultMembershipLabel(role),
      isLoggedIn: isLoggedIn,
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
