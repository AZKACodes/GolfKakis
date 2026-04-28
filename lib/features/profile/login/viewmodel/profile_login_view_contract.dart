import 'package:golf_kakis/features/foundation/viewmodel/mvi_contract.dart';
import 'package:golf_kakis/features/foundation/enums/session/user_role.dart';
import 'package:golf_kakis/features/foundation/util/phone_util.dart';
import 'package:golf_kakis/features/profile/api/profile_api_service.dart';

abstract class ProfileLoginViewContract {
  ProfileLoginViewState get viewState;
  Stream<ProfileLoginNavEffect> get navEffects;
  void onUserIntent(ProfileLoginUserIntent intent);
}

// ------ View State ------

sealed class ProfileLoginViewState extends ViewState {
  const ProfileLoginViewState() : super();
}

class ProfileLoginDataLoaded extends ProfileLoginViewState {
  const ProfileLoginDataLoaded({
    required this.name,
    required this.countryCode,
    required this.phoneNumber,
    required this.isSubmitting,
    this.errorMessage,
    this.infoMessage,
  }) : super();

  static const initial = ProfileLoginDataLoaded(
    name: '',
    countryCode: PhoneUtil.defaultCountryCodeOption,
    phoneNumber: '',
    isSubmitting: false,
  );

  final String name;
  final PhoneCountryCodeOption countryCode;
  final String phoneNumber;
  final bool isSubmitting;
  final String? errorMessage;
  final String? infoMessage;

  bool get canSubmit =>
      name.trim().isNotEmpty && phoneNumber.trim().isNotEmpty && !isSubmitting;

  String get fullPhoneNumber {
    final normalized = phoneNumber.trim();
    if (normalized.isEmpty) {
      return countryCode.dialCode;
    }

    return '${countryCode.dialCode} $normalized';
  }

  ProfileLoginDataLoaded copyWith({
    String? name,
    PhoneCountryCodeOption? countryCode,
    String? phoneNumber,
    bool? isSubmitting,
    String? errorMessage,
    String? infoMessage,
    bool clearErrorMessage = false,
    bool clearInfoMessage = false,
  }) {
    return ProfileLoginDataLoaded(
      name: name ?? this.name,
      countryCode: countryCode ?? this.countryCode,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      infoMessage: clearInfoMessage ? null : infoMessage ?? this.infoMessage,
    );
  }
}

// ------ UserIntent ------

sealed class ProfileLoginUserIntent extends UserIntent {
  const ProfileLoginUserIntent() : super();
}

class OnNameChanged extends ProfileLoginUserIntent {
  const OnNameChanged(this.value);

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

class OnLoginClick extends ProfileLoginUserIntent {
  const OnLoginClick({required this.visitorId});

  final String visitorId;
}

class OnBackClick extends ProfileLoginUserIntent {
  const OnBackClick();
}

class OnRegisterClick extends ProfileLoginUserIntent {
  const OnRegisterClick();
}

// ------ NavEffect ------

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

class RequestOtpSucceeded extends ProfileLoginNavEffect {
  const RequestOtpSucceeded({required this.response});

  final RequestOtpResponse response;
}

class RegisterRequested extends ProfileLoginNavEffect {
  const RegisterRequested();
}
