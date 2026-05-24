import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/enums/session/user_role.dart';
import 'package:golf_kakis/features/foundation/root/root_screen.dart';
import 'package:golf_kakis/features/foundation/session/session_scope.dart';
import 'package:golf_kakis/features/profile/authentication/otp/profile_otp_page.dart';
import 'package:golf_kakis/features/profile/authentication/otp/viewmodel/profile_otp_view_contract.dart';
import 'package:golf_kakis/features/profile/authentication/pin/domain/profile_pin_use_case_impl.dart';

import 'view/profile_pin_view.dart';
import 'viewmodel/profile_pin_view_contract.dart';
import 'viewmodel/profile_pin_view_model.dart';

class ProfilePinPage extends StatefulWidget {
  const ProfilePinPage({
    required this.mode,
    required this.phoneNumber,
    this.pinSetupToken = '',
    this.username = '',
    this.hasOTPFallback = false,
    super.key,
  });

  final ProfilePinMode mode;
  final String pinSetupToken;
  final String username;
  final String phoneNumber;
  final bool hasOTPFallback;

  @override
  State<ProfilePinPage> createState() => _ProfilePinPageState();
}

class _ProfilePinPageState extends State<ProfilePinPage> {
  late final ProfilePinViewModel _viewModel;
  StreamSubscription<ProfilePinNavEffect>? _navEffectSubscription;

  @override
  void initState() {
    super.initState();
    _viewModel = ProfilePinViewModel(
      mode: widget.mode,
      pinSetupToken: widget.pinSetupToken,
      phoneNumber: widget.phoneNumber,
      hasOTPFallback: widget.hasOTPFallback,
      useCase: ProfilePinUseCaseImpl.create(),
    );
    _navEffectSubscription = _viewModel.navEffects.listen(_handleNavEffect);
  }

  @override
  void dispose() {
    _navEffectSubscription?.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  void _handleNavEffect(ProfilePinNavEffect effect) {
    if (!mounted) {
      return;
    }

    switch (effect) {
      case ProfilePinNavigateBack():
        Navigator.of(context).maybePop();
      case ProfilePinSetupCompleted():
        final response = effect.response;
        final accessToken = response.session.accessToken.isNotEmpty
            ? response.session.accessToken
            : response.accessToken;
        final refreshToken = response.session.refreshToken.isNotEmpty
            ? response.session.refreshToken
            : response.refreshToken;
        final displayName = response.user.name.isNotEmpty
            ? response.user.name
            : widget.username;
        final phoneNumber = response.user.phoneNumber.isNotEmpty
            ? response.user.phoneNumber
            : widget.phoneNumber;

        SessionScope.of(context).login(
          username: displayName,
          role: UserRole.user,
          accessToken: accessToken,
          refreshToken: refreshToken,
          sessionId: response.session.sessionId,
          sessionExpiresInSeconds: response.session.expiresInSeconds,
          refreshExpiresAt: response.session.refreshExpiresAt,
          authUserId: response.user.userId,
          isPhoneVerified: response.user.isPhoneVerified,
          profileFullName: displayName,
          profilePhoneNumber: phoneNumber,
          hasPin: response.user.hasPin,
          hasPasskey: response.user.hasPasskey,
          hasOTPFallback: true,
        );
        RootScreen.selectTab(2);
        Navigator.of(
          context,
          rootNavigator: true,
        ).popUntil((route) => route.isFirst);
      case ProfileForgotPinRequested():
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            settings: const RouteSettings(name: 'pin_reset_otp'),
            builder: (_) => ProfileOtpPage(
              purpose: ProfileOtpPurpose.pinReset,
              username: widget.phoneNumber,
              phoneNumber: widget.phoneNumber,
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
            title: Text(
              widget.mode == ProfilePinMode.login ? 'Enter PIN' : 'Create PIN',
            ),
            leading: IconButton(
              onPressed: () =>
                  _viewModel.onUserIntent(const OnProfilePinBackClick()),
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          body: ProfilePinView(
            state: _viewModel.viewState,
            onPinChanged: (value) =>
                _viewModel.onUserIntent(OnProfilePinChanged(value)),
            onConfirmPinChanged: (value) =>
                _viewModel.onUserIntent(OnProfileConfirmPinChanged(value)),
            onForgotPinClick: () =>
                _viewModel.onUserIntent(const OnProfileForgotPinClick()),
          ),
        );
      },
    );
  }
}
