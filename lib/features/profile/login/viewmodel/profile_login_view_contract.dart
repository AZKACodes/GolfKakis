import 'package:golf_kakis/features/foundation/model/snackbar_message_model.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_contract.dart';
import 'package:golf_kakis/features/profile/api/profile_api_service.dart';

abstract class ProfileLoginViewContract {
  ProfileLoginViewState get viewState;
  Stream<ProfileLoginNavEffect> get navEffects;
  void onUserIntent(ProfileLoginUserIntent intent);
}

sealed class ProfileLoginViewState extends ViewState {
  const ProfileLoginViewState() : super();
}

class ProfileLoginDataLoaded extends ProfileLoginViewState {
  const ProfileLoginDataLoaded({
    required this.username,
    required this.password,
    required this.isSubmitting,
    this.errorSnackbarMessageModel = SnackbarMessageModel.emptyValue,
    this.infoSnackbarMessageModel = SnackbarMessageModel.emptyValue,
  }) : super();

  static const initial = ProfileLoginDataLoaded(
    username: '',
    password: '',
    isSubmitting: false,
  );

  final String username;
  final String password;
  final bool isSubmitting;
  final SnackbarMessageModel errorSnackbarMessageModel;
  final SnackbarMessageModel infoSnackbarMessageModel;

  String? get errorMessage => errorSnackbarMessageModel.hasMessage
      ? errorSnackbarMessageModel.message
      : null;

  String? get infoMessage => infoSnackbarMessageModel.hasMessage
      ? infoSnackbarMessageModel.message
      : null;

  bool get canSubmit =>
      username.trim().isNotEmpty && password.trim().isNotEmpty && !isSubmitting;

  ProfileLoginDataLoaded copyWith({
    String? username,
    String? password,
    bool? isSubmitting,
    SnackbarMessageModel? errorSnackbarMessageModel,
    SnackbarMessageModel? infoSnackbarMessageModel,
    bool clearErrorMessage = false,
    bool clearInfoMessage = false,
  }) {
    return ProfileLoginDataLoaded(
      username: username ?? this.username,
      password: password ?? this.password,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorSnackbarMessageModel: clearErrorMessage
          ? SnackbarMessageModel.emptyValue
          : errorSnackbarMessageModel ?? this.errorSnackbarMessageModel,
      infoSnackbarMessageModel: clearInfoMessage
          ? SnackbarMessageModel.emptyValue
          : infoSnackbarMessageModel ?? this.infoSnackbarMessageModel,
    );
  }
}

sealed class ProfileLoginUserIntent extends UserIntent {
  const ProfileLoginUserIntent() : super();
}

class OnUsernameChanged extends ProfileLoginUserIntent {
  const OnUsernameChanged(this.value);

  final String value;
}

class OnPasswordChanged extends ProfileLoginUserIntent {
  const OnPasswordChanged(this.value);

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

sealed class ProfileLoginNavEffect extends NavEffect {
  const ProfileLoginNavEffect() : super();
}

class NavigateBack extends ProfileLoginNavEffect {
  const NavigateBack();
}

class RequestOtpSucceeded extends ProfileLoginNavEffect {
  const RequestOtpSucceeded({required this.response, required this.username});

  final RequestOtpResponse response;
  final String username;
}

class RegisterRequested extends ProfileLoginNavEffect {
  const RegisterRequested();
}
