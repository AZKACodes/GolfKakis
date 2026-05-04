import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/enums/session/user_role.dart';
import 'package:golf_kakis/features/foundation/session/session_scope.dart';
import 'package:golf_kakis/features/profile/register/domain/profile_register_use_case_impl.dart';
import 'package:golf_kakis/features/profile/register/otp/view/profile_register_otp_view.dart';
import 'package:golf_kakis/features/profile/register/otp/viewmodel/profile_register_otp_view_contract.dart';
import 'package:golf_kakis/features/profile/register/otp/viewmodel/profile_register_otp_view_model.dart';

class ProfileRegisterOtpPage extends StatefulWidget {
  const ProfileRegisterOtpPage({
    required this.username,
    required this.phoneNumber,
    required this.fullName,
    required this.nickname,
    required this.occupation,
    required this.requestMessage,
    this.requiresOccupation = true,
    super.key,
  });

  final String username;
  final String phoneNumber;
  final String fullName;
  final String nickname;
  final String occupation;
  final String requestMessage;
  final bool requiresOccupation;

  @override
  State<ProfileRegisterOtpPage> createState() => _ProfileRegisterOtpPageState();
}

class _ProfileRegisterOtpPageState extends State<ProfileRegisterOtpPage> {
  late final ProfileRegisterOtpViewModel _viewModel;
  StreamSubscription<ProfileRegisterOtpNavEffect>? _navEffectSubscription;

  @override
  void initState() {
    super.initState();
    _viewModel = ProfileRegisterOtpViewModel(
      username: widget.username,
      phoneNumber: widget.phoneNumber,
      fullName: widget.fullName,
      nickname: widget.nickname,
      occupation: widget.occupation,
      requiresOccupation: widget.requiresOccupation,
      useCase: ProfileRegisterUseCaseImpl.create(),
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

    _navEffectSubscription = _viewModel.navEffects.listen((effect) {
      if (effect is RegisterOtpNavigateBack) {
        if (!mounted) {
          return;
        }
        Navigator.of(context).maybePop();
      }

      if (effect is RegisterOtpCompleted) {
        if (!mounted) {
          return;
        }

        final fallbackFullName = effect.fullName.isNotEmpty
            ? effect.fullName
            : effect.username;
        final fallbackNickname = effect.nickname.isNotEmpty
            ? effect.nickname
            : effect.username;
        final fallbackOccupation = effect.occupation.isNotEmpty
            ? effect.occupation
            : 'Golfer';

        SessionScope.of(context).login(
          username: effect.username,
          role: UserRole.user,
          accessToken: effect.response.accessToken,
          authUserId: effect.response.user.userId,
          authId: effect.response.user.authId,
          isPhoneVerified: effect.response.user.isPhoneVerified,
          authCreatedAt: effect.response.user.createdAt,
          authUpdatedAt: effect.response.user.updatedAt,
          profileFullName: fallbackFullName,
          profileNickname: fallbackNickname,
          profileOccupation: fallbackOccupation,
          profilePhoneNumber: effect.response.user.phoneNumber.isNotEmpty
              ? effect.response.user.phoneNumber
              : effect.phoneNumber,
        );
        Navigator.of(context, rootNavigator: true).popUntil(
          (route) => !_registerRouteNames.contains(route.settings.name),
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
            title: const Text('Verify OTP'),
            leading: IconButton(
              onPressed: () =>
                  _viewModel.onUserIntent(const OnRegisterOtpBackClick()),
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          body: ProfileRegisterOtpView(
            state: _viewModel.viewState,
            onOtpChanged: (index, value) => _viewModel.onUserIntent(
              OnRegisterOtpDigitChanged(index: index, value: value),
            ),
            onContinueClick: () => _viewModel.onUserIntent(
              OnRegisterOtpContinueClick(
                visitorId: SessionScope.of(context).deviceId,
              ),
            ),
          ),
        );
      },
    );
  }
}

const Set<String> _registerRouteNames = <String>{
  'profile_login',
  'register_method',
  'register_otp',
  'register_details',
  'register_phone',
};
