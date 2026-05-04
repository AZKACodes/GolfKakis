import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golf_kakis/features/profile/register/phone/profile_register_phone_page.dart';
import 'package:golf_kakis/features/profile/register/details/view/profile_register_details_view.dart';
import 'package:golf_kakis/features/profile/register/details/viewmodel/profile_register_details_view_contract.dart';
import 'package:golf_kakis/features/profile/register/details/viewmodel/profile_register_details_view_model.dart';

class ProfileRegisterDetailsPage extends StatefulWidget {
  const ProfileRegisterDetailsPage({
    required this.username,
    required this.password,
    this.requiresOccupation = true,
    super.key,
  });

  final String username;
  final String password;
  final bool requiresOccupation;

  @override
  State<ProfileRegisterDetailsPage> createState() =>
      _ProfileRegisterDetailsPageState();
}

class _ProfileRegisterDetailsPageState
    extends State<ProfileRegisterDetailsPage> {
  late final ProfileRegisterDetailsViewModel _viewModel;
  StreamSubscription<ProfileRegisterDetailsNavEffect>? _navEffectSubscription;

  @override
  void initState() {
    super.initState();
    _viewModel = ProfileRegisterDetailsViewModel(
      username: widget.username,
      password: widget.password,
      requiresOccupation: widget.requiresOccupation,
    );
    _navEffectSubscription = _viewModel.navEffects.listen((effect) {
      if (effect is RegisterDetailsNavigateBack) {
        if (!mounted) {
          return;
        }
        Navigator.of(context).maybePop();
      }

      if (effect is RegisterDetailsNavigateToPhone) {
        if (!mounted) {
          return;
        }
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            settings: const RouteSettings(name: _registerPhoneRouteName),
            builder: (_) => ProfileRegisterPhonePage(
              username: effect.username,
              password: effect.password,
              fullName: effect.fullName,
              nickname: effect.nickname,
              occupation: effect.occupation,
              requiresOccupation: effect.requiresOccupation,
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _navEffectSubscription?.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('About You'),
            leading: IconButton(
              onPressed: () =>
                  _viewModel.onUserIntent(const OnRegisterDetailsBackClick()),
              icon: const Icon(Icons.arrow_back),
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    _viewModel.onUserIntent(const OnRegisterDetailsSkipClick()),
                child: const Text('Skip'),
              ),
            ],
          ),
          body: ProfileRegisterDetailsView(
            state: _viewModel.viewState,
            onFullNameChanged: (value) =>
                _viewModel.onUserIntent(OnRegisterFullNameChanged(value)),
            onNicknameChanged: (value) =>
                _viewModel.onUserIntent(OnRegisterNicknameChanged(value)),
            onOccupationChanged: (value) =>
                _viewModel.onUserIntent(OnRegisterOccupationChanged(value)),
            onContinueClick: () =>
                _viewModel.onUserIntent(const OnRegisterDetailsContinueClick()),
            onSkipClick: () =>
                _viewModel.onUserIntent(const OnRegisterDetailsSkipClick()),
          ),
        );
      },
    );
  }
}

const String _registerPhoneRouteName = 'register_phone';
