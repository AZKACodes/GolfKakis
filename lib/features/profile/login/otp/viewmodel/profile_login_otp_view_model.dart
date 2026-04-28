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
    return ProfileLoginOtpDataLoaded.initial(
      name: _name,
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
      final response = await _profileApiService.onVerifyOtp(
        name: _currentDataState.name.trim(),
        phoneNumber: _currentDataState.phoneNumber.trim(),
        otp: _currentDataState.otpDigits.join(),
        visitorId: visitorId,
      );

      emitViewState((_) => _currentDataState.copyWith(isSubmitting: false));
      sendNavEffect(() => LoginOtpVerified(response: response));
    } on ApiException catch (error) {
      emitViewState(
        (_) => _currentDataState.copyWith(
          isSubmitting: false,
          errorMessage: error.message,
        ),
      );
    } catch (_) {
      emitViewState(
        (_) => _currentDataState.copyWith(
          isSubmitting: false,
          errorMessage: 'Unable to verify OTP right now.',
        ),
      );
    }
  }
}
