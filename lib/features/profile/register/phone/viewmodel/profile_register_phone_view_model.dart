import 'package:golf_kakis/features/foundation/model/snackbar_message_model.dart';
import 'package:golf_kakis/features/foundation/network/network.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_view_model.dart';
import 'package:golf_kakis/features/profile/register/domain/profile_register_use_case.dart';

import 'profile_register_phone_view_contract.dart';

class ProfileRegisterPhoneViewModel
    extends
        MviViewModel<
          ProfileRegisterPhoneUserIntent,
          ProfileRegisterPhoneViewState,
          ProfileRegisterPhoneNavEffect
        >
    implements ProfileRegisterPhoneViewContract {
  ProfileRegisterPhoneViewModel({
    required String username,
    required String password,
    required String fullName,
    required String nickname,
    required String occupation,
    required bool requiresOccupation,
    required ProfileRegisterUseCase useCase,
  }) : _username = username,
       _password = password,
       _fullName = fullName,
       _nickname = nickname,
       _occupation = occupation,
       _requiresOccupation = requiresOccupation,
       _useCase = useCase;

  final String _username;
  final String _password;
  final String _fullName;
  final String _nickname;
  final String _occupation;
  final bool _requiresOccupation;
  final ProfileRegisterUseCase _useCase;

  @override
  ProfileRegisterPhoneViewState createInitialState() {
    return ProfileRegisterPhoneViewState.initial(
      username: _username,
      password: _password,
      fullName: _fullName,
      nickname: _nickname,
      occupation: _occupation,
      requiresOccupation: _requiresOccupation,
    );
  }

  @override
  Future<void> handleIntent(ProfileRegisterPhoneUserIntent intent) async {
    switch (intent) {
      case OnRegisterPhoneChanged():
        emitViewState(
          (state) => state.copyWith(
            phoneNumber: intent.value,
            clearErrorMessage: true,
          ),
        );
      case OnRegisterPhoneContinueClick():
        await _requestOtp(visitorId: intent.visitorId);
      case OnRegisterPhoneBackClick():
        sendNavEffect(() => const RegisterPhoneNavigateBack());
    }
  }

  Future<void> _requestOtp({required String visitorId}) async {
    final phoneNumber = currentState.phoneNumber.trim();
    if (phoneNumber.isEmpty) {
      emitViewState(
        (state) => state.copyWith(
          errorSnackbarMessageModel: const SnackbarMessageModel(
            message: 'Enter your phone number to continue.',
          ),
        ),
      );
      return;
    }

    emitViewState(
      (state) => state.copyWith(isSubmitting: true, clearErrorMessage: true),
    );

    try {
      final response = await _useCase.requestOtp(
        username: currentState.username.trim(),
        password: currentState.password,
        phoneNumber: phoneNumber,
        visitorId: visitorId,
      );

      emitViewState((state) => state.copyWith(isSubmitting: false));
      sendNavEffect(
        () => RegisterPhoneRequestOtpSucceeded(
          response: response,
          username: currentState.username.trim(),
          password: currentState.password,
          fullName: currentState.fullName.trim(),
          nickname: currentState.nickname.trim(),
          occupation: currentState.occupation.trim(),
          requiresOccupation: currentState.requiresOccupation,
        ),
      );
    } on ApiException catch (error) {
      emitViewState(
        (state) => state.copyWith(
          isSubmitting: false,
          errorSnackbarMessageModel: SnackbarMessageModel(
            message: error.message,
          ),
        ),
      );
    } catch (_) {
      emitViewState(
        (state) => state.copyWith(
          isSubmitting: false,
          errorSnackbarMessageModel: const SnackbarMessageModel(
            message: 'Unable to request OTP right now.',
          ),
        ),
      );
    }
  }
}
