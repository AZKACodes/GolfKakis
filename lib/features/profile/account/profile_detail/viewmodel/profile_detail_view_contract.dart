import 'package:golf_kakis/features/foundation/default_values.dart';
import 'package:golf_kakis/features/foundation/model/profile/user_profile_model.dart';
import 'package:golf_kakis/features/foundation/model/snackbar_message_model.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_contract.dart';
import 'package:golf_kakis/features/foundation/session/session_state.dart';

abstract class ProfileDetailViewContract {
  ProfileDetailViewState get viewState;
  Stream<ProfileDetailNavEffect> get navEffects;
  void onUserIntent(ProfileDetailUserIntent intent);
}

// ------ View State ------

sealed class ProfileDetailViewState extends ViewState {
  const ProfileDetailViewState() : super();
}

class ProfileDetailDataLoaded extends ProfileDetailViewState {
  const ProfileDetailDataLoaded({
    required this.realName,
    required this.username,
    required this.gender,
    required this.dateOfBirth,
    required this.email,
    required this.phoneNumber,
    required this.avatarIndex,
    this.avatarImagePath,
    required this.initialUsername,
    required this.initialGender,
    required this.initialDateOfBirth,
    required this.initialEmail,
    required this.initialAvatarIndex,
    this.initialAvatarImagePath,
    required this.isSaving,
    this.snackbarMessageModel = SnackbarMessageModel.emptyValue,
    this.errorSnackbarMessageModel = SnackbarMessageModel.emptyValue,
  }) : super();

  factory ProfileDetailDataLoaded.fromProfile(
    UserProfileModel profile, {
    String dateOfBirth = emptyString,
  }) {
    return ProfileDetailDataLoaded(
      realName: profile.displayName,
      username: profile.nickname,
      gender: profile.occupation == '-' ? emptyString : profile.occupation,
      dateOfBirth: dateOfBirth,
      email: profile.email,
      phoneNumber: profile.phoneNumber,
      avatarIndex: profile.avatarIndex,
      avatarImagePath: profile.avatarImagePath,
      initialUsername: profile.nickname,
      initialGender:
          profile.occupation == '-' ? emptyString : profile.occupation,
      initialDateOfBirth: dateOfBirth,
      initialEmail: profile.email,
      initialAvatarIndex: profile.avatarIndex,
      initialAvatarImagePath: profile.avatarImagePath,
      isSaving: false,
    );
  }

  final String realName;
  final String username;
  final String gender;
  final String dateOfBirth;
  final String email;
  final String phoneNumber;
  final int avatarIndex;
  final String? avatarImagePath;
  final String initialUsername;
  final String initialGender;
  final String initialDateOfBirth;
  final String initialEmail;
  final int initialAvatarIndex;
  final String? initialAvatarImagePath;
  final bool isSaving;
  final SnackbarMessageModel snackbarMessageModel;
  final SnackbarMessageModel errorSnackbarMessageModel;

  String? get message =>
      snackbarMessageModel.hasMessage ? snackbarMessageModel.message : null;

  String? get errorMessage => errorSnackbarMessageModel.hasMessage
      ? errorSnackbarMessageModel.message
      : null;

  bool get canSave =>
      username.trim().isNotEmpty &&
      email.trim().isNotEmpty &&
      hasChanges &&
      !isSaving;

  bool get hasChanges =>
      username.trim() != initialUsername.trim() ||
      gender.trim() != initialGender.trim() ||
      dateOfBirth.trim() != initialDateOfBirth.trim() ||
      email.trim() != initialEmail.trim() ||
      avatarIndex != initialAvatarIndex ||
      (avatarImagePath?.trim() ?? '') != (initialAvatarImagePath?.trim() ?? '');

