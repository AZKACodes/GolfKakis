import 'package:golf_kakis/features/foundation/viewmodel/mvi_view_model.dart';

import 'profile_register_otp_view_contract.dart';

class ProfileRegisterOtpViewModel
    extends
        MviViewModel<
          ProfileRegisterOtpUserIntent,
          ProfileRegisterOtpViewState,
          ProfileRegisterOtpNavEffect
        >
    implements ProfileRegisterOtpViewContract {
  ProfileRegisterOtpViewModel({
    required String phoneNumber,
    required String password,
    bool requiresOccupation = true,
  }) : _phoneNumber = phoneNumber,
       _password = password,
       _requiresOccupation = requiresOccupation;

  final String _phoneNumber;
  final String _password;
  final bool _requiresOccupation;

  @override
  ProfileRegisterOtpViewState createInitialState() {
    return ProfileRegisterOtpViewState.initial(phoneNumber: _phoneNumber);
  }

  @override
  Future<void> handleIntent(ProfileRegisterOtpUserIntent intent) async {
    switch (intent) {
      case OnRegisterOtpDigitChanged():
        final sanitized = intent.value.replaceAll(RegExp(r'[^0-9]'), '');
        final nextDigits = List<String>.from(currentState.otpDigits);
        nextDigits[intent.index] = sanitized.isEmpty ? '' : sanitized[0];
        emitViewState(
          (state) =>
              state.copyWith(otpDigits: nextDigits, clearErrorMessage: true),
        );
      case OnRegisterOtpContinueClick():
        await _continueFlow();
      case OnRegisterOtpBackClick():
        sendNavEffect(() => const RegisterOtpNavigateBack());
    }
  }

  Future<void> _continueFlow() async {
    if (!currentState.canContinue) {
      emitViewState(
        (state) => state.copyWith(
          errorMessage: 'Enter the 4-digit OTP to continue the demo flow.',
        ),
      );
      return;
    }

    emitViewState(
      (state) => state.copyWith(isSubmitting: true, clearErrorMessage: true),
    );
    await Future<void>.delayed(const Duration(milliseconds: 250));
    emitViewState((state) => state.copyWith(isSubmitting: false));
    sendNavEffect(
      () => RegisterOtpNavigateToAbout(
        phoneNumber: currentState.phoneNumber,
        password: _password,
        requiresOccupation: _requiresOccupation,
      ),
    );
  }
}
