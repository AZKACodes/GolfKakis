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
  ProfileLoginViewState createInitialState() => ProfileLoginDataLoaded.initial;

  @override
  Future<void> handleIntent(ProfileLoginUserIntent intent) async {
    switch (intent) {
      case OnNameChanged():
        emitViewState(
          (_) => _currentDataState.copyWith(
            name: intent.value,
            clearErrorMessage: true,
          ),
        );
      case OnCountryCodeChanged():
        emitViewState(
          (_) => _currentDataState.copyWith(
            countryCode: intent.value,
            clearErrorMessage: true,
          ),
        );
      case OnPhoneChanged():
        emitViewState(
          (_) => _currentDataState.copyWith(
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

  ProfileLoginDataLoaded get _currentDataState {
    return switch (currentState) {
      ProfileLoginDataLoaded() => currentState as ProfileLoginDataLoaded,
    };
  }

  Future<void> _requestOtp({required String visitorId}) async {
    if (!_currentDataState.canSubmit) {
      emitViewState(
        (_) => _currentDataState.copyWith(
          errorMessage: 'Enter your name and phone number to continue.',
          clearInfoMessage: true,
        ),
      );
      return;
    }

    emitViewState(
      (_) => _currentDataState.copyWith(
        isSubmitting: true,
        clearErrorMessage: true,
        clearInfoMessage: true,
      ),
    );

    try {
      final response = await _profileApiService.onRequestOtp(
        name: _currentDataState.name.trim(),
        phoneNumber: _currentDataState.fullPhoneNumber.replaceAll(' ', ''),
        visitorId: visitorId,
      );

      emitViewState((_) => _currentDataState.copyWith(isSubmitting: false));
      sendNavEffect(() => RequestOtpSucceeded(response: response));
    } on ApiException catch (error) {
      emitViewState(
        (_) => _currentDataState.copyWith(
          isSubmitting: false,
          errorMessage: error.message,
          clearInfoMessage: true,
        ),
      );
    } catch (_) {
      emitViewState(
        (_) => _currentDataState.copyWith(
          isSubmitting: false,
          errorMessage: 'Unable to request OTP right now.',
          clearInfoMessage: true,
        ),
      );
    }
  }
}
