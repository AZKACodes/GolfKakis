import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golf_kakis/features/profile/register/details/profile_register_details_page.dart';
import 'package:golf_kakis/features/profile/register/method/view/profile_register_method_view.dart';
import 'package:golf_kakis/features/profile/register/method/viewmodel/profile_register_method_view_contract.dart';
import 'package:golf_kakis/features/profile/register/method/viewmodel/profile_register_method_view_model.dart';

class ProfileRegisterMethodPage extends StatefulWidget {
  const ProfileRegisterMethodPage({this.requiresOccupation = true, super.key});

  final bool requiresOccupation;

  @override
  State<ProfileRegisterMethodPage> createState() =>
      _ProfileRegisterMethodPageState();
}

class _ProfileRegisterMethodPageState extends State<ProfileRegisterMethodPage> {
  late final ProfileRegisterMethodViewModel _viewModel;
  StreamSubscription<ProfileRegisterMethodNavEffect>? _navEffectSubscription;

  @override
  void initState() {
    super.initState();
    _viewModel = ProfileRegisterMethodViewModel();
    _navEffectSubscription = _viewModel.navEffects.listen((effect) async {
      if (effect is RegisterMethodNavigateBack) {
        if (!mounted) {
          return;
        }
        Navigator.of(context).maybePop();
      }

      if (effect is RegisterMethodNavigateToAbout) {
        if (!mounted) {
          return;
        }
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            settings: const RouteSettings(name: _registerDetailsRouteName),
            builder: (_) => ProfileRegisterDetailsPage(
              username: effect.username,
              password: effect.password,
              requiresOccupation: widget.requiresOccupation,
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
            title: const Text('Register'),
            leading: IconButton(
              onPressed: () =>
                  _viewModel.onUserIntent(const OnRegisterMethodBackClick()),
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          body: ProfileRegisterMethodView(
            state: _viewModel.viewState,
            onUsernameChanged: (value) =>
                _viewModel.onUserIntent(OnRegisterUsernameChanged(value)),
            onPasswordChanged: (value) =>
                _viewModel.onUserIntent(OnRegisterPasswordChanged(value)),
            onConfirmPasswordChanged: (value) => _viewModel.onUserIntent(
              OnRegisterConfirmPasswordChanged(value),
            ),
            onContinueClick: () =>
                _viewModel.onUserIntent(const OnRegisterMethodContinueClick()),
          ),
        );
      },
    );
  }
}

const String _registerDetailsRouteName = 'register_details';
