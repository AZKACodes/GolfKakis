import 'package:golf_kakis/features/foundation/viewmodel/mvi_contract.dart';
import 'package:golf_kakis/features/foundation/enums/session/user_role.dart';

abstract class ProfileLoginViewContract {
  ProfileLoginViewState get viewState;
  Stream<ProfileLoginNavEffect> get navEffects;
  void onUserIntent(ProfileLoginUserIntent intent);
}

class ProfileLoginViewState extends ViewState {
  const ProfileLoginViewState({
    required this.email,
    required this.password,
    required this.isSubmitting,
    this.errorMessage,
  }) : super();

  static const initial = ProfileLoginViewState(
    email: '',
    password: '',
    isSubmitting: false,
  );

  final String email;
  final String password;
  final bool isSubmitting;
  final String? errorMessage;

  bool get canSubmit =>
      email.trim().isNotEmpty && password.trim().isNotEmpty && !isSubmitting;

  ProfileLoginViewState copyWith({
    String? email,
    String? password,
    bool? isSubmitting,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ProfileLoginViewState(
      email: email ?? this.email,
      password: password ?? this.password,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}

sealed class ProfileLoginUserIntent extends UserIntent {
  const ProfileLoginUserIntent() : super();
}

class OnEmailChanged extends ProfileLoginUserIntent {
  const OnEmailChanged(this.value);

  final String value;
}

class OnPasswordChanged extends ProfileLoginUserIntent {
  const OnPasswordChanged(this.value);

  final String value;
}

class OnLoginClick extends ProfileLoginUserIntent {
  const OnLoginClick(this.role);

  final UserRole role;
}

class OnBackClick extends ProfileLoginUserIntent {
  const OnBackClick();
}

sealed class ProfileLoginNavEffect extends NavEffect {
  const ProfileLoginNavEffect() : super();
}

class NavigateBack extends ProfileLoginNavEffect {
  const NavigateBack();
}

class LoginSucceeded extends ProfileLoginNavEffect {
  const LoginSucceeded({required this.username, required this.role});

  final String username;
  final UserRole role;
}
