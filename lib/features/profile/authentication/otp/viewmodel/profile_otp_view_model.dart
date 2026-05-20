import 'dart:async';

import 'package:golf_kakis/features/foundation/model/snackbar_message_model.dart';
import 'package:golf_kakis/features/foundation/network/network.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_view_model.dart';
import 'package:golf_kakis/features/profile/authentication/domain/profile_register_use_case.dart';
import 'package:golf_kakis/features/profile/authentication/login/domain/profile_login_use_case.dart';

import 'profile_otp_view_contract.dart';

class ProfileOtpViewModel
    extends
        MviViewModel<
          ProfileOtpUserIntent,
          ProfileOtpViewState,
          ProfileOtpNavEffect
        >
    implements ProfileOtpViewContract {
  ProfileOtpViewModel({
    required ProfileOtpPurpose purpose,
    required String username,
    required String phoneNumber,
    required ProfileLoginUseCase loginUseCase,
    required ProfileRegisterUseCase registerUseCase,
  }) : _purpose = purpose,
       _username = username,
       _phoneNumber = phoneNumber,
       _loginUseCase = loginUseCase,
       _registerUseCase = registerUseCase;

  final ProfileOtpPurpose _purpose;
  final String _username;
  final String _phoneNumber;
  final ProfileLoginUseCase _loginUseCase;
  final ProfileRegisterUseCase _registerUseCase;
  Timer? _otpTimer;

  @override
  ProfileOtpViewState createInitialState() {
    return ProfileOtpViewState.initial(
      phoneNumber: _phoneNumber,
      showsResend: _purpose == ProfileOtpPurpose.register,
    );
  }

  @override
  Future<void> handleIntent(ProfileOtpUserIntent intent) async {
    switch (intent) {
      case OnProfileOtpInit():
        if (_purpose == ProfileOtpPurpose.register ||
            _purpose == ProfileOtpPurpose.pinReset) {
          await onInitOTP(
            visitorId: intent.visitorId,
            captchaToken: intent.captchaToken,
          );
        }
      case OnProfileOtpDigitChanged():
        final sanitized = intent.value.replaceAll(RegExp(r'[^0-9]'), '');
        final nextDigits = List<String>.from(currentState.otpDigits);
        nextDigits[intent.index] = sanitized.isEmpty ? '' : sanitized[0];
        emitViewState(
          (state) =>
              state.copyWith(otpDigits: nextDigits, clearErrorMessage: true),
        );
      case OnProfileOtpVerifyClick():
        await _verifyOtp(visitorId: intent.visitorId);
      case OnProfileOtpResendClick():
        await onInitOTP(
          visitorId: intent.visitorId,
          captchaToken: intent.captchaToken,
        );
      case OnProfileOtpBackClick():
        sendNavEffect(() => const ProfileOtpNavigateBack());
    }
  }

  Future<void> onInitOTP({
    required String visitorId,
    required String captchaToken,
  }) async {
    if (currentState.isSendingOtp) {
      return;
    }

    _otpTimer?.cancel();
    emitViewState(
      (state) => state.copyWith(
        isSendingOtp: true,
        clearErrorMessage: true,
        clearSuccessMessage: true,
      ),
    );

    try {
      final response = await _registerUseCase.sendWhatsAppOtp(
        name: _username.trim(),
        phoneNumber: _phoneNumber.trim(),
        purpose: _purpose == ProfileOtpPurpose.pinReset
            ? 'pin_reset'
            : 'register',
        visitorId: visitorId,
        captchaToken: captchaToken,
      );
      final expiresInSeconds = response.otpExpiresInSeconds > 0
          ? response.otpExpiresInSeconds
          : 300;

      emitViewState(
        (state) => state.copyWith(
          isSendingOtp: false,
          otpRemainingSeconds: expiresInSeconds,
          maskedDestination: response.maskedDestination,
          successMessage: response.message,
        ),
      );
      _startOtpTimer();
    } on ApiException catch (error) {
      emitViewState(
        (state) => state.copyWith(
          isSendingOtp: false,
          errorSnackbarMessageModel: SnackbarMessageModel(
            message: error.message,
          ),
        ),
      );
    } catch (_) {
      emitViewState(
        (state) => state.copyWith(
          isSendingOtp: false,
          errorSnackbarMessageModel: const SnackbarMessageModel(
            message: 'Unable to send WhatsApp OTP right now.',
          ),
        ),
      );
    }
  }

  void _startOtpTimer() {
    _otpTimer?.cancel();
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final nextRemaining = currentState.otpRemainingSeconds - 1;
      if (nextRemaining <= 0) {
        timer.cancel();
        emitViewState((state) => state.copyWith(otpRemainingSeconds: 0));
        return;
      }

      emitViewState(
        (state) => state.copyWith(otpRemainingSeconds: nextRemaining),
      );
    });
  }

  Future<void> _verifyOtp({required String visitorId}) async {
    if (!currentState.canVerify) {
      return;
    }

    emitViewState(
      (state) => state.copyWith(isSubmitting: true, clearErrorMessage: true),
    );

    try {
      switch (_purpose) {
        case ProfileOtpPurpose.login:
          final response = await _loginUseCase.verifyOtp(
            username: _username.trim(),
            phoneNumber: currentState.phoneNumber.trim(),
            otp: currentState.otpDigits.join(),
            visitorId: visitorId,
          );
          emitViewState((state) => state.copyWith(isSubmitting: false));
          sendNavEffect(
            () => ProfileOtpVerified(
              response: response,
              username: _username.trim(),
            ),
          );
        case ProfileOtpPurpose.register:
          final response = await _registerUseCase.verifyRegisterOtp(
            name: _username.trim(),
            phoneNumber: currentState.phoneNumber.trim(),
            purpose: 'register',
            includeVisitorId: true,
            otpCode: currentState.otpDigits.join(),
            visitorId: visitorId,
          );
          emitViewState((state) => state.copyWith(isSubmitting: false));
          sendNavEffect(
            () => ProfileOtpPinSetupRequired(
              pinSetupToken: response.pinSetupToken,
              username: _username.trim(),
              phoneNumber: currentState.phoneNumber.trim(),
            ),
          );
        case ProfileOtpPurpose.pinReset:
          final response = await _registerUseCase.verifyRegisterOtp(
            name: _username.trim(),
            phoneNumber: currentState.phoneNumber.trim(),
            purpose: 'pin_reset',
            includeVisitorId: false,
            otpCode: currentState.otpDigits.join(),
            visitorId: visitorId,
          );
          emitViewState((state) => state.copyWith(isSubmitting: false));
          sendNavEffect(
            () => ProfileOtpPinSetupRequired(
              pinSetupToken: response.pinSetupToken,
              username: _username.trim(),
              phoneNumber: currentState.phoneNumber.trim(),
            ),
          );
      }
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

  @override
  void dispose() {
    _otpTimer?.cancel();
    super.dispose();
  }
}
