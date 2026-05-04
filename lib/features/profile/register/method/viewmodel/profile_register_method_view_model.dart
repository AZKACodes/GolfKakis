import 'package:golf_kakis/features/foundation/model/snackbar_message_model.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_view_model.dart';

import 'profile_register_method_view_contract.dart';

class ProfileRegisterMethodViewModel
    extends
        MviViewModel<
          ProfileRegisterMethodUserIntent,
          ProfileRegisterMethodViewState,
          ProfileRegisterMethodNavEffect
        >
    implements ProfileRegisterMethodViewContract {
  @override
  ProfileRegisterMethodViewState createInitialState() {
    return ProfileRegisterMethodViewState.initial;
  }

  @override
  Future<void> handleIntent(ProfileRegisterMethodUserIntent intent) async {
    switch (intent) {
      case OnRegisterUsernameChanged():
        emitViewState(
          (state) =>
              state.copyWith(username: intent.value, clearErrorMessage: true),
        );
      case OnRegisterPasswordChanged():
        emitViewState(
          (state) =>
              state.copyWith(password: intent.value, clearErrorMessage: true),
        );
      case OnRegisterConfirmPasswordChanged():
        emitViewState(
          (state) => state.copyWith(
            confirmPassword: intent.value,
            clearErrorMessage: true,
          ),
        );
      case OnRegisterMethodContinueClick():
        await _continueRegistration();
      case OnRegisterMethodBackClick():
        sendNavEffect(() => const RegisterMethodNavigateBack());
    }
  }

  Future<void> _continueRegistration() async {
    if (!currentState.canContinue) {
      emitViewState(
        (state) => state.copyWith(
          errorSnackbarMessageModel: const SnackbarMessageModel(
            message:
                'Enter your username, password, and confirm your password to continue.',
          ),
        ),
      );
      return;
    }

    if (currentState.password != currentState.confirmPassword) {
      emitViewState(
        (state) => state.copyWith(
          errorSnackbarMessageModel: const SnackbarMessageModel(
            message: 'Password and confirm password must match.',
          ),
        ),
      );
      return;
    }

    if (currentState.password.length < 6) {
      emitViewState(
        (state) => state.copyWith(
          errorSnackbarMessageModel: const SnackbarMessageModel(
            message: 'Password must be at least 6 characters.',
          ),
        ),
      );
      return;
    }

    sendNavEffect(
      () => RegisterMethodNavigateToAbout(
        username: currentState.username.trim(),
        password: currentState.password,
      ),
    );
  }
}
