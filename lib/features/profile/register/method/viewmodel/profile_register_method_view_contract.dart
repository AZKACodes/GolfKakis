import 'package:golf_kakis/features/foundation/model/snackbar_message_model.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_contract.dart';

abstract class ProfileRegisterMethodViewContract {
  ProfileRegisterMethodViewState get viewState;
  Stream<ProfileRegisterMethodNavEffect> get navEffects;
  void onUserIntent(ProfileRegisterMethodUserIntent intent);
}

class ProfileRegisterMethodViewState extends ViewState {
  const ProfileRegisterMethodViewState({
    required this.username,
    required this.password,
    required this.confirmPassword,
    required this.isSubmitting,
    this.errorSnackbarMessageModel = SnackbarMessageModel.emptyValue,
  }) : super();

  static const initial = ProfileRegisterMethodViewState(
    username: '',
    password: '',
    confirmPassword: '',
    isSubmitting: false,
  );

  final String username;
  final String password;
  final String confirmPassword;
  final bool isSubmitting;
  final SnackbarMessageModel errorSnackbarMessageModel;

  String? get errorMessage => errorSnackbarMessageModel.hasMessage
      ? errorSnackbarMessageModel.message
      : null;

  bool get canContinue =>
      username.trim().isNotEmpty &&
      password.isNotEmpty &&
      confirmPassword.isNotEmpty &&
      !isSubmitting;

  ProfileRegisterMethodViewState copyWith({
    String? username,
    String? password,
    String? confirmPassword,
    bool? isSubmitting,
    SnackbarMessageModel? errorSnackbarMessageModel,
    bool clearErrorMessage = false,
  }) {
    return ProfileRegisterMethodViewState(
      username: username ?? this.username,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorSnackbarMessageModel: clearErrorMessage
          ? SnackbarMessageModel.emptyValue
          : errorSnackbarMessageModel ?? this.errorSnackbarMessageModel,
    );
  }
}

sealed class ProfileRegisterMethodUserIntent extends UserIntent {
  const ProfileRegisterMethodUserIntent() : super();
}

class OnRegisterUsernameChanged extends ProfileRegisterMethodUserIntent {
  const OnRegisterUsernameChanged(this.value);

  final String value;
}

class OnRegisterPasswordChanged extends ProfileRegisterMethodUserIntent {
  const OnRegisterPasswordChanged(this.value);

  final String value;
}

class OnRegisterConfirmPasswordChanged extends ProfileRegisterMethodUserIntent {
  const OnRegisterConfirmPasswordChanged(this.value);

  final String value;
}

class OnRegisterMethodContinueClick extends ProfileRegisterMethodUserIntent {
  const OnRegisterMethodContinueClick();
}

class OnRegisterMethodBackClick extends ProfileRegisterMethodUserIntent {
  const OnRegisterMethodBackClick();
}

sealed class ProfileRegisterMethodNavEffect extends NavEffect {
  const ProfileRegisterMethodNavEffect() : super();
}

class RegisterMethodNavigateBack extends ProfileRegisterMethodNavEffect {
  const RegisterMethodNavigateBack();
}

class RegisterMethodNavigateToAbout extends ProfileRegisterMethodNavEffect {
  const RegisterMethodNavigateToAbout({
    required this.username,
    required this.password,
  });

  final String username;
  final String password;
}
