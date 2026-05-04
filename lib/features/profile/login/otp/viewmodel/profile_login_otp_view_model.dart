import 'package:golf_kakis/features/foundation/network/network.dart';
import 'package:golf_kakis/features/foundation/model/snackbar_message_model.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_view_model.dart';

import '../../domain/profile_login_use_case.dart';
import 'profile_login_otp_view_contract.dart';

class ProfileLoginOtpViewModel
    extends
        MviViewModel<
          ProfileLoginOtpUserIntent,
          ProfileLoginOtpViewState,
          ProfileLoginOtpNavEffect
        >
    implements ProfileLoginOtpViewContract {
  ProfileLoginOtpViewModel({
    required String username,
    required String phoneNumber,
    required ProfileLoginUseCase useCase,
  }) : _username = username,
       _phoneNumber = phoneNumber,
       _useCase = useCase;

  final String _username;
  final String _phoneNumber;
  final ProfileLoginUseCase _useCase;

  @override
  ProfileLoginOtpViewState createInitialState() {
    return ProfileLoginOtpDataLoaded.initial(
      username: _username,
      phoneNumber: _phoneNumber,
    );
  }

  @override
  Future<void> handleIntent(ProfileLoginOtpUserIntent intent) async {
    switch (intent) {
      case OnLoginOtpDigitChanged():
        final sanitized = intent.value.replaceAll(RegExp(r'[^0-9]'), '');
        final nextDigits = List<String>.from(_currentDataState.otpDigits);
        nextDigits[intent.index] = sanitized.isEmpty ? '' : sanitized[0];
        emitViewState(
          (_) => _currentDataState.copyWith(
            otpDigits: nextDigits,
            clearErrorMessage: true,
          ),
        );
      case OnLoginOtpVerifyClick():
        await _verifyOtp(visitorId: intent.visitorId);
      case OnLoginOtpBackClick():
        sendNavEffect(() => const LoginOtpNavigateBack());
    }
  }

  ProfileLoginOtpDataLoaded get _currentDataState {
    return switch (currentState) {
      ProfileLoginOtpDataLoaded() => currentState as ProfileLoginOtpDataLoaded,
    };
  }

  Future<void> _verifyOtp({required String visitorId}) async {
    if (!_currentDataState.canVerify) {
      return;
    }

    emitViewState(
      (_) => _currentDataState.copyWith(
        isSubmitting: true,
        clearErrorMessage: true,
      ),
    );
    try {
      final response = await _useCase.verifyOtp(
        username: _currentDataState.username.trim(),
        phoneNumber: _currentDataState.phoneNumber.trim(),
        otp: _currentDataState.otpDigits.join(),
        visitorId: visitorId,
      );

      emitViewState((_) => _currentDataState.copyWith(isSubmitting: false));
      sendNavEffect(
        () => LoginOtpVerified(
          response: response,
          username: _currentDataState.username.trim(),
        ),
      );
    } on ApiException catch (error) {
      emitViewState(
        (_) => _currentDataState.copyWith(
          isSubmitting: false,
          errorSnackbarMessageModel: SnackbarMessageModel(
            message: error.message,
          ),
        ),
      );
    } catch (_) {
      emitViewState(
        (_) => _currentDataState.copyWith(
          isSubmitting: false,
          errorSnackbarMessageModel: const SnackbarMessageModel(
            message: 'Unable to verify OTP right now.',
          ),
        ),
      );
    }
  }
}
