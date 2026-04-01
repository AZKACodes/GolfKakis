import 'package:golf_kakis/features/foundation/viewmodel/mvi_contract.dart';
import 'package:golf_kakis/features/foundation/enums/session/user_role.dart';
import 'package:golf_kakis/features/foundation/util/phone_util.dart';

enum LoginMethod { email, phone }

abstract class ProfileLoginViewContract {
  ProfileLoginViewState get viewState;
  Stream<ProfileLoginNavEffect> get navEffects;
  void onUserIntent(ProfileLoginUserIntent intent);
}

class ProfileLoginViewState extends ViewState {
  const ProfileLoginViewState({
    required this.loginMethod,
    required this.email,
    required this.countryCode,
    required this.phoneNumber,
    required this.password,
    required this.isSubmitting,
    this.errorMessage,
    this.infoMessage,
  }) : super();

  static const initial = ProfileLoginViewState(
    loginMethod: LoginMethod.phone,
    email: '',
    countryCode: PhoneUtil.defaultCountryCodeOption,
    phoneNumber: '',
    password: '',
    isSubmitting: false,
  );

  final LoginMethod loginMethod;
  final String email;
  final PhoneCountryCodeOption countryCode;
  final String phoneNumber;
  final String password;
  final bool isSubmitting;
  final String? errorMessage;
  final String? infoMessage;

  bool get canSubmit =>
      loginIdentifier.trim().isNotEmpty &&
      password.trim().isNotEmpty &&
      !isSubmitting;

  String get fullPhoneNumber {
    final normalized = phoneNumber.trim();
    if (normalized.isEmpty) {
      return countryCode.dialCode;
    }

    return '${countryCode.dialCode} $normalized';
  }

  String get loginIdentifier => switch (loginMethod) {
    LoginMethod.email => email.trim(),
    LoginMethod.phone => fullPhoneNumber.trim(),
  };

  ProfileLoginViewState copyWith({
    LoginMethod? loginMethod,
    String? email,
    PhoneCountryCodeOption? countryCode,
    String? phoneNumber,
    String? password,
    bool? isSubmitting,
    String? errorMessage,
    String? infoMessage,
    bool clearErrorMessage = false,
    bool clearInfoMessage = false,
  }) {
    return ProfileLoginViewState(
      loginMethod: loginMethod ?? this.loginMethod,
      email: email ?? this.email,
      countryCode: countryCode ?? this.countryCode,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      password: password ?? this.password,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      infoMessage: clearInfoMessage ? null : infoMessage ?? this.infoMessage,
    );
  }
}

sealed class ProfileLoginUserIntent extends UserIntent {
  const ProfileLoginUserIntent() : super();
}

class OnLoginMethodChanged extends ProfileLoginUserIntent {
  const OnLoginMethodChanged(this.value);

  final LoginMethod value;
}

class OnEmailChanged extends ProfileLoginUserIntent {
  const OnEmailChanged(this.value);

  final String value;
}

class OnCountryCodeChanged extends ProfileLoginUserIntent {
  const OnCountryCodeChanged(this.value);

  final PhoneCountryCodeOption value;
}

class OnPhoneChanged extends ProfileLoginUserIntent {
  const OnPhoneChanged(this.value);

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

class OnRegisterClick extends ProfileLoginUserIntent {
  const OnRegisterClick();
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

class RegisterRequested extends ProfileLoginNavEffect {
  const RegisterRequested();
}
