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
    _navEffectSubscription = _viewModel.navEffects.listen(_handleNavEffect);
  }

  @override
  void dispose() {
    _navEffectSubscription?.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  void _handleNavEffect(ProfileEditNavEffect effect) {
    if (!mounted) {
      return;
    }

    switch (effect) {
      case ProfileEditNavigateBack():
        Navigator.of(context).maybePop();
      case ProfileEditSaved():
        final loadedState = switch (_viewModel.viewState) {
          ProfileEditDataLoaded() =>
            _viewModel.viewState as ProfileEditDataLoaded,
        };
        SessionScope.of(context).updateProfile(
          fullName: loadedState.fullName.trim(),
          nickname: loadedState.nickname.trim(),
          occupation: loadedState.occupation.trim(),
          email: loadedState.email.trim(),
          phoneNumber: loadedState.phoneNumber.trim(),
          avatarIndex: loadedState.avatarIndex,
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
              onUserIntent: _viewModel.onUserIntent,
            ),
          ),
        );
      },
    );
  }
}
