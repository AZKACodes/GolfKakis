import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/enums/session/user_role.dart';
import 'package:golf_kakis/features/foundation/security/captcha/turnstile_captcha_token_provider.dart';
import 'package:golf_kakis/features/foundation/session/session_scope.dart';
import 'package:golf_kakis/features/profile/api/profile_api_service.dart';
import 'package:golf_kakis/features/profile/authentication/login/domain/profile_login_use_case_impl.dart';
import 'package:golf_kakis/features/profile/authentication/otp/domain/profile_otp_use_case_impl.dart';
import 'package:golf_kakis/features/profile/authentication/pin/profile_pin_page.dart';
import 'package:golf_kakis/features/profile/authentication/pin/viewmodel/profile_pin_view_contract.dart';

import 'view/profile_otp_view.dart';
import 'viewmodel/profile_otp_view_contract.dart';
import 'viewmodel/profile_otp_view_model.dart';

class ProfileOtpPage extends StatefulWidget {
  const ProfileOtpPage({
    required this.purpose,
    required this.username,
    required this.phoneNumber,
    this.requestMessage = '',
    super.key,
  });

  final ProfileOtpPurpose purpose;
  final String username;
  final String phoneNumber;
  final String requestMessage;

  @override
  State<ProfileOtpPage> createState() => _ProfileOtpPageState();
}

class _ProfileOtpPageState extends State<ProfileOtpPage> {
  late final ProfileOtpViewModel _viewModel;
  StreamSubscription<ProfileOtpNavEffect>? _navEffectSubscription;

  @override
  void initState() {
    super.initState();
    _viewModel = ProfileOtpViewModel(
      purpose: widget.purpose,
      username: widget.username,
      phoneNumber: widget.phoneNumber,
      loginUseCase: ProfileLoginUseCaseImpl.create(),
      otpUseCase: ProfileOtpUseCaseImpl.create(),
      captchaTokenProvider: TurnstileCaptchaTokenProvider(context: context),
    );
    _navEffectSubscription = _viewModel.navEffects.listen(_handleNavEffect);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      if (widget.requestMessage.trim().isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.requestMessage),
            duration: const Duration(seconds: 5),
          ),
        );
      }

      _viewModel.onUserIntent(
        OnProfileOtpInit(visitorId: SessionScope.of(context).deviceId),
      );
    });
  }

  @override
  void dispose() {
    _navEffectSubscription?.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  void _handleNavEffect(ProfileOtpNavEffect effect) {
    if (!mounted) {
      return;
    }

    switch (effect) {
      case ProfileOtpNavigateBack():
        Navigator.of(context).maybePop();
      case ProfileOtpVerified():
        Navigator.of(context).pop(
          ProfileOtpSuccessResult(
            response: effect.response,
            username: effect.username,
            role: UserRole.user,
          ),
        );
      case ProfileOtpPinSetupRequired():
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            settings: const RouteSettings(name: 'profile_pin'),
            builder: (_) => ProfilePinPage(
              mode: ProfilePinMode.setup,
              pinSetupToken: effect.pinSetupToken,
              username: effect.username,
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
            title: const Text('Verify OTP'),
            leading: IconButton(
              onPressed: () =>
                  _viewModel.onUserIntent(const OnProfileOtpBackClick()),
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          body: ProfileOtpView(
            state: _viewModel.viewState,
            onUserIntent: (intent) {
              switch (intent) {
                case OnProfileOtpVerifyClick():
                  _viewModel.onUserIntent(
                    OnProfileOtpVerifyClick(
                      visitorId: SessionScope.of(context).deviceId,
                    ),
                  );
                case OnProfileOtpResendClick():
                  _viewModel.onUserIntent(
                    OnProfileOtpResendClick(
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

class ProfileOtpSuccessResult {
  const ProfileOtpSuccessResult({
    required this.response,
    required this.username,
    required this.role,
  });

  final VerifyOtpResponse response;
  final String username;
  final UserRole role;
}
