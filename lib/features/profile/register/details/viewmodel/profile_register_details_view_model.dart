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
  ProfileRegisterDetailsViewModel({
    required String username,
    required String password,
    required bool requiresOccupation,
  }) : _username = username,
       _password = password,
       _requiresOccupation = requiresOccupation;

  final String _username;
  final String _password;
  final bool _requiresOccupation;

  @override
  ProfileRegisterDetailsViewState createInitialState() {
    return ProfileRegisterDetailsViewState.initial(
      username: _username,
      requiresOccupation: _requiresOccupation,
    );
  }

  @override
  Future<void> handleIntent(ProfileRegisterDetailsUserIntent intent) async {
    switch (intent) {
      case OnRegisterFullNameChanged():
        emitViewState((state) => state.copyWith(fullName: intent.value));
      case OnRegisterNicknameChanged():
        emitViewState((state) => state.copyWith(nickname: intent.value));
      case OnRegisterOccupationChanged():
        emitViewState((state) => state.copyWith(occupation: intent.value));
      case OnRegisterDetailsContinueClick():
        _goToPhone();
      case OnRegisterDetailsSkipClick():
        _goToPhone(skip: true);
      case OnRegisterDetailsBackClick():
        sendNavEffect(() => const RegisterDetailsNavigateBack());
    }
  }

  void _goToPhone({bool skip = false}) {
    sendNavEffect(
      () => RegisterDetailsNavigateToPhone(
        username: currentState.username,
        password: _password,
        fullName: skip ? '' : currentState.fullName.trim(),
        nickname: skip ? '' : currentState.nickname.trim(),
        occupation: skip ? '' : currentState.occupation.trim(),
        requiresOccupation: currentState.requiresOccupation,
      ),
    );
  }
}
