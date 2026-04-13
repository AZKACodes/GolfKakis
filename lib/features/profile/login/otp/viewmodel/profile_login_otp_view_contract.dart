import 'package:golf_kakis/features/foundation/viewmodel/mvi_contract.dart';
import 'package:golf_kakis/features/profile/api/profile_api_service.dart';

abstract class ProfileLoginOtpViewContract {
  ProfileLoginOtpViewState get viewState;
  Stream<ProfileLoginOtpNavEffect> get navEffects;
  void onUserIntent(ProfileLoginOtpUserIntent intent);
}

class ProfileLoginOtpViewState extends ViewState {
  const ProfileLoginOtpViewState({
    required this.name,
    required this.phoneNumber,
    required this.otpDigits,
    required this.isSubmitting,
    this.errorMessage,
  }) : super();

  factory ProfileLoginOtpViewState.initial({
    required String name,
    required String phoneNumber,
  }) {
    return ProfileLoginOtpViewState(
      name: name,
      phoneNumber: phoneNumber,
      otpDigits: const ['', '', '', '', '', ''],
      isSubmitting: false,
    );
  }

  final String name;
  final String phoneNumber;
  final List<String> otpDigits;
  final bool isSubmitting;
  final String? errorMessage;

  bool get canVerify =>
      otpDigits.every((digit) => digit.trim().isNotEmpty) && !isSubmitting;

  ProfileLoginOtpViewState copyWith({
    String? name,
    String? phoneNumber,
    List<String>? otpDigits,
    bool? isSubmitting,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ProfileLoginOtpViewState(
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      otpDigits: otpDigits ?? this.otpDigits,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}

sealed class ProfileLoginOtpUserIntent extends UserIntent {
  const ProfileLoginOtpUserIntent() : super();
}

class OnLoginOtpDigitChanged extends ProfileLoginOtpUserIntent {
  const OnLoginOtpDigitChanged({required this.index, required this.value});

  final int index;
  final String value;
}

class OnLoginOtpVerifyClick extends ProfileLoginOtpUserIntent {
  const OnLoginOtpVerifyClick({required this.visitorId});

  final String visitorId;
}

class OnLoginOtpBackClick extends ProfileLoginOtpUserIntent {
  const OnLoginOtpBackClick();
}

sealed class ProfileLoginOtpNavEffect extends NavEffect {
  const ProfileLoginOtpNavEffect() : super();
}

class LoginOtpNavigateBack extends ProfileLoginOtpNavEffect {
  const LoginOtpNavigateBack();
}

class LoginOtpVerified extends ProfileLoginOtpNavEffect {
  const LoginOtpVerified({required this.response});

  final VerifyOtpResponse response;
}
