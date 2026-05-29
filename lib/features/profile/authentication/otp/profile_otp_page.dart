import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/enums/session/user_role.dart';
import 'package:golf_kakis/features/foundation/security/captcha/turnstile_captcha_token_provider.dart';
import 'package:golf_kakis/features/foundation/session/session_scope.dart';
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
  String? _lastErrorSnackbarMessage;

  @override
  void initState() {
    super.initState();
    _viewModel = ProfileOtpViewModel(
      purpose: widget.purpose,
      username: widget.username,
      phoneNumber: widget.phoneNumber,
      otpUseCase: ProfileOtpUseCaseImpl.create(),
      captchaTokenProvider: TurnstileCaptchaTokenProvider(context: context),
    );
    _navEffectSubscription = _viewModel.navEffects.listen((effect) {
      unawaited(_handleNavEffect(effect));
    });

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

  Future<void> _handleNavEffect(ProfileOtpNavEffect effect) async {
    if (!mounted) {
      return;
    }

    switch (effect) {
      case ProfileOtpNavigateBack():
        Navigator.of(context).maybePop();
      case ProfileOtpPinSetupRequired():
        final didSaveSession = _saveVerifiedRegistrationSession(effect);
        if (didSaveSession) {
          try {
            await SessionScope.of(context).refreshSession();
          } catch (_) {
            if (!mounted) {
              return;
            }
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(content: Text('Unable to refresh app session.')),
              );
            return;
          }
          if (!mounted) {
            return;
          }
        }
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

  bool _saveVerifiedRegistrationSession(ProfileOtpPinSetupRequired effect) {
    final response = effect.response;
    if (!response.hasSessionDetails) {
      return false;
    }

    final user = response.user;
    final session = response.session;
    final accessToken = session?.accessToken.isNotEmpty == true
        ? session!.accessToken
        : response.accessToken;
    final refreshToken = session?.refreshToken.isNotEmpty == true
        ? session!.refreshToken
        : response.refreshToken;
    final displayName = user?.name.isNotEmpty == true
        ? user!.name
        : effect.username;
    final phoneNumber = user?.phoneNumber.isNotEmpty == true
        ? user!.phoneNumber
        : effect.phoneNumber;

    SessionScope.of(context).login(
      username: displayName,
      role: _roleFromName(user?.roleName ?? ''),
      accessToken: accessToken,
      refreshToken: refreshToken,
      sessionId: session?.sessionId,
      sessionExpiresInSeconds: session?.expiresInSeconds,
      refreshExpiresAt: session?.refreshExpiresAt,
      authUserId: user?.userId,
      authId: user?.authId,
      isPhoneVerified: user?.isPhoneVerified,
      authCreatedAt: user?.createdAt,
      authUpdatedAt: user?.updatedAt,
      profileFullName: displayName,
      profileNickname: user?.username,
      profilePhoneNumber: phoneNumber,
      hasPin: user?.hasPin,
      hasPasskey: user?.hasPasskey,
      hasOTPFallback: true,
    );
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        _showErrorSnackbarIfNeeded(_viewModel.viewState);
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

  void _showErrorSnackbarIfNeeded(ProfileOtpViewState state) {
    final message = state.errorMessage;
    if (message == null) {
      _lastErrorSnackbarMessage = null;
      return;
    }

    if (_lastErrorSnackbarMessage == message) {
      return;
    }

    _lastErrorSnackbarMessage = message;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    });
  }
}

UserRole _roleFromName(String roleName) {
  for (final role in UserRole.values) {
    if (role.name == roleName.trim().toLowerCase()) {
      return role;
    }
  }
  return UserRole.user;
}
