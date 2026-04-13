import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/enums/session/user_role.dart';
import 'package:golf_kakis/features/foundation/session/session_scope.dart';
import 'package:golf_kakis/features/profile/login/otp/profile_login_otp_page.dart';
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
    _navEffectSubscription = _viewModel.navEffects.listen((effect) async {
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
        SessionScope.of(
          context,
        ).login(username: effect.username, role: effect.role);
        Navigator.of(context).maybePop();
      }

      if (effect is RequestOtpSucceeded) {
        if (!mounted) {
          return;
        }
        final result = await Navigator.of(context).push<LoginOtpSuccessResult>(
          MaterialPageRoute<LoginOtpSuccessResult>(
            settings: const RouteSettings(name: _loginOtpRouteName),
            builder: (_) => ProfileLoginOtpPage(
              name: effect.response.name,
              phoneNumber: effect.response.normalizedPhoneNumber.isNotEmpty
                  ? effect.response.normalizedPhoneNumber
                  : effect.response.phoneNumber,
              requestMessage: effect.response.message,
              visitorId: SessionScope.of(context).deviceId,
            ),
          ),
        );

        if (!mounted || result == null) {
          return;
        }

        SessionScope.of(context).login(
          username: result.response.user.name,
          role: UserRole.user,
          accessToken: result.response.accessToken,
          authUserId: result.response.user.userId,
          authId: result.response.user.authId,
          isPhoneVerified: result.response.user.isPhoneVerified,
          authCreatedAt: result.response.user.createdAt,
          authUpdatedAt: result.response.user.updatedAt,
          profileFullName: result.response.user.name,
          profilePhoneNumber: result.response.user.phoneNumber,
        );
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
            onNameChanged: (value) =>
                _viewModel.onUserIntent(OnNameChanged(value)),
            onCountryCodeChanged: (value) =>
                _viewModel.onUserIntent(OnCountryCodeChanged(value)),
            onPhoneChanged: (value) =>
                _viewModel.onUserIntent(OnPhoneChanged(value)),
            onLoginClick: () => _viewModel.onUserIntent(
              OnLoginClick(visitorId: SessionScope.of(context).deviceId),
            ),
            onRegisterClick: () =>
                _viewModel.onUserIntent(const OnRegisterClick()),
          ),
        );
      },
    );
  }
}

const String _loginOtpRouteName = 'login_otp';
