import 'package:golf_kakis/features/foundation/network/network.dart';
import 'package:golf_kakis/features/profile/api/profile_api_service.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_view_model.dart';

import 'profile_login_view_contract.dart';

class ProfileLoginViewModel
    extends
        MviViewModel<
          ProfileLoginUserIntent,
          ProfileLoginViewState,
          ProfileLoginNavEffect
        >
    implements ProfileLoginViewContract {
  ProfileLoginViewModel({ProfileApiService? profileApiService})
    : _profileApiService = profileApiService ?? ProfileApiService();

  final ProfileApiService _profileApiService;

  @override
  ProfileLoginViewState createInitialState() => ProfileLoginViewState.initial;

  @override
  Future<void> handleIntent(ProfileLoginUserIntent intent) async {
    switch (intent) {
      case OnNameChanged():
        emitViewState(
          (state) =>
              state.copyWith(name: intent.value, clearErrorMessage: true),
        );
      case OnCountryCodeChanged():
        emitViewState(
          (state) => state.copyWith(
            countryCode: intent.value,
            clearErrorMessage: true,
          ),
        );
      case OnPhoneChanged():
        emitViewState(
          (state) => state.copyWith(
            phoneNumber: intent.value,
            clearErrorMessage: true,
          ),
        );
      case OnLoginClick():
        await _requestOtp(visitorId: intent.visitorId);
      case OnBackClick():
        sendNavEffect(() => const NavigateBack());
      case OnRegisterClick():
        sendNavEffect(() => const RegisterRequested());
    }
  }

  Future<void> _requestOtp({required String visitorId}) async {
    if (!currentState.canSubmit) {
      emitViewState(
        (state) => state.copyWith(
          errorMessage: 'Enter your name and phone number to continue.',
          clearInfoMessage: true,
        ),
      );
      return;
    }

    emitViewState(
      (state) => state.copyWith(
        isSubmitting: true,
        clearErrorMessage: true,
        clearInfoMessage: true,
      ),
    );

    try {
      final response = await _profileApiService.onRequestOtp(
        name: currentState.name.trim(),
        phoneNumber: currentState.fullPhoneNumber.replaceAll(' ', ''),
        visitorId: visitorId,
      );

      emitViewState((state) => state.copyWith(isSubmitting: false));
      sendNavEffect(() => RequestOtpSucceeded(response: response));
    } on ApiException catch (error) {
      emitViewState(
        (state) => state.copyWith(
          isSubmitting: false,
          errorMessage: error.message,
          clearInfoMessage: true,
        ),
      );
    } catch (_) {
      emitViewState(
        (state) => state.copyWith(
          isSubmitting: false,
          errorMessage: 'Unable to request OTP right now.',
          clearInfoMessage: true,
        ),
      );
    }
  }
}