  ProfileDetailDataLoaded copyWith({
    String? realName,
    String? username,
    String? gender,
    String? dateOfBirth,
    String? email,
    String? phoneNumber,
    int? avatarIndex,
    String? avatarImagePath,
    String? initialUsername,
    String? initialGender,
    String? initialDateOfBirth,
    String? initialEmail,
    int? initialAvatarIndex,
    String? initialAvatarImagePath,
    bool? isSaving,
    SnackbarMessageModel? snackbarMessageModel,
    SnackbarMessageModel? errorSnackbarMessageModel,
    bool clearMessage = false,
    bool clearErrorMessage = false,
  }) {
    return ProfileDetailDataLoaded(
      realName: realName ?? this.realName,
      username: username ?? this.username,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarIndex: avatarIndex ?? this.avatarIndex,
      avatarImagePath: avatarImagePath ?? this.avatarImagePath,
      initialUsername: initialUsername ?? this.initialUsername,
      initialGender: initialGender ?? this.initialGender,
      initialDateOfBirth: initialDateOfBirth ?? this.initialDateOfBirth,
      initialEmail: initialEmail ?? this.initialEmail,
      initialAvatarIndex: initialAvatarIndex ?? this.initialAvatarIndex,
      initialAvatarImagePath:
          initialAvatarImagePath ?? this.initialAvatarImagePath,
      isSaving: isSaving ?? this.isSaving,
      snackbarMessageModel: clearMessage
          ? SnackbarMessageModel.emptyValue
          : snackbarMessageModel ?? this.snackbarMessageModel,
      errorSnackbarMessageModel: clearErrorMessage
          ? SnackbarMessageModel.emptyValue
          : errorSnackbarMessageModel ?? this.errorSnackbarMessageModel,
    );
  }
}

// ------ UserIntent ------

sealed class ProfileDetailUserIntent extends UserIntent {
  const ProfileDetailUserIntent() : super();
}

class OnProfileDetailUsernameChanged extends ProfileDetailUserIntent {
  const OnProfileDetailUsernameChanged(this.value);

  final String value;
}

class OnInitProfileDetails extends ProfileDetailUserIntent {
  const OnInitProfileDetails(this.session);

  final SessionState session;
}

class OnProfileDetailGenderChanged extends ProfileDetailUserIntent {
  const OnProfileDetailGenderChanged(this.value);

  final String value;
}

class OnProfileDetailDateOfBirthChanged extends ProfileDetailUserIntent {
  const OnProfileDetailDateOfBirthChanged(this.value);

  final String value;
}

class OnProfileDetailEmailChanged extends ProfileDetailUserIntent {
  const OnProfileDetailEmailChanged(this.value);

  final String value;
}

class OnProfileDetailPhoneChanged extends ProfileDetailUserIntent {
  const OnProfileDetailPhoneChanged(this.value);

  final String value;
}

class OnProfileDetailAvatarChanged extends ProfileDetailUserIntent {
  const OnProfileDetailAvatarChanged(this.value);

  final int value;
}

class OnProfileDetailAvatarImageChanged extends ProfileDetailUserIntent {
  const OnProfileDetailAvatarImageChanged(this.value);

  final String value;
}

class OnProfileDetailSaveClick extends ProfileDetailUserIntent {
  const OnProfileDetailSaveClick();
}

class OnProfileDetailDeactivateAccountConfirmed
    extends ProfileDetailUserIntent {
  const OnProfileDetailDeactivateAccountConfirmed(this.phoneNumber);

  final String phoneNumber;
}

class OnProfileDetailBackClick extends ProfileDetailUserIntent {
  const OnProfileDetailBackClick();
}

// ------ NavEffect ------

sealed class ProfileDetailNavEffect extends NavEffect {
  const ProfileDetailNavEffect() : super();
}

class ProfileDetailNavigateBack extends ProfileDetailNavEffect {
  const ProfileDetailNavigateBack();
}

class ProfileDetailSaved extends ProfileDetailNavEffect {
  const ProfileDetailSaved();
}

class ProfileDetailDeactivated extends ProfileDetailNavEffect {
  const ProfileDetailDeactivated();
}
