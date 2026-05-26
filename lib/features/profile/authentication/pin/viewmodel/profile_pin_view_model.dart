import 'package:golf_kakis/features/foundation/model/snackbar_message_model.dart';
import 'package:golf_kakis/features/foundation/network/network.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_view_model.dart';
import 'package:golf_kakis/features/profile/authentication/pin/domain/profile_pin_use_case.dart';

import 'profile_pin_view_contract.dart';

class ProfilePinViewModel
    extends
        MviViewModel<
          ProfilePinUserIntent,
          ProfilePinViewState,
          ProfilePinNavEffect
        >
    implements ProfilePinViewContract {
  ProfilePinViewModel({
    required ProfilePinMode mode,
    required String pinSetupToken,
    required String phoneNumber,
    required bool hasOTPFallback,
    required ProfilePinUseCase useCase,
  }) : _mode = mode,
       _pinSetupToken = pinSetupToken,
       _phoneNumber = phoneNumber,
       _hasOTPFallback = hasOTPFallback,
       _useCase = useCase;

  final ProfilePinMode _mode;
  final String _pinSetupToken;
  final String _phoneNumber;
  final bool _hasOTPFallback;
  final ProfilePinUseCase _useCase;

  @override
  ProfilePinViewState createInitialState() {
    return ProfilePinViewState.initial(
      mode: _mode,
      hasOTPFallback: _hasOTPFallback,
    );
  }

  @override
  Future<void> handleIntent(ProfilePinUserIntent intent) async {
    switch (intent) {
      case OnProfilePinChanged():
        emitViewState(
          (state) => state.copyWith(
            pin: _sanitizePin(intent.value),
            clearErrorMessage: true,
          ),
        );
        await _submitIfComplete();
      case OnProfileConfirmPinChanged():
        emitViewState(
          (state) => state.copyWith(
            confirmPin: _sanitizePin(intent.value),
            clearErrorMessage: true,
          ),
        );
        await _submitIfComplete();
      case OnProfilePinSubmitClick():
        await _submit();
      case OnProfilePinBackClick():
        sendNavEffect(() => const ProfilePinNavigateBack());
      case OnProfileForgotPinClick():
        sendNavEffect(() => const ProfileForgotPinRequested());
    }
  }

  String _sanitizePin(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.length > 6 ? digits.substring(0, 6) : digits;
  }

  Future<void> _submitIfComplete() async {
    if (currentState.canSubmit) {
      await _submit();
    }
  }

  Future<void> _submit() async {
    if (_mode == ProfilePinMode.setup &&
        currentState.hasCompletePin &&
        currentState.hasCompleteConfirmPin &&
        !currentState.pinsMatch) {
      emitViewState(
        (state) => state.copyWith(
          errorSnackbarMessageModel: const SnackbarMessageModel(
            message: 'PINs do not match.',
          ),
        ),
      );
      return;
    }

    if (!currentState.canSubmit) {
      emitViewState(
        (state) => state.copyWith(
          errorSnackbarMessageModel: SnackbarMessageModel(
            message: _mode == ProfilePinMode.login
                ? 'Enter your 6-digit PIN.'
                : 'Enter and confirm your 6-digit PIN.',
          ),
        ),
      );
      return;
    }

    emitViewState(
      (state) => state.copyWith(isSubmitting: true, clearErrorMessage: true),
    );
    try {
      if (_mode == ProfilePinMode.login) {
        final response = await _useCase.loginViaPin(
          phoneNumber: _phoneNumber,
          pin: currentState.pin,
        );
        emitViewState((state) => state.copyWith(isSubmitting: false));
        sendNavEffect(() => ProfilePinSetupCompleted(response));
        return;
      }

      final response = await _useCase.setupUserPin(
        pinSetupToken: _pinSetupToken,
        pin: currentState.pin,
        confirmPin: currentState.confirmPin,
      );
      emitViewState((state) => state.copyWith(isSubmitting: false));
      sendNavEffect(() => ProfilePinSetupCompleted(response));
    } on ApiException catch (error) {
      emitViewState(
        (state) => state.copyWith(
          isSubmitting: false,
          errorSnackbarMessageModel: SnackbarMessageModel(
            message: _pinErrorMessage(error),
          ),
        ),
      );
    } catch (_) {
      emitViewState(
        (state) => state.copyWith(
          isSubmitting: false,
          errorSnackbarMessageModel: const SnackbarMessageModel(
            message: 'Unable to continue right now.',
          ),
        ),
      );
    }
  }

  String _pinErrorMessage(ApiException error) {
    final isInvalidPin =
        _mode == ProfilePinMode.login &&
        (error.statusCode == 401 ||
            error.message.toLowerCase().contains(
              'invalid phone number or pin',
            ));

    if (isInvalidPin) {
      return 'Invalid PIN.';
    }

    return error.message;
  }
}
