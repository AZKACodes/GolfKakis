import 'package:golf_kakis/features/foundation/model/snackbar_message_model.dart';
import 'package:golf_kakis/features/foundation/network/network.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_view_model.dart';
import 'package:golf_kakis/features/profile/authentication/domain/profile_register_use_case.dart';

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
    required ProfileRegisterUseCase useCase,
  }) : _mode = mode,
       _pinSetupToken = pinSetupToken,
       _phoneNumber = phoneNumber,
       _hasOTPFallback = hasOTPFallback,
       _useCase = useCase;

  final ProfilePinMode _mode;
  final String _pinSetupToken;
  final String _phoneNumber;
  final bool _hasOTPFallback;
  final ProfileRegisterUseCase _useCase;

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
        await _submitIfReady();
      case OnProfileConfirmPinChanged():
        emitViewState(
          (state) => state.copyWith(
            confirmPin: _sanitizePin(intent.value),
            clearErrorMessage: true,
          ),
        );
        await _submitIfReady();
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

  Future<void> _submitIfReady() async {
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
            message: error.message,
          ),
        ),
      );
    } catch (_) {
      emitViewState(
        (state) => state.copyWith(
          isSubmitting: false,
          errorSnackbarMessageModel: const SnackbarMessageModel(
            message: 'Unable to set up PIN right now.',
          ),
        ),
      );
    }
  }
}
