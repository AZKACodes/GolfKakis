import 'package:golf_kakis/features/foundation/network/network.dart';
import 'package:golf_kakis/features/foundation/model/snackbar_message_model.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_view_model.dart';

import '../domain/profile_login_use_case.dart';
import 'profile_login_view_contract.dart';

class ProfileLoginViewModel
    extends
        MviViewModel<
          ProfileLoginUserIntent,
          ProfileLoginViewState,
          ProfileLoginNavEffect
        >
    implements ProfileLoginViewContract {
  ProfileLoginViewModel({required ProfileLoginUseCase useCase})
    : _useCase = useCase;

  final ProfileLoginUseCase _useCase;

  @override
  ProfileLoginViewState createInitialState() => ProfileLoginDataLoaded.initial;

  @override
  Future<void> handleIntent(ProfileLoginUserIntent intent) async {
    switch (intent) {
      case OnUsernameChanged():
        emitViewState(
          (_) => _currentDataState.copyWith(
            username: intent.value,
            clearErrorMessage: true,
          ),
        );
      case OnPasswordChanged():
        emitViewState(
          (_) => _currentDataState.copyWith(
            password: intent.value,
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
          errorSnackbarMessageModel: const SnackbarMessageModel(
            message: 'Enter your username and password to continue.',
          ),
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
      final response = await _useCase.requestOtp(
        username: _currentDataState.username.trim(),
        password: _currentDataState.password,
        visitorId: visitorId,
      );

      emitViewState((_) => _currentDataState.copyWith(isSubmitting: false));
      sendNavEffect(
        () => RequestOtpSucceeded(
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
          clearInfoMessage: true,
        ),
      );
    } catch (_) {
      emitViewState(
        (_) => _currentDataState.copyWith(
          isSubmitting: false,
          errorSnackbarMessageModel: const SnackbarMessageModel(
            message: 'Unable to request OTP right now.',
          ),
          clearInfoMessage: true,
        ),
      );
    }
  }
}
