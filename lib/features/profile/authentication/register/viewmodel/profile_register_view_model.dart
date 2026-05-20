import 'package:golf_kakis/features/foundation/model/snackbar_message_model.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_view_model.dart';

import 'profile_register_view_contract.dart';

class ProfileRegisterViewModel
    extends
        MviViewModel<
          ProfileRegisterUserIntent,
          ProfileRegisterViewState,
          ProfileRegisterNavEffect
        >
    implements ProfileRegisterViewContract {
  ProfileRegisterViewModel();

  @override
  ProfileRegisterViewState createInitialState() {
    return ProfileRegisterViewState.initial;
  }

  @override
  Future<void> handleIntent(ProfileRegisterUserIntent intent) async {
    switch (intent) {
      case OnRegisterNameChanged():
        emitViewState(
          (state) =>
              state.copyWith(name: intent.value, clearErrorMessage: true),
        );
      case OnRegisterPhoneChanged():
        emitViewState(
          (state) => state.copyWith(
            phoneNumber: intent.value,
            clearErrorMessage: true,
          ),
        );
      case OnRegisterContinueClick():
        _submit();
      case OnRegisterBackClick():
        sendNavEffect(() => const RegisterNavigateBack());
    }
  }

  void _submit() {
    if (!currentState.canContinue) {
      emitViewState(
        (state) => state.copyWith(
          errorSnackbarMessageModel: const SnackbarMessageModel(
            message: 'Enter your name and phone number to continue.',
          ),
        ),
      );
      return;
    }

    sendNavEffect(
      () => RegisterSubmitted(
        name: currentState.name.trim(),
        phoneNumber: currentState.phoneNumber.trim(),
      ),
    );
  }
}
