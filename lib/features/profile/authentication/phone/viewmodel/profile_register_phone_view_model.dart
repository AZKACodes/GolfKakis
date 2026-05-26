import 'package:golf_kakis/features/foundation/model/snackbar_message_model.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_view_model.dart';

import 'profile_register_phone_view_contract.dart';

class ProfileRegisterPhoneViewModel
    extends
        MviViewModel<
          ProfileRegisterPhoneUserIntent,
          ProfileRegisterPhoneViewState,
          ProfileRegisterPhoneNavEffect
        >
    implements ProfileRegisterPhoneViewContract {
  ProfileRegisterPhoneViewModel({
    required String username,
    required String password,
    required String fullName,
    required String nickname,
    required String occupation,
    required bool requiresOccupation,
  }) : _username = username,
       _password = password,
       _fullName = fullName,
       _nickname = nickname,
       _occupation = occupation,
       _requiresOccupation = requiresOccupation;

  final String _username;
  final String _password;
  final String _fullName;
  final String _nickname;
  final String _occupation;
  final bool _requiresOccupation;

  @override
  ProfileRegisterPhoneViewState createInitialState() {
    return ProfileRegisterPhoneViewState.initial(
      username: _username,
      password: _password,
      fullName: _fullName,
      nickname: _nickname,
      occupation: _occupation,
      requiresOccupation: _requiresOccupation,
    );
  }

  @override
  Future<void> handleIntent(ProfileRegisterPhoneUserIntent intent) async {
    switch (intent) {
      case OnRegisterPhoneChanged():
        emitViewState(
          (state) => state.copyWith(
            phoneNumber: intent.value,
            clearErrorMessage: true,
          ),
        );
      case OnRegisterPhoneContinueClick():
        _continueToOtp();
      case OnRegisterPhoneBackClick():
        sendNavEffect(() => const RegisterPhoneNavigateBack());
    }
  }

  void _continueToOtp() {
    final phoneNumber = currentState.phoneNumber.trim();
    if (phoneNumber.isEmpty) {
      emitViewState(
        (state) => state.copyWith(
          errorSnackbarMessageModel: const SnackbarMessageModel(
            message: 'Enter your phone number to continue.',
          ),
        ),
      );
      return;
    }

    sendNavEffect(
      () => RegisterPhoneOtpRequested(
        phoneNumber: phoneNumber,
        username: currentState.username.trim(),
        password: currentState.password,
        fullName: currentState.fullName.trim(),
        nickname: currentState.nickname.trim(),
        occupation: currentState.occupation.trim(),
        requiresOccupation: currentState.requiresOccupation,
      ),
    );
  }
}
