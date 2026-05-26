import 'package:golf_kakis/features/foundation/model/user_profile_model.dart';
import 'package:golf_kakis/features/foundation/session/session_state.dart';

abstract class ProfileOverviewRepository {
  Future<ProfileOverviewResult> onFetchUserDetails({
    required SessionState session,
  });

  Future<ProfileOverviewResult> onBuildGuestProfile({
    required SessionState session,
  });
}

class ProfileOverviewResult {
  const ProfileOverviewResult({
    required this.profile,
    required this.isFallback,
  });

  final UserProfileModel profile;
  final bool isFallback;
}
