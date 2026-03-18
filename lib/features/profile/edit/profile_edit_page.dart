import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/model/profile/user_profile_model.dart';
import 'package:golf_kakis/features/foundation/session/session_scope.dart';
import 'package:golf_kakis/features/profile/edit/view/profile_edit_view.dart';
import 'package:golf_kakis/features/profile/edit/viewmodel/profile_edit_view_contract.dart';
import 'package:golf_kakis/features/profile/edit/viewmodel/profile_edit_view_model.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({required this.profile, super.key});

  final UserProfileModel profile;

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  late final ProfileEditViewModel _viewModel;
  StreamSubscription<ProfileEditNavEffect>? _navEffectSubscription;

  @override
  void initState() {
    super.initState();
    _viewModel = ProfileEditViewModel(profile: widget.profile);
    _navEffectSubscription = _viewModel.navEffects.listen((effect) {
      if (effect is ProfileEditNavigateBack) {
        if (!mounted) {
          return;
        }
        Navigator.of(context).maybePop();
      }

      if (effect is ProfileEditSaved) {
        if (!mounted) {
          return;
        }
        SessionScope.of(context).updateProfile(
          fullName: _viewModel.viewState.fullName.trim(),
          nickname: _viewModel.viewState.nickname.trim(),
          occupation: _viewModel.viewState.occupation.trim(),
          email: _viewModel.viewState.email.trim(),
          phoneNumber: _viewModel.viewState.phoneNumber.trim(),
          avatarIndex: _viewModel.viewState.avatarIndex,
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
            title: const Text('Edit Profile'),
            leading: IconButton(
              onPressed: () =>
                  _viewModel.onUserIntent(const OnProfileEditBackClick()),
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          body: SafeArea(
            child: ProfileEditView(
              state: _viewModel.viewState,
              onFullNameChanged: (value) =>
                  _viewModel.onUserIntent(OnProfileEditFullNameChanged(value)),
              onNicknameChanged: (value) =>
                  _viewModel.onUserIntent(OnProfileEditNicknameChanged(value)),
              onOccupationChanged: (value) => _viewModel.onUserIntent(
                OnProfileEditOccupationChanged(value),
              ),
              onEmailChanged: (value) =>
                  _viewModel.onUserIntent(OnProfileEditEmailChanged(value)),
              onPhoneChanged: (value) =>
                  _viewModel.onUserIntent(OnProfileEditPhoneChanged(value)),
              onAvatarChanged: (value) =>
                  _viewModel.onUserIntent(OnProfileEditAvatarChanged(value)),
              onSaveClick: () =>
                  _viewModel.onUserIntent(const OnProfileEditSaveClick()),
            ),
          ),
        );
      },
    );
  }
}
