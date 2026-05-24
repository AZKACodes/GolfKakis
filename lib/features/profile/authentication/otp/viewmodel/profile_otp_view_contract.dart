import 'package:golf_kakis/features/foundation/model/snackbar_message_model.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_contract.dart';
import 'package:golf_kakis/features/profile/api/profile_api_service.dart';

enum ProfileOtpPurpose { login, register, pinReset }

abstract class ProfileOtpViewContract {
  ProfileOtpViewState get viewState;
  Stream<ProfileOtpNavEffect> get navEffects;
  void onUserIntent(ProfileOtpUserIntent intent);
}

class ProfileOtpViewState extends ViewState {
  const ProfileOtpViewState({
    required this.phoneNumber,
    required this.otpDigits,
    required this.isSendingOtp,
    required this.isSubmitting,
    required this.showsResend,
    required this.otpRemainingSeconds,
    required this.maskedDestination,
    required this.successMessage,
    this.errorSnackbarMessageModel = SnackbarMessageModel.emptyValue,
  }) : super();

  factory ProfileOtpViewState.initial({
    required String phoneNumber,
    required bool showsResend,
  }) {
    return ProfileOtpViewState(
      phoneNumber: phoneNumber,
      otpDigits: const ['', '', '', '', '', ''],
      isSendingOtp: false,
      isSubmitting: false,
      showsResend: showsResend,
      otpRemainingSeconds: 0,
      maskedDestination: '',
      successMessage: '',
    );
  }

  final String phoneNumber;
  final List<String> otpDigits;
  final bool isSendingOtp;
  final bool isSubmitting;
  final bool showsResend;
  final int otpRemainingSeconds;
  final String maskedDestination;
  final String successMessage;
  final SnackbarMessageModel errorSnackbarMessageModel;

  String? get errorMessage => errorSnackbarMessageModel.hasMessage
      ? errorSnackbarMessageModel.message
      : null;

  bool get canVerify =>
      otpDigits.every((digit) => digit.trim().isNotEmpty) && !isSubmitting;
  bool get canResend =>
      showsResend && !isSendingOtp && otpRemainingSeconds == 0;
  String get destinationLabel =>
      maskedDestination.trim().isNotEmpty ? maskedDestination : phoneNumber;

  ProfileOtpViewState copyWith({
    String? phoneNumber,
    List<String>? otpDigits,
    bool? isSendingOtp,
    bool? isSubmitting,
    bool? showsResend,
    int? otpRemainingSeconds,
    String? maskedDestination,
    String? successMessage,
    SnackbarMessageModel? errorSnackbarMessageModel,
    bool clearErrorMessage = false,
    bool clearSuccessMessage = false,
  }) {
    return ProfileOtpViewState(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      otpDigits: otpDigits ?? this.otpDigits,
      isSendingOtp: isSendingOtp ?? this.isSendingOtp,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      showsResend: showsResend ?? this.showsResend,
      otpRemainingSeconds: otpRemainingSeconds ?? this.otpRemainingSeconds,
      maskedDestination: maskedDestination ?? this.maskedDestination,
      successMessage: clearSuccessMessage
          ? ''
          : successMessage ?? this.successMessage,
      errorSnackbarMessageModel: clearErrorMessage
          ? SnackbarMessageModel.emptyValue
          : errorSnackbarMessageModel ?? this.errorSnackbarMessageModel,
    );
  }
}

sealed class ProfileOtpUserIntent extends UserIntent {
  const ProfileOtpUserIntent() : super();
}

class OnProfileOtpInit extends ProfileOtpUserIntent {
  const OnProfileOtpInit({required this.visitorId});

  final String visitorId;
}

class OnProfileOtpDigitChanged extends ProfileOtpUserIntent {
  const OnProfileOtpDigitChanged({required this.index, required this.value});

  final int index;
  final String value;
}

class OnProfileOtpVerifyClick extends ProfileOtpUserIntent {
  const OnProfileOtpVerifyClick({required this.visitorId});

  final String visitorId;
}

class OnProfileOtpResendClick extends ProfileOtpUserIntent {
  const OnProfileOtpResendClick({required this.visitorId});

  final String visitorId;
}

class OnProfileOtpBackClick extends ProfileOtpUserIntent {
  const OnProfileOtpBackClick();
}

sealed class ProfileOtpNavEffect extends NavEffect {
  const ProfileOtpNavEffect() : super();
}

class ProfileOtpNavigateBack extends ProfileOtpNavEffect {
  const ProfileOtpNavigateBack();
}

class ProfileOtpVerified extends ProfileOtpNavEffect {
  const ProfileOtpVerified({required this.response, required this.username});

  final VerifyOtpResponse response;
  final String username;
}

class ProfileOtpPinSetupRequired extends ProfileOtpNavEffect {
  const ProfileOtpPinSetupRequired({
    required this.pinSetupToken,
    required this.username,
    required this.phoneNumber,
  });

  final String pinSetupToken;
  final String username;
  final String phoneNumber;
}
