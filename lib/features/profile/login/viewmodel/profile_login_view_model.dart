import 'package:golf_kakis/features/foundation/enums/session/user_role.dart';
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
  @override
  ProfileLoginViewState createInitialState() => ProfileLoginViewState.initial;

  @override
  Future<void> handleIntent(ProfileLoginUserIntent intent) async {
    switch (intent) {
      case OnLoginMethodChanged():
        emitViewState(
          (state) => state.copyWith(
            loginMethod: intent.value,
            infoMessage: intent.value == LoginMethod.email
                ? 'Email login is coming soon. Use phone to continue for now.'
                : null,
            clearErrorMessage: true,
            clearInfoMessage: intent.value == LoginMethod.phone,
          ),
        );
      case OnEmailChanged():
        emitViewState(
          (state) =>
              state.copyWith(email: intent.value, clearErrorMessage: true),
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
      case OnPasswordChanged():
        emitViewState(
          (state) =>
              state.copyWith(password: intent.value, clearErrorMessage: true),
        );
      case OnLoginClick():
        await _login(intent.role);
      case OnBackClick():
        sendNavEffect(() => const NavigateBack());
      case OnRegisterClick():
        sendNavEffect(() => const RegisterRequested());
    }
  }

  Future<void> _login(UserRole role) async {
    if (role != UserRole.guest &&
        currentState.loginMethod == LoginMethod.email) {
      emitViewState(
        (state) => state.copyWith(
          infoMessage:
              'Email login is coming soon. Use phone to continue for now.',
          clearErrorMessage: true,
        ),
      );
      return;
    }

    if (role != UserRole.guest && !currentState.canSubmit) {
      emitViewState(
        (state) => state.copyWith(
          errorMessage: currentState.loginMethod == LoginMethod.phone
              ? 'Enter phone number and password to continue.'
              : 'Enter email and password to continue.',
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

    await Future<void>.delayed(const Duration(milliseconds: 500));

    final loginIdentifier = currentState.loginIdentifier;
    final username = switch (role) {
      UserRole.guest => 'Guest User',
      UserRole.user =>
        loginIdentifier.contains('@')
            ? loginIdentifier.split('@').first
            : loginIdentifier,
      UserRole.agent => 'Agent Zack',
      UserRole.admin => 'Admin Zack',
    };

    emitViewState((state) => state.copyWith(isSubmitting: false));
    sendNavEffect(() => LoginSucceeded(username: username, role: role));
  }
}
