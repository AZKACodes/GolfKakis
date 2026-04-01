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
      case OnRegisterMethodSelected():
        emitViewState(
          (state) => state.copyWith(
            selectedMethod: intent.method,
            infoMessage: intent.method == RegisterMethod.email
                ? 'Email registration is coming soon. Use phone to continue for now.'
                : null,
            clearErrorMessage: true,
            clearInfoMessage: intent.method == RegisterMethod.phone,
          ),
        );
      case OnRegisterPhoneChanged():
        emitViewState(
          (state) => state.copyWith(
            phoneNumber: intent.value,
            clearErrorMessage: true,
            clearInfoMessage: true,
          ),
        );
      case OnRegisterCountryCodeSelected():
        emitViewState(
          (state) => state.copyWith(
            countryCode: intent.value,
            clearErrorMessage: true,
            clearInfoMessage: true,
          ),
        );
      case OnRegisterMethodContinueClick():
        await _continueRegistration();
      case OnRegisterMethodBackClick():
        sendNavEffect(() => const RegisterMethodNavigateBack());
    }
  }

  Future<void> _continueRegistration() async {
    if (currentState.selectedMethod == RegisterMethod.email) {
      emitViewState(
        (state) => state.copyWith(
          infoMessage:
              'Email registration is coming soon. Use phone to continue for now.',
          clearErrorMessage: true,
        ),
      );
      return;
    }

    if (!currentState.canContinuePhone) {
      emitViewState(
        (state) => state.copyWith(
          errorMessage: 'Enter a phone number to continue.',
          clearInfoMessage: true,
        ),
      );
      return;
    }

    emitViewState(
      (state) => state.copyWith(
        isSubmitting: true,
        clearErrorMessage: true,
        clearInfoMessage: true,
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 250));
    emitViewState((state) => state.copyWith(isSubmitting: false));
    sendNavEffect(
      () => RegisterMethodNavigateToOtp(currentState.fullPhoneNumber),
    );
  }
}
