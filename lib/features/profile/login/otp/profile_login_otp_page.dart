import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/enums/session/user_role.dart';
import 'package:golf_kakis/features/foundation/session/session_scope.dart';
import 'package:golf_kakis/features/profile/api/profile_api_service.dart';
import 'package:golf_kakis/features/profile/login/domain/profile_login_use_case_impl.dart';
import 'package:golf_kakis/features/profile/login/otp/view/profile_login_otp_view.dart';
import 'package:golf_kakis/features/profile/login/otp/viewmodel/profile_login_otp_view_contract.dart';
import 'package:golf_kakis/features/profile/login/otp/viewmodel/profile_login_otp_view_model.dart';

class ProfileLoginOtpPage extends StatefulWidget {
  const ProfileLoginOtpPage({
    required this.username,
    required this.phoneNumber,
    required this.requestMessage,
    required this.visitorId,
    super.key,
  });

  final String username;
  final String phoneNumber;
  final String requestMessage;
  final String visitorId;

  @override
  State<ProfileLoginOtpPage> createState() => _ProfileLoginOtpPageState();
}

class _ProfileLoginOtpPageState extends State<ProfileLoginOtpPage> {
  late final ProfileLoginOtpViewModel _viewModel;
  StreamSubscription<ProfileLoginOtpNavEffect>? _navEffectSubscription;

  @override
  void initState() {
    super.initState();
    _viewModel = ProfileLoginOtpViewModel(
      username: widget.username,
      phoneNumber: widget.phoneNumber,
      useCase: ProfileLoginUseCaseImpl.create(),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.requestMessage),
          duration: const Duration(seconds: 5),
        ),
      );
    });

    _navEffectSubscription = _viewModel.navEffects.listen(_handleNavEffect);
  }

  @override
  void dispose() {
    _navEffectSubscription?.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  void _handleNavEffect(ProfileLoginOtpNavEffect effect) {
    if (!mounted) {
      return;
    }

    switch (effect) {
      case LoginOtpNavigateBack():
        Navigator.of(context).maybePop();
      case LoginOtpVerified():
        Navigator.of(context).pop(
          LoginOtpSuccessResult(
            response: effect.response,
            username: effect.username,
            role: UserRole.user,
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
            title: const Text('Verify OTP'),
            leading: IconButton(
              onPressed: () =>
                  _viewModel.onUserIntent(const OnLoginOtpBackClick()),
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          body: ProfileLoginOtpView(
            state: _viewModel.viewState,
            onUserIntent: (intent) {
              switch (intent) {
                case OnLoginOtpVerifyClick():
                  _viewModel.onUserIntent(
                    OnLoginOtpVerifyClick(
                      visitorId: SessionScope.of(context).deviceId,
                    ),
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

class LoginOtpSuccessResult {
  const LoginOtpSuccessResult({
    required this.response,
    required this.username,
    required this.role,
  });

  final VerifyOtpResponse response;
  final String username;
  final UserRole role;
}
