import 'dart:async';

import 'package:golf_kakis/features/foundation/model/snackbar_message_model.dart';
import 'package:golf_kakis/features/foundation/network/network.dart';
import 'package:golf_kakis/features/foundation/security/captcha/captcha_token_provider.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_view_model.dart';
import 'package:golf_kakis/features/profile/authentication/otp/domain/profile_otp_use_case.dart';

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
    required ProfileOtpUseCase otpUseCase,
    required CaptchaTokenProvider captchaTokenProvider,
  }) : _purpose = purpose,
       _username = username,
       _phoneNumber = phoneNumber,
       _otpUseCase = otpUseCase,
       _captchaTokenProvider = captchaTokenProvider;

  final ProfileOtpPurpose _purpose;
  final String _username;
  final String _phoneNumber;
  final ProfileOtpUseCase _otpUseCase;
  final CaptchaTokenProvider _captchaTokenProvider;
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
          await onInitOTP(visitorId: intent.visitorId);
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
        await onInitOTP(visitorId: intent.visitorId);
      case OnProfileOtpBackClick():
        sendNavEffect(() => const ProfileOtpNavigateBack());
    }
  }

  Future<void> onInitOTP({required String visitorId}) async {
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
      final captchaToken = await _captchaTokenProvider.execute(
        CaptchaTokenAction.requestOtp,
      );
      final response = await _otpUseCase.sendWhatsAppOtp(
        name: _username.trim(),
        phoneNumber: _phoneNumber.trim(),
        purpose: _purpose == ProfileOtpPurpose.pinReset
            ? 'pin_reset'
            : 'register',
        visitorId: visitorId,
        captchaToken: captchaToken,
      );

      if (!response.success) {
        emitViewState(
          (state) => state.copyWith(
            isSendingOtp: false,
            errorSnackbarMessageModel: const SnackbarMessageModel(
              message: 'Unable to send OTP. Please try again later',
            ),
          ),
        );
        return;
      }

      final expiresInSeconds = response.otpExpiresInSeconds > 0
          ? response.otpExpiresInSeconds
          : 300;

      emitViewState(
        (state) => state.copyWith(
          isSendingOtp: false,
          otpRemainingSeconds: expiresInSeconds,
          maskedDestination: response.maskedDestination,
          successMessage: 'OTP is sent through WhatsApp',
        ),
      );
      _startOtpTimer();
    } on ApiException {
      emitViewState(
        (state) => state.copyWith(
          isSendingOtp: false,
          errorSnackbarMessageModel: const SnackbarMessageModel(
            message: 'Unable to send OTP. Please try again later',
          ),
        ),
      );
    } catch (_) {
      emitViewState(
        (state) => state.copyWith(
          isSendingOtp: false,
          errorSnackbarMessageModel: const SnackbarMessageModel(
            message: 'Unable to send OTP. Please try again later',
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
        case ProfileOtpPurpose.register:
          final response = await _otpUseCase.verifyRegisterOtp(
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
              response: response,
            ),
          );
        case ProfileOtpPurpose.pinReset:
          final response = await _otpUseCase.verifyRegisterOtp(
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
              response: response,
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
