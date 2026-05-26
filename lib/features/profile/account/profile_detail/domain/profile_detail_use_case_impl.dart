import 'package:golf_kakis/features/foundation/model/user_profile_model.dart';
import 'package:golf_kakis/features/foundation/session/session_state.dart';
import 'package:golf_kakis/features/profile/account/profile_detail/data/profile_detail_repository_impl.dart';

import 'profile_detail_use_case.dart';

class ProfileDetailUseCaseImpl implements ProfileDetailUseCase {
  const ProfileDetailUseCaseImpl();

  @override
  Future<UserProfileModel> onFetchUserDetails({
    required SessionState session,
    required UserProfileModel fallbackProfile,
  }) {
    return ProfileDetailRepositoryImpl().onFetchUserDetails(
      session: session,
      fallbackProfile: fallbackProfile,
    );
  }

  @override
  Future<UserProfileModel> onUpdateProfile({
    required SessionState session,
    required UserProfileModel profile,
  }) {
    return ProfileDetailRepositoryImpl().onUpdateProfile(
      session: session,
      profile: profile,
    );
  }

  @override
  Future<UserProfileModel> onUpdateProfilePicture({
    required SessionState session,
    required UserProfileModel profile,
  }) {
    return ProfileDetailRepositoryImpl().onUpdateProfilePicture(
      session: session,
      profile: profile,
    );
  }

  @override
  Future<String> onDeactivateAccount({
    required SessionState session,
    required String phoneNumber,
  }) {
    return ProfileDetailRepositoryImpl().onDeactivateAccount(
      session: session,
      phoneNumber: phoneNumber,
    );
  }
}
