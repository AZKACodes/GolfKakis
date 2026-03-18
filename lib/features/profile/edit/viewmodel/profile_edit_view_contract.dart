import 'package:golf_kakis/features/foundation/model/profile/user_profile_model.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_contract.dart';

abstract class ProfileEditViewContract {
  ProfileEditViewState get viewState;
  Stream<ProfileEditNavEffect> get navEffects;
  void onUserIntent(ProfileEditUserIntent intent);
}

class ProfileEditViewState extends ViewState {
  const ProfileEditViewState({
    required this.fullName,
    required this.nickname,
    required this.occupation,
    required this.email,
    required this.phoneNumber,
    required this.avatarIndex,
    required this.isSaving,
    this.message,
    this.errorMessage,
  }) : super();

  factory ProfileEditViewState.fromProfile(UserProfileModel profile) {
    return ProfileEditViewState(
      fullName: profile.displayName,
      nickname: profile.nickname,
      occupation: profile.occupation,
      email: profile.email,
      phoneNumber: profile.phoneNumber,
      avatarIndex: profile.avatarIndex,
      isSaving: false,
    );
  }

  final String fullName;
  final String nickname;
  final String occupation;
  final String email;
  final String phoneNumber;
  final int avatarIndex;
  final bool isSaving;
  final String? message;
  final String? errorMessage;

  bool get canSave =>
      fullName.trim().isNotEmpty &&
      nickname.trim().isNotEmpty &&
      occupation.trim().isNotEmpty &&
      !isSaving;

  ProfileEditViewState copyWith({
    String? fullName,
    String? nickname,
    String? occupation,
    String? email,
    String? phoneNumber,
    int? avatarIndex,
    bool? isSaving,
    String? message,
    String? errorMessage,
    bool clearMessage = false,
    bool clearErrorMessage = false,
  }) {
    return ProfileEditViewState(
      fullName: fullName ?? this.fullName,
      nickname: nickname ?? this.nickname,
      occupation: occupation ?? this.occupation,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarIndex: avatarIndex ?? this.avatarIndex,
      isSaving: isSaving ?? this.isSaving,
      message: clearMessage ? null : message ?? this.message,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}

sealed class ProfileEditUserIntent extends UserIntent {
  const ProfileEditUserIntent() : super();
}

class OnProfileEditFullNameChanged extends ProfileEditUserIntent {
  const OnProfileEditFullNameChanged(this.value);

  final String value;
}

class OnProfileEditNicknameChanged extends ProfileEditUserIntent {
  const OnProfileEditNicknameChanged(this.value);

  final String value;
}

class OnProfileEditOccupationChanged extends ProfileEditUserIntent {
  const OnProfileEditOccupationChanged(this.value);

  final String value;
}

class OnProfileEditEmailChanged extends ProfileEditUserIntent {
  const OnProfileEditEmailChanged(this.value);

  final String value;
}

class OnProfileEditPhoneChanged extends ProfileEditUserIntent {
  const OnProfileEditPhoneChanged(this.value);

  final String value;
}

class OnProfileEditAvatarChanged extends ProfileEditUserIntent {
  const OnProfileEditAvatarChanged(this.value);

  final int value;
}

class OnProfileEditSaveClick extends ProfileEditUserIntent {
  const OnProfileEditSaveClick();
}

class OnProfileEditBackClick extends ProfileEditUserIntent {
  const OnProfileEditBackClick();
}

sealed class ProfileEditNavEffect extends NavEffect {
  const ProfileEditNavEffect() : super();
}

class ProfileEditNavigateBack extends ProfileEditNavEffect {
  const ProfileEditNavigateBack();
}

class ProfileEditSaved extends ProfileEditNavEffect {
  const ProfileEditSaved();
}
