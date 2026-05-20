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
      case OnLoginPhoneChanged():
        emitViewState(
          (_) => _currentDataState.copyWith(
            phoneNumber: intent.value,
            clearErrorMessage: true,
          ),
        );
      case OnLoginClick():
        await _fetchLoginMethods();
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

  Future<void> _fetchLoginMethods() async {
    if (!_currentDataState.canSubmit) {
      emitViewState(
        (_) => _currentDataState.copyWith(
          errorSnackbarMessageModel: const SnackbarMessageModel(
            message: 'Enter your phone number to continue.',
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
      final response = await _useCase.onFetchLoginMethods(
        phoneNumber: _currentDataState.phoneNumber.trim(),
      );

      emitViewState((_) => _currentDataState.copyWith(isSubmitting: false));
      sendNavEffect(
        () => LoginMethodsLoaded(
          response: response,
          phoneNumber: _currentDataState.phoneNumber.trim(),
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
            message: 'Unable to load login methods right now.',
          ),
          clearInfoMessage: true,
        ),
      );
    }
  }
}
