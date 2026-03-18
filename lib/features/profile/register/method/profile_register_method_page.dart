import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golf_kakis/features/profile/register/method/view/profile_register_method_view.dart';
import 'package:golf_kakis/features/profile/register/method/viewmodel/profile_register_method_view_contract.dart';
import 'package:golf_kakis/features/profile/register/method/viewmodel/profile_register_method_view_model.dart';
import 'package:golf_kakis/features/profile/register/otp/profile_register_otp_page.dart';

class ProfileRegisterMethodPage extends StatefulWidget {
  const ProfileRegisterMethodPage({super.key});

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
    _navEffectSubscription = _viewModel.navEffects.listen((effect) {
      if (effect is RegisterMethodNavigateBack) {
        if (!mounted) {
          return;
        }
        Navigator.of(context).maybePop();
      }

      if (effect is RegisterMethodNavigateToOtp) {
        if (!mounted) {
          return;
        }
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) =>
                ProfileRegisterOtpPage(phoneNumber: effect.phoneNumber),
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
            onMethodSelected: (method) =>
                _viewModel.onUserIntent(OnRegisterMethodSelected(method)),
            onPhoneChanged: (value) =>
                _viewModel.onUserIntent(OnRegisterPhoneChanged(value)),
            onContinueClick: () =>
                _viewModel.onUserIntent(const OnRegisterMethodContinueClick()),
          ),
        );
      },
    );
  }
}
