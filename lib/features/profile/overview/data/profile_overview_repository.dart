import 'package:xxx_demo_app/features/foundation/model/profile/user_profile_model.dart';
import 'package:xxx_demo_app/features/foundation/session/session_state.dart';

abstract class ProfileOverviewRepository {
  Future<ProfileOverviewResult> onFetchUserProfile({
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
