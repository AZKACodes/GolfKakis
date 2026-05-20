import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/session/session_scope.dart';
import 'package:golf_kakis/features/profile/authentication/login/domain/profile_login_use_case_impl.dart';
import 'package:golf_kakis/features/profile/authentication/otp/profile_otp_page.dart';
import 'package:golf_kakis/features/profile/authentication/otp/viewmodel/profile_otp_view_contract.dart';
import 'package:golf_kakis/features/profile/authentication/pin/profile_pin_page.dart';
import 'package:golf_kakis/features/profile/authentication/pin/viewmodel/profile_pin_view_contract.dart';
import 'package:golf_kakis/features/profile/authentication/register/profile_register_page.dart';

import 'view/profile_login_view.dart';
import 'viewmodel/profile_login_view_contract.dart';
import 'viewmodel/profile_login_view_model.dart';

class ProfileLoginPage extends StatefulWidget {
  const ProfileLoginPage({super.key});

  @override
  State<ProfileLoginPage> createState() => _ProfileLoginPageState();
}

class _ProfileLoginPageState extends State<ProfileLoginPage> {
  late final ProfileLoginViewModel _viewModel;
  StreamSubscription<ProfileLoginNavEffect>? _navEffectSubscription;

  @override
  void initState() {
    super.initState();
    _viewModel = ProfileLoginViewModel(
      useCase: ProfileLoginUseCaseImpl.create(),
    );
    _navEffectSubscription = _viewModel.navEffects.listen(_handleNavEffect);
  }

  @override
  void dispose() {
    _navEffectSubscription?.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _handleNavEffect(ProfileLoginNavEffect effect) async {
    if (!mounted) {
      return;
    }

    switch (effect) {
      case NavigateBack():
        Navigator.of(context).maybePop();
      case LoginMethodsLoaded():
        SessionScope.of(context).updateLoginMethods(
          hasPin: effect.response.hasPin,
          hasPasskey: effect.response.hasPasskey,
          hasOTPFallback: effect.response.hasOTPFallback,
        );
        if (effect.response.hasPin) {
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              settings: const RouteSettings(name: 'profile_pin_login'),
              builder: (_) => ProfilePinPage(
                mode: ProfilePinMode.login,
                phoneNumber: effect.phoneNumber,
                hasOTPFallback: effect.response.hasOTPFallback,
              ),
            ),
          );
        } else if (effect.response.hasOTPFallback) {
          await _openPinResetOtp(effect.phoneNumber);
        }
      case RegisterRequested():
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            settings: const RouteSettings(name: 'profile_register'),
            builder: (_) => const ProfileRegisterPage(),
          ),
        );
    }
  }

  Future<void> _openPinResetOtp(String phoneNumber) async {
    await Navigator.of(context).push<ProfileOtpSuccessResult>(
      MaterialPageRoute<ProfileOtpSuccessResult>(
        settings: const RouteSettings(name: _loginOtpRouteName),
        builder: (_) => ProfileOtpPage(
          purpose: ProfileOtpPurpose.pinReset,
          username: phoneNumber,
          phoneNumber: phoneNumber,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Login'),
            leading: IconButton(
              onPressed: () => _viewModel.onUserIntent(const OnBackClick()),
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          body: ProfileLoginView(
            state: _viewModel.viewState,
            onUserIntent: (intent) {
              switch (intent) {
                case OnLoginClick():
                  _viewModel.onUserIntent(
                    OnLoginClick(visitorId: SessionScope.of(context).deviceId),
                  );
                default:
                  _viewModel.onUserIntent(intent);
              }
            },
          ),
        );
      },
    );
  }
}

const String _loginOtpRouteName = 'login_otp';
