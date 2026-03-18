import 'package:golf_kakis/features/foundation/viewmodel/mvi_contract.dart';

abstract class ProfileRegisterDetailsViewContract {
  ProfileRegisterDetailsViewState get viewState;
  Stream<ProfileRegisterDetailsNavEffect> get navEffects;
  void onUserIntent(ProfileRegisterDetailsUserIntent intent);
}

class ProfileRegisterDetailsViewState extends ViewState {
  const ProfileRegisterDetailsViewState({
    required this.phoneNumber,
    required this.name,
    required this.nickname,
    required this.occupation,
    required this.isSubmitting,
    this.errorMessage,
  }) : super();

  factory ProfileRegisterDetailsViewState.initial({
    required String phoneNumber,
  }) {
    return ProfileRegisterDetailsViewState(
      phoneNumber: phoneNumber,
      name: '',
      nickname: '',
      occupation: '',
      isSubmitting: false,
    );
  }

  final String phoneNumber;
  final String name;
  final String nickname;
  final String occupation;
  final bool isSubmitting;
  final String? errorMessage;

  bool get canSubmit =>
      name.trim().isNotEmpty &&
      nickname.trim().isNotEmpty &&
      occupation.trim().isNotEmpty &&
      !isSubmitting;

  ProfileRegisterDetailsViewState copyWith({
    String? phoneNumber,
    String? name,
    String? nickname,
    String? occupation,
    bool? isSubmitting,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ProfileRegisterDetailsViewState(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      occupation: occupation ?? this.occupation,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}

sealed class ProfileRegisterDetailsUserIntent extends UserIntent {
  const ProfileRegisterDetailsUserIntent() : super();
}

class OnRegisterNameChanged extends ProfileRegisterDetailsUserIntent {
  const OnRegisterNameChanged(this.value);

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

class OnRegisterDetailsSubmitClick extends ProfileRegisterDetailsUserIntent {
  const OnRegisterDetailsSubmitClick();
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

class RegisterDetailsCompleted extends ProfileRegisterDetailsNavEffect {
  const RegisterDetailsCompleted({
    required this.fullName,
    required this.nickname,
    required this.occupation,
    required this.email,
    required this.phoneNumber,
  });

  final String fullName;
  final String nickname;
  final String occupation;
  final String email;
  final String phoneNumber;
}
