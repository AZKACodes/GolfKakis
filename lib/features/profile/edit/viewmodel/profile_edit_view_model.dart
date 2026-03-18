import 'package:golf_kakis/features/foundation/model/profile/user_profile_model.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_view_model.dart';

import 'profile_edit_view_contract.dart';

class ProfileEditViewModel
    extends
        MviViewModel<
          ProfileEditUserIntent,
          ProfileEditViewState,
          ProfileEditNavEffect
        >
    implements ProfileEditViewContract {
  ProfileEditViewModel({required UserProfileModel profile})
    : _profile = profile;

  final UserProfileModel _profile;

  @override
  ProfileEditViewState createInitialState() {
    return ProfileEditViewState.fromProfile(_profile);
  }

  @override
  Future<void> handleIntent(ProfileEditUserIntent intent) async {
    switch (intent) {
      case OnProfileEditFullNameChanged():
        emitViewState(
          (state) => state.copyWith(
            fullName: intent.value,
            clearMessage: true,
            clearErrorMessage: true,
          ),
        );
      case OnProfileEditNicknameChanged():
        emitViewState(
          (state) => state.copyWith(
            nickname: intent.value,
            clearMessage: true,
            clearErrorMessage: true,
          ),
        );
      case OnProfileEditOccupationChanged():
        emitViewState(
          (state) => state.copyWith(
            occupation: intent.value,
            clearMessage: true,
            clearErrorMessage: true,
          ),
        );
      case OnProfileEditEmailChanged():
        emitViewState(
          (state) => state.copyWith(
            email: intent.value,
            clearMessage: true,
            clearErrorMessage: true,
          ),
        );
      case OnProfileEditPhoneChanged():
        emitViewState(
          (state) => state.copyWith(
            phoneNumber: intent.value,
            clearMessage: true,
            clearErrorMessage: true,
          ),
        );
      case OnProfileEditAvatarChanged():
        emitViewState(
          (state) => state.copyWith(
            avatarIndex: intent.value,
            clearMessage: true,
            clearErrorMessage: true,
          ),
        );
      case OnProfileEditSaveClick():
        await _save();
      case OnProfileEditBackClick():
        sendNavEffect(() => const ProfileEditNavigateBack());
    }
  }

  Future<void> _save() async {
    if (!currentState.canSave) {
      emitViewState(
        (state) => state.copyWith(
          errorMessage: 'Enter your name, nickname, and occupation to save.',
          clearMessage: true,
        ),
      );
      return;
    }

    emitViewState(
      (state) => state.copyWith(
        isSaving: true,
        clearMessage: true,
        clearErrorMessage: true,
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 300));
    emitViewState(
      (state) => state.copyWith(
        isSaving: false,
        message: 'Profile updated for this demo session.',
      ),
    );
    sendNavEffect(() => const ProfileEditSaved());
  }
}
