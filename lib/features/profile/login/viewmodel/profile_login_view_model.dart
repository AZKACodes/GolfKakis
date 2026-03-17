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
      case OnEmailChanged():
        emitViewState(
          (state) =>
              state.copyWith(email: intent.value, clearErrorMessage: true),
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
    }
  }

  Future<void> _login(UserRole role) async {
    if (role != UserRole.guest && !currentState.canSubmit) {
      emitViewState(
        (state) => state.copyWith(
          errorMessage: 'Enter email and password to continue.',
        ),
      );
      return;
    }

    emitViewState(
      (state) => state.copyWith(isSubmitting: true, clearErrorMessage: true),
    );

    await Future<void>.delayed(const Duration(milliseconds: 500));

    final normalizedEmail = currentState.email.trim();
    final username = switch (role) {
      UserRole.guest => 'Guest User',
      UserRole.user =>
        normalizedEmail.contains('@')
            ? normalizedEmail.split('@').first
            : normalizedEmail,
      UserRole.agent => 'Agent Zack',
      UserRole.admin => 'Admin Zack',
    };

    emitViewState((state) => state.copyWith(isSubmitting: false));
    sendNavEffect(() => LoginSucceeded(username: username, role: role));
  }
}
