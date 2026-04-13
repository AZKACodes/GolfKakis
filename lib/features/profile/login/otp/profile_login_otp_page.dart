import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/session/session_scope.dart';
import 'package:golf_kakis/features/profile/api/profile_api_service.dart';
import 'package:golf_kakis/features/profile/login/otp/view/profile_login_otp_view.dart';
import 'package:golf_kakis/features/profile/login/otp/viewmodel/profile_login_otp_view_contract.dart';
import 'package:golf_kakis/features/profile/login/otp/viewmodel/profile_login_otp_view_model.dart';

class ProfileLoginOtpPage extends StatefulWidget {
  const ProfileLoginOtpPage({
    required this.name,
    required this.phoneNumber,
    required this.requestMessage,
    required this.visitorId,
    super.key,
  });

  final String name;
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
      name: widget.name,
      phoneNumber: widget.phoneNumber,
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
      if (effect is LoginOtpNavigateBack) {
        if (!mounted) {
          return;
        }
        Navigator.of(context).maybePop();
      }

      if (effect is LoginOtpVerified) {
        if (!mounted) {
          return;
        }
        Navigator.of(context).pop(
          LoginOtpSuccessResult(
            response: effect.response,
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
            title: const Text('Verify OTP'),
            leading: IconButton(
              onPressed: () =>
                  _viewModel.onUserIntent(const OnLoginOtpBackClick()),
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          body: ProfileLoginOtpView(
            state: _viewModel.viewState,
            onOtpChanged: (index, value) => _viewModel.onUserIntent(
              OnLoginOtpDigitChanged(index: index, value: value),
            ),
            onVerifyClick: () => _viewModel.onUserIntent(
              OnLoginOtpVerifyClick(
                visitorId: SessionScope.of(context).deviceId,
              ),
            ),
          ),
        );
      },
    );
  }
}

class LoginOtpSuccessResult {
  const LoginOtpSuccessResult({required this.response});

  final VerifyOtpResponse response;
}
