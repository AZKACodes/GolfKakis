import 'package:golf_kakis/features/foundation/viewmodel/mvi_contract.dart';

abstract class ProfileRegisterDetailsViewContract {
  ProfileRegisterDetailsViewState get viewState;
  Stream<ProfileRegisterDetailsNavEffect> get navEffects;
  void onUserIntent(ProfileRegisterDetailsUserIntent intent);
}

class ProfileRegisterDetailsViewState extends ViewState {
  const ProfileRegisterDetailsViewState({
    required this.username,
    required this.fullName,
    required this.nickname,
    required this.occupation,
    required this.requiresOccupation,
    required this.isSubmitting,
  }) : super();

  factory ProfileRegisterDetailsViewState.initial({
    required String username,
    required bool requiresOccupation,
  }) {
    return ProfileRegisterDetailsViewState(
      username: username,
      fullName: '',
      nickname: '',
      occupation: '',
      requiresOccupation: requiresOccupation,
      isSubmitting: false,
    );
  }

  final String username;
  final String fullName;
  final String nickname;
  final String occupation;
  final bool requiresOccupation;
  final bool isSubmitting;

  ProfileRegisterDetailsViewState copyWith({
    String? username,
    String? fullName,
    String? nickname,
    String? occupation,
    bool? requiresOccupation,
    bool? isSubmitting,
  }) {
    return ProfileRegisterDetailsViewState(
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      nickname: nickname ?? this.nickname,
      occupation: occupation ?? this.occupation,
      requiresOccupation: requiresOccupation ?? this.requiresOccupation,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

sealed class ProfileRegisterDetailsUserIntent extends UserIntent {
  const ProfileRegisterDetailsUserIntent() : super();
}

class OnRegisterFullNameChanged extends ProfileRegisterDetailsUserIntent {
  const OnRegisterFullNameChanged(this.value);

  final String value;
}

class OnRegisterNicknameChanged extends ProfileRegisterDetailsUserIntent {
  const OnRegisterNicknameChanged(this.value);

  final String value;
}

class OnRegisterOccupationChanged extends ProfileRegisterDetailsUserIntent {
  const OnRegisterOccupationChanged(this.value);

  final String value;
}

class OnRegisterDetailsContinueClick extends ProfileRegisterDetailsUserIntent {
  const OnRegisterDetailsContinueClick();
}

class OnRegisterDetailsSkipClick extends ProfileRegisterDetailsUserIntent {
  const OnRegisterDetailsSkipClick();
}

class OnRegisterDetailsBackClick extends ProfileRegisterDetailsUserIntent {
  const OnRegisterDetailsBackClick();
}

sealed class ProfileRegisterDetailsNavEffect extends NavEffect {
  const ProfileRegisterDetailsNavEffect() : super();
}

class RegisterDetailsNavigateBack extends ProfileRegisterDetailsNavEffect {
  const RegisterDetailsNavigateBack();
}

class RegisterDetailsNavigateToPhone extends ProfileRegisterDetailsNavEffect {
  const RegisterDetailsNavigateToPhone({
    required this.username,
    required this.password,
    required this.fullName,
    required this.nickname,
    required this.occupation,
    required this.requiresOccupation,
  });

  final String username;
  final String password;
  final String fullName;
  final String nickname;
  final String occupation;
  final bool requiresOccupation;
}
