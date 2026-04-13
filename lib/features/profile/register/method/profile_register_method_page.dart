import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/session/session_scope.dart';
import 'package:golf_kakis/features/profile/register/method/view/profile_register_method_view.dart';
import 'package:golf_kakis/features/profile/register/method/viewmodel/profile_register_method_view_contract.dart';
import 'package:golf_kakis/features/profile/register/method/viewmodel/profile_register_method_view_model.dart';
import 'package:golf_kakis/features/profile/register/otp/profile_register_otp_page.dart';

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

      if (effect is RegisterMethodNavigateToOtp) {
        if (!mounted) {
          return;
        }
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            settings: const RouteSettings(name: _registerOtpRouteName),
            builder: (_) => ProfileRegisterOtpPage(
              name: effect.response.name,
              phoneNumber: effect.response.normalizedPhoneNumber.isNotEmpty
                  ? effect.response.normalizedPhoneNumber
                  : effect.response.phoneNumber,
              password: effect.password,
              requestMessage: effect.response.message,
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
            onNameChanged: (value) =>
                _viewModel.onUserIntent(OnRegisterNameChanged(value)),
            onCountryCodeSelected: (value) =>
                _viewModel.onUserIntent(OnRegisterCountryCodeSelected(value)),
            onPhoneChanged: (value) =>
                _viewModel.onUserIntent(OnRegisterPhoneChanged(value)),
            onContinueClick: () => _viewModel.onUserIntent(
              OnRegisterMethodContinueClick(
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
