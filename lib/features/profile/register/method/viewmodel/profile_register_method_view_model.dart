import 'package:golf_kakis/features/foundation/network/network.dart';
import 'package:golf_kakis/features/profile/api/profile_api_service.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_view_model.dart';

import 'profile_register_method_view_contract.dart';

class ProfileRegisterMethodViewModel
    extends
        MviViewModel<
          ProfileRegisterMethodUserIntent,
          ProfileRegisterMethodViewState,
          ProfileRegisterMethodNavEffect
        >
    implements ProfileRegisterMethodViewContract {
  ProfileRegisterMethodViewModel({ProfileApiService? profileApiService})
    : _profileApiService = profileApiService ?? ProfileApiService();

  final ProfileApiService _profileApiService;

  @override
  ProfileRegisterMethodViewState createInitialState() {
    return ProfileRegisterMethodViewState.initial;
  }

  @override
  Future<void> handleIntent(ProfileRegisterMethodUserIntent intent) async {
    switch (intent) {
      case OnRegisterNameChanged():
        emitViewState(
          (state) => state.copyWith(
            name: intent.value,
            clearErrorMessage: true,
            clearInfoMessage: true,
          ),
        );
      case OnRegisterPhoneChanged():
        emitViewState(
          (state) => state.copyWith(
            phoneNumber: intent.value,
            clearErrorMessage: true,
            clearInfoMessage: true,
          ),
        );
      case OnRegisterCountryCodeSelected():
        emitViewState(
          (state) => state.copyWith(
            countryCode: intent.value,
            clearErrorMessage: true,
            clearInfoMessage: true,
          ),
        );
      case OnRegisterMethodContinueClick():
        await _continueRegistration(visitorId: intent.visitorId);
      case OnRegisterMethodBackClick():
        sendNavEffect(() => const RegisterMethodNavigateBack());
    }
  }

  Future<void> _continueRegistration({required String visitorId}) async {
    if (!currentState.canContinuePhone) {
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
      sendNavEffect(
        () => RegisterMethodNavigateToOtp(
          response: response,
          password: '',
        ),
      );
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
