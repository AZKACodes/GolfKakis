import 'package:golf_kakis/features/foundation/model/snackbar_message_model.dart';
import 'package:golf_kakis/features/foundation/model/response/setup_user_pin_response.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_contract.dart';

enum ProfilePinMode { setup, login }

abstract class ProfilePinViewContract {
  ProfilePinViewState get viewState;
  Stream<ProfilePinNavEffect> get navEffects;
  void onUserIntent(ProfilePinUserIntent intent);
}

class ProfilePinViewState extends ViewState {
  const ProfilePinViewState({
    required this.pin,
    required this.confirmPin,
    required this.isSubmitting,
    required this.mode,
    required this.hasOTPFallback,
    this.errorSnackbarMessageModel = SnackbarMessageModel.emptyValue,
  }) : super();

  factory ProfilePinViewState.initial({
    required ProfilePinMode mode,
    required bool hasOTPFallback,
  }) {
    return ProfilePinViewState(
      pin: '',
      confirmPin: '',
      isSubmitting: false,
      mode: mode,
      hasOTPFallback: hasOTPFallback,
    );
  }

  final String pin;
  final String confirmPin;
  final bool isSubmitting;
  final ProfilePinMode mode;
  final bool hasOTPFallback;
  final SnackbarMessageModel errorSnackbarMessageModel;

  String? get errorMessage => errorSnackbarMessageModel.hasMessage
      ? errorSnackbarMessageModel.message
      : null;
  bool get hasCompletePin => pin.length == 6;
  bool get hasCompleteConfirmPin => confirmPin.length == 6;
  bool get pinsMatch => pin == confirmPin;
  bool get canSubmit {
    if (mode == ProfilePinMode.login) {
      return hasCompletePin && !isSubmitting;
    }
    return hasCompletePin &&
        hasCompleteConfirmPin &&
        pinsMatch &&
        !isSubmitting;
  }

  ProfilePinViewState copyWith({
    String? pin,
    String? confirmPin,
    bool? isSubmitting,
    ProfilePinMode? mode,
    bool? hasOTPFallback,
    SnackbarMessageModel? errorSnackbarMessageModel,
    bool clearErrorMessage = false,
  }) {
    return ProfilePinViewState(
      pin: pin ?? this.pin,
      confirmPin: confirmPin ?? this.confirmPin,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      mode: mode ?? this.mode,
      hasOTPFallback: hasOTPFallback ?? this.hasOTPFallback,
      errorSnackbarMessageModel: clearErrorMessage
          ? SnackbarMessageModel.emptyValue
          : errorSnackbarMessageModel ?? this.errorSnackbarMessageModel,
    );
  }
}

sealed class ProfilePinUserIntent extends UserIntent {
  const ProfilePinUserIntent() : super();
}

class OnProfilePinChanged extends ProfilePinUserIntent {
  const OnProfilePinChanged(this.value);

  final String value;
}

class OnProfileConfirmPinChanged extends ProfilePinUserIntent {
  const OnProfileConfirmPinChanged(this.value);

  final String value;
}

class OnProfilePinSubmitClick extends ProfilePinUserIntent {
  const OnProfilePinSubmitClick();
}

class OnProfilePinBackClick extends ProfilePinUserIntent {
  const OnProfilePinBackClick();
}

class OnProfileForgotPinClick extends ProfilePinUserIntent {
  const OnProfileForgotPinClick();
}

sealed class ProfilePinNavEffect extends NavEffect {
  const ProfilePinNavEffect() : super();
}

class ProfilePinNavigateBack extends ProfilePinNavEffect {
  const ProfilePinNavigateBack();
}

class ProfilePinSetupCompleted extends ProfilePinNavEffect {
  const ProfilePinSetupCompleted(this.response);

  final SetupUserPinResponse response;
}

class ProfileForgotPinRequested extends ProfilePinNavEffect {
  const ProfileForgotPinRequested();
}
