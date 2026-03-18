import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/enums/session/user_role.dart';
import 'package:golf_kakis/features/foundation/session/session_scope.dart';
import 'package:golf_kakis/features/profile/register/details/view/profile_register_details_view.dart';
import 'package:golf_kakis/features/profile/register/details/viewmodel/profile_register_details_view_contract.dart';
import 'package:golf_kakis/features/profile/register/details/viewmodel/profile_register_details_view_model.dart';

class ProfileRegisterDetailsPage extends StatefulWidget {
  const ProfileRegisterDetailsPage({required this.phoneNumber, super.key});

  final String phoneNumber;

  @override
  State<ProfileRegisterDetailsPage> createState() =>
      _ProfileRegisterDetailsPageState();
}

class _ProfileRegisterDetailsPageState
    extends State<ProfileRegisterDetailsPage> {
  late final ProfileRegisterDetailsViewModel _viewModel;
  StreamSubscription<ProfileRegisterDetailsNavEffect>? _navEffectSubscription;

  @override
  void initState() {
    super.initState();
    _viewModel = ProfileRegisterDetailsViewModel(
      phoneNumber: widget.phoneNumber,
    );
    _navEffectSubscription = _viewModel.navEffects.listen((effect) {
      if (effect is RegisterDetailsNavigateBack) {
        if (!mounted) {
          return;
        }
        Navigator.of(context).maybePop();
      }

      if (effect is RegisterDetailsCompleted) {
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
        Navigator.of(
          context,
          rootNavigator: true,
        ).popUntil((route) => route.isFirst);
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
            title: const Text('About You'),
            leading: IconButton(
              onPressed: () =>
                  _viewModel.onUserIntent(const OnRegisterDetailsBackClick()),
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          body: ProfileRegisterDetailsView(
            state: _viewModel.viewState,
            onNameChanged: (value) =>
                _viewModel.onUserIntent(OnRegisterNameChanged(value)),
            onNicknameChanged: (value) =>
                _viewModel.onUserIntent(OnRegisterNicknameChanged(value)),
            onOccupationChanged: (value) =>
                _viewModel.onUserIntent(OnRegisterOccupationChanged(value)),
            onSubmitClick: () =>
                _viewModel.onUserIntent(const OnRegisterDetailsSubmitClick()),
          ),
        );
      },
    );
  }
}
