import 'package:golf_kakis/features/foundation/model/snackbar_message_model.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_contract.dart';
import 'package:golf_kakis/features/profile/api/profile_api_service.dart';

abstract class ProfileRegisterPhoneViewContract {
  ProfileRegisterPhoneViewState get viewState;
  Stream<ProfileRegisterPhoneNavEffect> get navEffects;
  void onUserIntent(ProfileRegisterPhoneUserIntent intent);
}

class ProfileRegisterPhoneViewState extends ViewState {
  const ProfileRegisterPhoneViewState({
    required this.username,
    required this.password,
    required this.fullName,
    required this.nickname,
    required this.occupation,
    required this.requiresOccupation,
    required this.phoneNumber,
    required this.isSubmitting,
    this.errorSnackbarMessageModel = SnackbarMessageModel.emptyValue,
  }) : super();

  factory ProfileRegisterPhoneViewState.initial({
    required String username,
    required String password,
    required String fullName,
    required String nickname,
    required String occupation,
    required bool requiresOccupation,
  }) {
    return ProfileRegisterPhoneViewState(
      username: username,
      password: password,
      fullName: fullName,
      nickname: nickname,
      occupation: occupation,
      requiresOccupation: requiresOccupation,
      phoneNumber: '',
      isSubmitting: false,
    );
  }

  final String username;
  final String password;
  final String fullName;
  final String nickname;
  final String occupation;
  final bool requiresOccupation;
  final String phoneNumber;
  final bool isSubmitting;
  final SnackbarMessageModel errorSnackbarMessageModel;

  String? get errorMessage => errorSnackbarMessageModel.hasMessage
      ? errorSnackbarMessageModel.message
      : null;

  ProfileRegisterPhoneViewState copyWith({
    String? username,
    String? password,
    String? fullName,
    String? nickname,
    String? occupation,
    bool? requiresOccupation,
    String? phoneNumber,
    bool? isSubmitting,
    SnackbarMessageModel? errorSnackbarMessageModel,
    bool clearErrorMessage = false,
  }) {
    return ProfileRegisterPhoneViewState(
      username: username ?? this.username,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,
      nickname: nickname ?? this.nickname,
      occupation: occupation ?? this.occupation,
      requiresOccupation: requiresOccupation ?? this.requiresOccupation,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorSnackbarMessageModel: clearErrorMessage
          ? SnackbarMessageModel.emptyValue
          : errorSnackbarMessageModel ?? this.errorSnackbarMessageModel,
    );
  }
}

sealed class ProfileRegisterPhoneUserIntent extends UserIntent {
  const ProfileRegisterPhoneUserIntent() : super();
}

class OnRegisterPhoneChanged extends ProfileRegisterPhoneUserIntent {
  const OnRegisterPhoneChanged(this.value);

  final String value;
}

class OnRegisterPhoneContinueClick extends ProfileRegisterPhoneUserIntent {
  const OnRegisterPhoneContinueClick({required this.visitorId});

  final String visitorId;
}

class OnRegisterPhoneBackClick extends ProfileRegisterPhoneUserIntent {
  const OnRegisterPhoneBackClick();
}

sealed class ProfileRegisterPhoneNavEffect extends NavEffect {
  const ProfileRegisterPhoneNavEffect() : super();
}

class RegisterPhoneNavigateBack extends ProfileRegisterPhoneNavEffect {
  const RegisterPhoneNavigateBack();
}

class RegisterPhoneRequestOtpSucceeded extends ProfileRegisterPhoneNavEffect {
  const RegisterPhoneRequestOtpSucceeded({
    required this.response,
    required this.username,
    required this.password,
    required this.fullName,
    required this.nickname,
    required this.occupation,
    required this.requiresOccupation,
  });

  final RequestOtpResponse response;
  final String username;
  final String password;
  final String fullName;
  final String nickname;
  final String occupation;
  final bool requiresOccupation;
}
