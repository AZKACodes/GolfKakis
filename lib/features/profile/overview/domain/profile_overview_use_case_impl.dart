import 'package:golf_kakis/features/foundation/session/session_state.dart';
import 'package:golf_kakis/features/profile/overview/data/profile_overview_repository.dart';
import 'package:golf_kakis/features/profile/overview/data/profile_overview_repository_impl.dart';

import 'profile_overview_use_case.dart';

class ProfileOverviewUseCaseImpl implements ProfileOverviewUseCase {
  const ProfileOverviewUseCaseImpl();

  @override
  Future<ProfileOverviewResult> fetchUserProfile({
    required SessionState session,
  }) {
    return ProfileOverviewRepositoryImpl().onFetchUserProfile(session: session);
  }
}
