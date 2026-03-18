import 'package:golf_kakis/features/foundation/viewmodel/mvi_contract.dart';

abstract class ProfileRegisterOtpViewContract {
  ProfileRegisterOtpViewState get viewState;
  Stream<ProfileRegisterOtpNavEffect> get navEffects;
  void onUserIntent(ProfileRegisterOtpUserIntent intent);
}

class ProfileRegisterOtpViewState extends ViewState {
  const ProfileRegisterOtpViewState({
    required this.phoneNumber,
    required this.otpDigits,
    required this.isSubmitting,
    this.errorMessage,
  }) : super();

  factory ProfileRegisterOtpViewState.initial({required String phoneNumber}) {
    return ProfileRegisterOtpViewState(
      phoneNumber: phoneNumber,
      otpDigits: const ['', '', '', ''],
      isSubmitting: false,
    );
  }

  final String phoneNumber;
  final List<String> otpDigits;
  final bool isSubmitting;
  final String? errorMessage;

  bool get canContinue => otpDigits.every((digit) => digit.trim().isNotEmpty);
  String get otpValue => otpDigits.join();

  ProfileRegisterOtpViewState copyWith({
    String? phoneNumber,
    List<String>? otpDigits,
    bool? isSubmitting,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ProfileRegisterOtpViewState(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      otpDigits: otpDigits ?? this.otpDigits,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}

sealed class ProfileRegisterOtpUserIntent extends UserIntent {
  const ProfileRegisterOtpUserIntent() : super();
}

class OnRegisterOtpDigitChanged extends ProfileRegisterOtpUserIntent {
  const OnRegisterOtpDigitChanged({required this.index, required this.value});

  final int index;
  final String value;
}

class OnRegisterOtpContinueClick extends ProfileRegisterOtpUserIntent {
  const OnRegisterOtpContinueClick();
}

class OnRegisterOtpBackClick extends ProfileRegisterOtpUserIntent {
  const OnRegisterOtpBackClick();
}

sealed class ProfileRegisterOtpNavEffect extends NavEffect {
  const ProfileRegisterOtpNavEffect() : super();
}

class RegisterOtpNavigateBack extends ProfileRegisterOtpNavEffect {
  const RegisterOtpNavigateBack();
}

class RegisterOtpNavigateToAbout extends ProfileRegisterOtpNavEffect {
  const RegisterOtpNavigateToAbout({required this.phoneNumber});

  final String phoneNumber;
}
