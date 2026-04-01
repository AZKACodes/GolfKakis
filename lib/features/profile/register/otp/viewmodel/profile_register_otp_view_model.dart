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
    bool skipAboutYou = false,
  }) : _phoneNumber = phoneNumber,
       _skipAboutYou = skipAboutYou;

  final String _phoneNumber;
  final bool _skipAboutYou;

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
    if (_skipAboutYou) {
      final normalizedPhoneNumber = currentState.phoneNumber.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );
      final suffix = normalizedPhoneNumber.isEmpty
          ? 'User'
          : normalizedPhoneNumber.substring(
              normalizedPhoneNumber.length > 4
                  ? normalizedPhoneNumber.length - 4
                  : 0,
            );
      sendNavEffect(
        () => RegisterOtpCompleted(
          fullName: 'User $suffix',
          nickname: 'Golfer',
          occupation: 'Golfer',
          email: 'user$suffix@golfkakis.app',
          phoneNumber: currentState.phoneNumber,
        ),
      );
      return;
    }

    sendNavEffect(
      () => RegisterOtpNavigateToAbout(phoneNumber: currentState.phoneNumber),
    );
  }
}
