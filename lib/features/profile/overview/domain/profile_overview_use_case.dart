import 'package:golf_kakis/features/foundation/session/session_state.dart';
import 'package:golf_kakis/features/profile/overview/data/profile_overview_repository.dart';

abstract class ProfileOverviewUseCase {
  Future<ProfileOverviewResult> fetchUserProfile({
    required SessionState session,
  });
}
