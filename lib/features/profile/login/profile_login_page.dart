import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/session/session_scope.dart';
import 'package:golf_kakis/features/profile/login/domain/profile_login_use_case_impl.dart';
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
      case RequestOtpSucceeded():
        final result = await Navigator.of(context).push<LoginOtpSuccessResult>(
          MaterialPageRoute<LoginOtpSuccessResult>(
            settings: const RouteSettings(name: _loginOtpRouteName),
            builder: (_) => ProfileLoginOtpPage(
              username: effect.username,
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
          username: result.username,
          role: result.role,
          accessToken: result.response.accessToken,
          authUserId: result.response.user.userId,
          authId: result.response.user.authId,
          isPhoneVerified: result.response.user.isPhoneVerified,
          authCreatedAt: result.response.user.createdAt,
          authUpdatedAt: result.response.user.updatedAt,
          profileFullName: result.response.user.name.isNotEmpty
              ? result.response.user.name
              : result.username,
          profilePhoneNumber: result.response.user.phoneNumber,
        );
        Navigator.of(context).maybePop();
      case RegisterRequested():
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            settings: const RouteSettings(name: 'register_method'),
            builder: (_) =>
                const ProfileRegisterMethodPage(requiresOccupation: true),
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
