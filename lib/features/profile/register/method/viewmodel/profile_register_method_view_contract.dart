import 'package:golf_kakis/features/foundation/util/phone_util.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_contract.dart';

enum RegisterMethod { phone, email }

abstract class ProfileRegisterMethodViewContract {
  ProfileRegisterMethodViewState get viewState;
  Stream<ProfileRegisterMethodNavEffect> get navEffects;
  void onUserIntent(ProfileRegisterMethodUserIntent intent);
}

class ProfileRegisterMethodViewState extends ViewState {
  const ProfileRegisterMethodViewState({
    required this.selectedMethod,
    required this.countryCode,
    required this.phoneNumber,
    required this.isSubmitting,
    this.errorMessage,
    this.infoMessage,
  }) : super();

  static const initial = ProfileRegisterMethodViewState(
    selectedMethod: RegisterMethod.phone,
    countryCode: PhoneUtil.defaultCountryCodeOption,
    phoneNumber: '',
    isSubmitting: false,
  );

  final RegisterMethod selectedMethod;
  final PhoneCountryCodeOption countryCode;
  final String phoneNumber;
  final bool isSubmitting;
  final String? errorMessage;
  final String? infoMessage;

  bool get canContinuePhone => phoneNumber.trim().isNotEmpty && !isSubmitting;

  String get fullPhoneNumber {
    final normalized = phoneNumber.trim();
    if (normalized.isEmpty) {
      return countryCode.dialCode;
    }

    return '${countryCode.dialCode} $normalized';
  }

  ProfileRegisterMethodViewState copyWith({
    RegisterMethod? selectedMethod,
    PhoneCountryCodeOption? countryCode,
    String? phoneNumber,
    bool? isSubmitting,
    String? errorMessage,
    String? infoMessage,
    bool clearErrorMessage = false,
    bool clearInfoMessage = false,
  }) {
    return ProfileRegisterMethodViewState(
      selectedMethod: selectedMethod ?? this.selectedMethod,
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

sealed class ProfileRegisterMethodUserIntent extends UserIntent {
  const ProfileRegisterMethodUserIntent() : super();
}

class OnRegisterMethodSelected extends ProfileRegisterMethodUserIntent {
  const OnRegisterMethodSelected(this.method);

  final RegisterMethod method;
}

class OnRegisterPhoneChanged extends ProfileRegisterMethodUserIntent {
  const OnRegisterPhoneChanged(this.value);

  final String value;
}

class OnRegisterCountryCodeSelected extends ProfileRegisterMethodUserIntent {
  const OnRegisterCountryCodeSelected(this.value);

  final PhoneCountryCodeOption value;
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

class RegisterMethodNavigateToOtp extends ProfileRegisterMethodNavEffect {
  const RegisterMethodNavigateToOtp(this.phoneNumber);

  final String phoneNumber;
}
