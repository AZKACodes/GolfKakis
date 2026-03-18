import 'package:golf_kakis/features/foundation/viewmodel/mvi_view_model.dart';

import 'profile_register_details_view_contract.dart';

class ProfileRegisterDetailsViewModel
    extends
        MviViewModel<
          ProfileRegisterDetailsUserIntent,
          ProfileRegisterDetailsViewState,
          ProfileRegisterDetailsNavEffect
        >
    implements ProfileRegisterDetailsViewContract {
  ProfileRegisterDetailsViewModel({required String phoneNumber})
    : _phoneNumber = phoneNumber;

  final String _phoneNumber;

  @override
  ProfileRegisterDetailsViewState createInitialState() {
    return ProfileRegisterDetailsViewState.initial(phoneNumber: _phoneNumber);
  }

  @override
  Future<void> handleIntent(ProfileRegisterDetailsUserIntent intent) async {
    switch (intent) {
      case OnRegisterNameChanged():
        emitViewState(
          (state) =>
              state.copyWith(name: intent.value, clearErrorMessage: true),
        );
      case OnRegisterNicknameChanged():
        emitViewState(
          (state) =>
              state.copyWith(nickname: intent.value, clearErrorMessage: true),
        );
      case OnRegisterOccupationChanged():
        emitViewState(
          (state) =>
              state.copyWith(occupation: intent.value, clearErrorMessage: true),
        );
      case OnRegisterDetailsSubmitClick():
        await _submit();
      case OnRegisterDetailsBackClick():
        sendNavEffect(() => const RegisterDetailsNavigateBack());
    }
  }

  Future<void> _submit() async {
    if (!currentState.canSubmit) {
      emitViewState(
        (state) => state.copyWith(
          errorMessage:
              'Enter your name, nickname, and occupation to continue.',
        ),
      );
      return;
    }

    emitViewState(
      (state) => state.copyWith(isSubmitting: true, clearErrorMessage: true),
    );
    await Future<void>.delayed(const Duration(milliseconds: 350));
    emitViewState((state) => state.copyWith(isSubmitting: false));
    sendNavEffect(
      () => RegisterDetailsCompleted(
        fullName: currentState.name.trim(),
        nickname: currentState.nickname.trim(),
        occupation: currentState.occupation.trim(),
        email:
            '${currentState.nickname.trim().toLowerCase().replaceAll(' ', '.')}@golfkakis.app',
        phoneNumber: currentState.phoneNumber,
      ),
    );
  }
}
