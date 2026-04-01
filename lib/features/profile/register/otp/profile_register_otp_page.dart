import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/enums/session/user_role.dart';
import 'package:golf_kakis/features/foundation/session/session_scope.dart';
import 'package:golf_kakis/features/profile/register/details/profile_register_details_page.dart';
import 'package:golf_kakis/features/profile/register/otp/view/profile_register_otp_view.dart';
import 'package:golf_kakis/features/profile/register/otp/viewmodel/profile_register_otp_view_contract.dart';
import 'package:golf_kakis/features/profile/register/otp/viewmodel/profile_register_otp_view_model.dart';

class ProfileRegisterOtpPage extends StatefulWidget {
  const ProfileRegisterOtpPage({
    required this.phoneNumber,
    this.skipAboutYou = false,
    super.key,
  });

  final String phoneNumber;
  final bool skipAboutYou;

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
      phoneNumber: widget.phoneNumber,
      skipAboutYou: widget.skipAboutYou,
    );
    _navEffectSubscription = _viewModel.navEffects.listen((effect) {
      if (effect is RegisterOtpNavigateBack) {
        if (!mounted) {
          return;
        }
        Navigator.of(context).maybePop();
      }

      if (effect is RegisterOtpNavigateToAbout) {
        if (!mounted) {
          return;
        }
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            settings: const RouteSettings(name: _registerDetailsRouteName),
            builder: (_) =>
                ProfileRegisterDetailsPage(phoneNumber: effect.phoneNumber),
          ),
        );
      }

      if (effect is RegisterOtpCompleted) {
        if (!mounted) {
          return;
        }
        SessionScope.of(context).login(
          username: effect.fullName,
          role: UserRole.user,
          profileFullName: effect.fullName,
          profileNickname: effect.nickname,
          profileOccupation: effect.occupation,
          profileEmail: effect.email,
          profilePhoneNumber: effect.phoneNumber,
          profileAvatarIndex: 0,
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
            title: const Text('Phone OTP'),
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
            onContinueClick: () =>
                _viewModel.onUserIntent(const OnRegisterOtpContinueClick()),
          ),
        );
      },
    );
  }
}

const String _registerDetailsRouteName = 'register_details';
const Set<String> _registerRouteNames = <String>{
  'register_method',
  'register_otp',
  'register_details',
};
