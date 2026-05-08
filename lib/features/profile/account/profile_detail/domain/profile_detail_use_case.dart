import 'package:golf_kakis/features/foundation/model/profile/user_profile_model.dart';
import 'package:golf_kakis/features/foundation/session/session_state.dart';

abstract class ProfileDetailUseCase {
  Future<UserProfileModel> onFetchUserDetails({
    required SessionState session,
    required UserProfileModel fallbackProfile,
  });

  Future<UserProfileModel> onUpdateProfile({
    required SessionState session,
    required UserProfileModel profile,
  });

  Future<UserProfileModel> onUpdateProfilePicture({
    required SessionState session,
    required UserProfileModel profile,
  });

  Future<String> onDeactivateAccount({
    required SessionState session,
    required String phoneNumber,
  });
}
