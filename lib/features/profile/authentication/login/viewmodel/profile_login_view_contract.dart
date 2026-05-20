import 'package:golf_kakis/features/foundation/model/snackbar_message_model.dart';
import 'package:golf_kakis/features/foundation/util/phone_util.dart';
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
    required this.phoneNumber,
    required this.isSubmitting,
    this.errorSnackbarMessageModel = SnackbarMessageModel.emptyValue,
    this.infoSnackbarMessageModel = SnackbarMessageModel.emptyValue,
  }) : super();

  static const initial = ProfileLoginDataLoaded(
    phoneNumber: '',
    isSubmitting: false,
  );

  final String phoneNumber;
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
      PhoneUtil.splitPhoneNumber(phoneNumber).localNumber.trim().length >= 8 &&
      !isSubmitting;

  ProfileLoginDataLoaded copyWith({
    String? phoneNumber,
    bool? isSubmitting,
    SnackbarMessageModel? errorSnackbarMessageModel,
    SnackbarMessageModel? infoSnackbarMessageModel,
    bool clearErrorMessage = false,
    bool clearInfoMessage = false,
  }) {
    return ProfileLoginDataLoaded(
      phoneNumber: phoneNumber ?? this.phoneNumber,
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

class OnLoginPhoneChanged extends ProfileLoginUserIntent {
  const OnLoginPhoneChanged(this.value);

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

class LoginMethodsLoaded extends ProfileLoginNavEffect {
  const LoginMethodsLoaded({required this.response, required this.phoneNumber});

  final LoginMethodsResponse response;
  final String phoneNumber;
}

class RegisterRequested extends ProfileLoginNavEffect {
  const RegisterRequested();
}
