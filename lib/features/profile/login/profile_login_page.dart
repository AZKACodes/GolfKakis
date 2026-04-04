import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/enums/session/user_role.dart';
import 'package:golf_kakis/features/foundation/session/session_scope.dart';
import 'package:golf_kakis/features/profile/register/method/profile_register_method_page.dart';

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
    _viewModel = ProfileLoginViewModel();
    _navEffectSubscription = _viewModel.navEffects.listen((effect) {
      if (effect is NavigateBack) {
        if (!mounted) {
          return;
        }
        Navigator.of(context).maybePop();
      }

      if (effect is LoginSucceeded) {
        if (!mounted) {
          return;
        }
        if (effect.role == UserRole.guest) {
          SessionScope.of(context).logout();
        } else {
          SessionScope.of(
            context,
          ).login(username: effect.username, role: effect.role);
        }
        Navigator.of(context).maybePop();
      }

      if (effect is RegisterRequested) {
        if (!mounted) {
          return;
        }
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            settings: const RouteSettings(name: 'register_method'),
            builder: (_) =>
                const ProfileRegisterMethodPage(requiresOccupation: true),
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
            title: const Text('Login'),
            leading: IconButton(
              onPressed: () => _viewModel.onUserIntent(const OnBackClick()),
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          body: ProfileLoginView(
            state: _viewModel.viewState,
            onLoginMethodChanged: (value) =>
                _viewModel.onUserIntent(OnLoginMethodChanged(value)),
            onEmailChanged: (value) =>
                _viewModel.onUserIntent(OnEmailChanged(value)),
            onCountryCodeChanged: (value) =>
                _viewModel.onUserIntent(OnCountryCodeChanged(value)),
            onPhoneChanged: (value) =>
                _viewModel.onUserIntent(OnPhoneChanged(value)),
            onPasswordChanged: (value) =>
                _viewModel.onUserIntent(OnPasswordChanged(value)),
            onLoginClick: (role) => _viewModel.onUserIntent(OnLoginClick(role)),
            onRegisterClick: () =>
                _viewModel.onUserIntent(const OnRegisterClick()),
          ),
        );
      },
    );
  }
}
