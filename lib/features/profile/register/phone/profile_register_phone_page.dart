import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/session/session_scope.dart';
import 'package:golf_kakis/features/profile/register/domain/profile_register_use_case_impl.dart';
import 'package:golf_kakis/features/profile/register/otp/profile_register_otp_page.dart';
import 'package:golf_kakis/features/profile/register/phone/view/profile_register_phone_view.dart';
import 'package:golf_kakis/features/profile/register/phone/viewmodel/profile_register_phone_view_contract.dart';
import 'package:golf_kakis/features/profile/register/phone/viewmodel/profile_register_phone_view_model.dart';

class ProfileRegisterPhonePage extends StatefulWidget {
  const ProfileRegisterPhonePage({
    required this.username,
    required this.password,
    required this.fullName,
    required this.nickname,
    required this.occupation,
    this.requiresOccupation = true,
    super.key,
  });

  final String username;
  final String password;
  final String fullName;
  final String nickname;
  final String occupation;
  final bool requiresOccupation;

  @override
  State<ProfileRegisterPhonePage> createState() =>
      _ProfileRegisterPhonePageState();
}

class _ProfileRegisterPhonePageState extends State<ProfileRegisterPhonePage> {
  late final ProfileRegisterPhoneViewModel _viewModel;
  StreamSubscription<ProfileRegisterPhoneNavEffect>? _navEffectSubscription;

  @override
  void initState() {
    super.initState();
    _viewModel = ProfileRegisterPhoneViewModel(
      username: widget.username,
      password: widget.password,
      fullName: widget.fullName,
      nickname: widget.nickname,
      occupation: widget.occupation,
      requiresOccupation: widget.requiresOccupation,
      useCase: ProfileRegisterUseCaseImpl.create(),
    );
    _navEffectSubscription = _viewModel.navEffects.listen(_handleNavEffect);
  }

  @override
  void dispose() {
    _navEffectSubscription?.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _handleNavEffect(ProfileRegisterPhoneNavEffect effect) async {
    if (!mounted) {
      return;
    }

    switch (effect) {
      case RegisterPhoneNavigateBack():
        Navigator.of(context).maybePop();
      case RegisterPhoneRequestOtpSucceeded():
        await Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            settings: const RouteSettings(name: _registerOtpRouteName),
            builder: (_) => ProfileRegisterOtpPage(
              username: effect.username,
              phoneNumber: effect.response.normalizedPhoneNumber.isNotEmpty
                  ? effect.response.normalizedPhoneNumber
                  : effect.response.phoneNumber,
              fullName: effect.fullName,
              nickname: effect.nickname,
              occupation: effect.occupation,
              requiresOccupation: effect.requiresOccupation,
              requestMessage: effect.response.message,
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Phone Number'),
            leading: IconButton(
              onPressed: () =>
                  _viewModel.onUserIntent(const OnRegisterPhoneBackClick()),
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          body: ProfileRegisterPhoneView(
            state: _viewModel.viewState,
            onPhoneChanged: (value) =>
                _viewModel.onUserIntent(OnRegisterPhoneChanged(value)),
            onContinueClick: () => _viewModel.onUserIntent(
              OnRegisterPhoneContinueClick(
                visitorId: SessionScope.of(context).deviceId,
              ),
            ),
          ),
        );
      },
    );
  }
}

const String _registerOtpRouteName = 'register_otp';
