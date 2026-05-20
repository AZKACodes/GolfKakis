import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golf_kakis/features/profile/authentication/otp/profile_otp_page.dart';
import 'package:golf_kakis/features/profile/authentication/otp/viewmodel/profile_otp_view_contract.dart';

import 'view/profile_register_view.dart';
import 'viewmodel/profile_register_view_contract.dart';
import 'viewmodel/profile_register_view_model.dart';

class ProfileRegisterPage extends StatefulWidget {
  const ProfileRegisterPage({super.key});

  @override
  State<ProfileRegisterPage> createState() => _ProfileRegisterPageState();
}

class _ProfileRegisterPageState extends State<ProfileRegisterPage> {
  late final ProfileRegisterViewModel _viewModel;
  StreamSubscription<ProfileRegisterNavEffect>? _navEffectSubscription;

  @override
  void initState() {
    super.initState();
    _viewModel = ProfileRegisterViewModel();
    _navEffectSubscription = _viewModel.navEffects.listen(_handleNavEffect);
  }

  @override
  void dispose() {
    _navEffectSubscription?.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _handleNavEffect(ProfileRegisterNavEffect effect) async {
    if (!mounted) {
      return;
    }

    switch (effect) {
      case RegisterNavigateBack():
        Navigator.of(context).maybePop();
      case RegisterSubmitted():
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            settings: const RouteSettings(name: _registerOtpRouteName),
            builder: (_) => ProfileOtpPage(
              purpose: ProfileOtpPurpose.register,
              username: effect.name,
              phoneNumber: effect.phoneNumber,
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
            title: const Text('Register'),
            leading: IconButton(
              onPressed: () =>
                  _viewModel.onUserIntent(const OnRegisterBackClick()),
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          body: ProfileRegisterView(
            state: _viewModel.viewState,
            onNameChanged: (value) =>
                _viewModel.onUserIntent(OnRegisterNameChanged(value)),
            onPhoneChanged: (value) =>
                _viewModel.onUserIntent(OnRegisterPhoneChanged(value)),
            onRegisterClick: _confirmRegister,
          ),
        );
      },
    );
  }

  Future<void> _confirmRegister() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm phone number'),
        content: Text(
          'Are you sure you want to use this number?\n\n'
          '${_viewModel.viewState.phoneNumber}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) {
      return;
    }

    _viewModel.onUserIntent(const OnRegisterContinueClick());
  }
}

const String _registerOtpRouteName = 'register_otp';
