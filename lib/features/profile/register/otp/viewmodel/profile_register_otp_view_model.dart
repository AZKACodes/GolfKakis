import 'package:golf_kakis/features/foundation/network/network.dart';
import 'package:golf_kakis/features/foundation/model/snackbar_message_model.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_view_model.dart';

import '../../domain/profile_register_use_case.dart';
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
    required String username,
    required String phoneNumber,
    required String fullName,
    required String nickname,
    required String occupation,
    bool requiresOccupation = true,
    required ProfileRegisterUseCase useCase,
  }) : _username = username,
       _phoneNumber = phoneNumber,
       _fullName = fullName,
       _nickname = nickname,
       _occupation = occupation,
       _requiresOccupation = requiresOccupation,
       _useCase = useCase;

  final String _username;
  final String _phoneNumber;
  final String _fullName;
  final String _nickname;
  final String _occupation;
  final bool _requiresOccupation;
  final ProfileRegisterUseCase _useCase;

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
        await _continueFlow(visitorId: intent.visitorId);
      case OnRegisterOtpBackClick():
        sendNavEffect(() => const RegisterOtpNavigateBack());
    }
  }

  Future<void> _continueFlow({required String visitorId}) async {
    if (!currentState.canContinue) {
      emitViewState(
        (state) => state.copyWith(
          errorSnackbarMessageModel: const SnackbarMessageModel(
            message: 'Enter the 6-digit OTP to continue the demo flow.',
          ),
        ),
      );
      return;
    }

    emitViewState(
      (state) => state.copyWith(isSubmitting: true, clearErrorMessage: true),
    );
    try {
      final response = await _useCase.verifyOtp(
        username: _username.trim(),
        phoneNumber: currentState.phoneNumber.trim(),
        otp: currentState.otpDigits.join(),
        visitorId: visitorId,
      );

      emitViewState((state) => state.copyWith(isSubmitting: false));
      sendNavEffect(
        () => RegisterOtpCompleted(
          response: response,
          username: _username.trim(),
          phoneNumber: currentState.phoneNumber.trim(),
          fullName: _fullName.trim(),
          nickname: _nickname.trim(),
          occupation: _occupation.trim(),
          requiresOccupation: _requiresOccupation,
        ),
      );
    } on ApiException catch (error) {
      emitViewState(
        (state) => state.copyWith(
          isSubmitting: false,
          errorSnackbarMessageModel: SnackbarMessageModel(
            message: error.message,
          ),
        ),
      );
    } catch (_) {
      emitViewState(
        (state) => state.copyWith(
          isSubmitting: false,
          errorSnackbarMessageModel: const SnackbarMessageModel(
            message: 'Unable to verify OTP right now.',
          ),
        ),
      );
    }
  }
}
