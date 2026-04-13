import 'package:golf_kakis/features/foundation/network/network.dart';
import 'package:golf_kakis/features/profile/api/profile_api_service.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_view_model.dart';

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
    required String name,
    required String phoneNumber,
    ProfileApiService? profileApiService,
  }) : _name = name,
       _phoneNumber = phoneNumber,
       _profileApiService = profileApiService ?? ProfileApiService();

  final String _name;
  final String _phoneNumber;
  final ProfileApiService _profileApiService;

  @override
  ProfileLoginOtpViewState createInitialState() {
    return ProfileLoginOtpViewState.initial(
      name: _name,
      phoneNumber: _phoneNumber,
    );
  }

  @override
  Future<void> handleIntent(ProfileLoginOtpUserIntent intent) async {
    switch (intent) {
      case OnLoginOtpDigitChanged():
        final sanitized = intent.value.replaceAll(RegExp(r'[^0-9]'), '');
        final nextDigits = List<String>.from(currentState.otpDigits);
        nextDigits[intent.index] = sanitized.isEmpty ? '' : sanitized[0];
        emitViewState(
          (state) =>
              state.copyWith(otpDigits: nextDigits, clearErrorMessage: true),
        );
      case OnLoginOtpVerifyClick():
        await _verifyOtp(visitorId: intent.visitorId);
      case OnLoginOtpBackClick():
        sendNavEffect(() => const LoginOtpNavigateBack());
    }
  }

  Future<void> _verifyOtp({required String visitorId}) async {
    if (!currentState.canVerify) {
      return;
    }

    emitViewState(
      (state) => state.copyWith(isSubmitting: true, clearErrorMessage: true),
    );
    try {
      final response = await _profileApiService.onVerifyOtp(
        name: currentState.name.trim(),
        phoneNumber: currentState.phoneNumber.trim(),
        otp: currentState.otpDigits.join(),
        visitorId: visitorId,
      );

      emitViewState((state) => state.copyWith(isSubmitting: false));
      sendNavEffect(() => LoginOtpVerified(response: response));
    } on ApiException catch (error) {
      emitViewState(
        (state) => state.copyWith(
          isSubmitting: false,
          errorMessage: error.message,
        ),
      );
    } catch (_) {
      emitViewState(
        (state) => state.copyWith(
          isSubmitting: false,
          errorMessage: 'Unable to verify OTP right now.',
        ),
      );
    }
  }
}
