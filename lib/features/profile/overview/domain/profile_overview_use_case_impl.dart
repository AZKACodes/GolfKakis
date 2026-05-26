import 'package:golf_kakis/features/foundation/session/session_state.dart';
import 'package:golf_kakis/features/profile/overview/data/profile_overview_repository.dart';
import 'package:golf_kakis/features/profile/overview/data/profile_overview_repository_impl.dart';

import 'profile_overview_use_case.dart';

class ProfileOverviewUseCaseImpl implements ProfileOverviewUseCase {
  const ProfileOverviewUseCaseImpl();

  @override
  Future<ProfileOverviewResult> onFetchUserDetails({
    required SessionState session,
  }) {
    return ProfileOverviewRepositoryImpl().onFetchUserDetails(session: session);
  }

  @override
  Future<ProfileOverviewResult> onBuildGuestProfile({
    required SessionState session,
  }) {
    return ProfileOverviewRepositoryImpl().onBuildGuestProfile(session: session);
  }
}
