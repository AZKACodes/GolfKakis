import 'package:golf_kakis/features/foundation/viewmodel/mvi_contract.dart';
import 'package:golf_kakis/features/profile/api/profile_api_service.dart';

abstract class ProfileLoginOtpViewContract {
  ProfileLoginOtpViewState get viewState;
  Stream<ProfileLoginOtpNavEffect> get navEffects;
  void onUserIntent(ProfileLoginOtpUserIntent intent);
}

// ------ View State ------

sealed class ProfileLoginOtpViewState extends ViewState {
  const ProfileLoginOtpViewState() : super();
}

class ProfileLoginOtpDataLoaded extends ProfileLoginOtpViewState {
  const ProfileLoginOtpDataLoaded({
    required this.name,
    required this.phoneNumber,
    required this.otpDigits,
    required this.isSubmitting,
    this.errorMessage,
  }) : super();

  factory ProfileLoginOtpDataLoaded.initial({
    required String name,
    required String phoneNumber,
  }) {
    return ProfileLoginOtpDataLoaded(
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

  ProfileLoginOtpDataLoaded copyWith({
    String? name,
    String? phoneNumber,
    List<String>? otpDigits,
    bool? isSubmitting,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ProfileLoginOtpDataLoaded(
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

// ------ UserIntent ------

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

// ------ NavEffect ------

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
