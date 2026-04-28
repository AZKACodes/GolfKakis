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
    return ProfileEditDataLoaded.fromProfile(_profile);
  }

  @override
  Future<void> handleIntent(ProfileEditUserIntent intent) async {
    switch (intent) {
      case OnProfileEditFullNameChanged():
        emitViewState(
          (_) => _currentDataState.copyWith(
            fullName: intent.value,
            clearMessage: true,
            clearErrorMessage: true,
          ),
        );
      case OnProfileEditNicknameChanged():
        emitViewState(
          (_) => _currentDataState.copyWith(
            nickname: intent.value,
            clearMessage: true,
            clearErrorMessage: true,
          ),
        );
      case OnProfileEditOccupationChanged():
        emitViewState(
          (_) => _currentDataState.copyWith(
            occupation: intent.value,
            clearMessage: true,
            clearErrorMessage: true,
          ),
        );
      case OnProfileEditEmailChanged():
        emitViewState(
          (_) => _currentDataState.copyWith(
            email: intent.value,
            clearMessage: true,
            clearErrorMessage: true,
          ),
        );
      case OnProfileEditPhoneChanged():
        emitViewState(
          (_) => _currentDataState.copyWith(
            phoneNumber: intent.value,
            clearMessage: true,
            clearErrorMessage: true,
          ),
        );
      case OnProfileEditAvatarChanged():
        emitViewState(
          (_) => _currentDataState.copyWith(
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

  ProfileEditDataLoaded get _currentDataState {
    return switch (currentState) {
      ProfileEditDataLoaded() => currentState as ProfileEditDataLoaded,
    };
  }

  Future<void> _save() async {
    if (!_currentDataState.canSave) {
      emitViewState(
        (_) => _currentDataState.copyWith(
          errorMessage: 'Enter your name, nickname, and occupation to save.',
          clearMessage: true,
        ),
      );
      return;
    }

    emitViewState(
      (_) => _currentDataState.copyWith(
        isSaving: true,
        clearMessage: true,
        clearErrorMessage: true,
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 300));
    emitViewState(
      (_) => _currentDataState.copyWith(
        isSaving: false,
        message: 'Profile updated for this demo session.',
      ),
    );
    sendNavEffect(() => const ProfileEditSaved());
  }
}
