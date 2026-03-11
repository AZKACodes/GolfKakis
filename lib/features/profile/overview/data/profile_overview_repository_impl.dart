import 'package:xxx_demo_app/features/foundation/enums/session/session_status.dart';
import 'package:xxx_demo_app/features/foundation/enums/session/user_role.dart';
import 'package:xxx_demo_app/features/foundation/model/profile/user_profile_model.dart';
import 'package:xxx_demo_app/features/foundation/network/network.dart';
import 'package:xxx_demo_app/features/foundation/session/session_state.dart';
import 'package:xxx_demo_app/features/profile/api/profile_api_service.dart';
import 'package:xxx_demo_app/features/profile/overview/data/profile_overview_repository.dart';

class ProfileOverviewRepositoryImpl implements ProfileOverviewRepository {
  ProfileOverviewRepositoryImpl({
    ApiClient? apiClient,
    ProfileApiService? apiService,
  }) : _apiService =
           apiService ?? ProfileApiService(apiClient: apiClient ?? ApiClient());

  final ProfileApiService _apiService;

  @override
  Future<ProfileOverviewResult> onFetchUserProfile({
    required SessionState session,
  }) async {
    try {
      final response = await _apiService.onFetchUserProfile();
      final profile = _parseProfile(response, session: session);
      if (profile != null) {
        return ProfileOverviewResult(profile: profile, isFallback: false);
      }
    } catch (_) {
      // Temporary fallback until the user profile endpoint is ready.
    }

    return ProfileOverviewResult(
      profile: _buildFallbackProfile(session),
      isFallback: true,
    );
  }

  UserProfileModel? _parseProfile(
    dynamic response, {
    required SessionState session,
  }) {
    final payload = response is Map<String, dynamic>
        ? response['data'] is Map<String, dynamic>
              ? response['data'] as Map<String, dynamic>
              : response
        : null;

    if (payload == null) {
      return null;
    }

    final userId =
        payload['userId']?.toString() ??
        payload['id']?.toString() ??
        payload['profileId']?.toString();
    final userSlug =
        payload['userSlug']?.toString() ??
        payload['slug']?.toString() ??
        payload['profileSlug']?.toString();

    if (userId == null || userSlug == null) {
      return null;
    }

    final isLoggedIn = payload['isLoggedIn'] is bool
        ? payload['isLoggedIn'] as bool
        : session.status == SessionStatus.loggedIn;
    final role =
        _parseRole(payload['role']?.toString()) ?? session.effectiveUserRole;

    return UserProfileModel(
      userId: userId,
      userSlug: userSlug,
      displayName:
          payload['displayName']?.toString() ??
          payload['name']?.toString() ??
          session.effectiveUsername,
      email: payload['email']?.toString() ?? '-',
      phoneNumber: payload['phoneNumber']?.toString() ?? '-',
      role: role,
      membershipLabel:
          payload['membershipLabel']?.toString() ??
          _defaultMembershipLabel(role),
      isLoggedIn: isLoggedIn,
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

  UserRole? _parseRole(String? value) {
    switch (value?.toLowerCase()) {
      case 'user':
        return UserRole.user;
      case 'agent':
        return UserRole.agent;
      case 'admin':
        return UserRole.admin;
      case 'guest':
        return UserRole.guest;
      default:
        return null;
    }
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
