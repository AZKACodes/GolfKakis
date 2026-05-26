import 'package:golf_kakis/features/foundation/model/snackbar_message_model.dart';
import 'package:golf_kakis/features/foundation/util/phone_util.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_contract.dart';

abstract class ProfileRegisterViewContract {
  ProfileRegisterViewState get viewState;
  Stream<ProfileRegisterNavEffect> get navEffects;
  void onUserIntent(ProfileRegisterUserIntent intent);
}

class ProfileRegisterViewState extends ViewState {
  const ProfileRegisterViewState({
    required this.name,
    required this.phoneNumber,
    required this.isSubmitting,
    this.errorSnackbarMessageModel = SnackbarMessageModel.emptyValue,
  }) : super();

  static const initial = ProfileRegisterViewState(
    name: '',
    phoneNumber: '',
    isSubmitting: false,
  );

  final String name;
  final String phoneNumber;
  final bool isSubmitting;
  final SnackbarMessageModel errorSnackbarMessageModel;

  String? get errorMessage => errorSnackbarMessageModel.hasMessage
      ? errorSnackbarMessageModel.message
      : null;

  bool get canContinue =>
      name.trim().isNotEmpty &&
      PhoneUtil.splitPhoneNumber(phoneNumber).localNumber.trim().isNotEmpty &&
      !isSubmitting;

  ProfileRegisterViewState copyWith({
    String? name,
    String? phoneNumber,
    bool? isSubmitting,
    SnackbarMessageModel? errorSnackbarMessageModel,
    bool clearErrorMessage = false,
  }) {
    return ProfileRegisterViewState(
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorSnackbarMessageModel: clearErrorMessage
          ? SnackbarMessageModel.emptyValue
          : errorSnackbarMessageModel ?? this.errorSnackbarMessageModel,
    );
  }
}

sealed class ProfileRegisterUserIntent extends UserIntent {
  const ProfileRegisterUserIntent() : super();
}

class OnRegisterNameChanged extends ProfileRegisterUserIntent {
  const OnRegisterNameChanged(this.value);

  final String value;
}

class OnRegisterPhoneChanged extends ProfileRegisterUserIntent {
  const OnRegisterPhoneChanged(this.value);

  final String value;
}

class OnRegisterContinueClick extends ProfileRegisterUserIntent {
  const OnRegisterContinueClick();
}

class OnRegisterBackClick extends ProfileRegisterUserIntent {
  const OnRegisterBackClick();
}

sealed class ProfileRegisterNavEffect extends NavEffect {
  const ProfileRegisterNavEffect() : super();
}

class RegisterNavigateBack extends ProfileRegisterNavEffect {
  const RegisterNavigateBack();
}

class RegisterSubmitted extends ProfileRegisterNavEffect {
  const RegisterSubmitted({required this.name, required this.phoneNumber});

  final String name;
  final String phoneNumber;
}
