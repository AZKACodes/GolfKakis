import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/model/user_profile_model.dart';
import 'package:golf_kakis/features/foundation/session/session_scope.dart';
import 'package:golf_kakis/features/foundation/session/session_state.dart';
import 'package:golf_kakis/features/profile/account/profile_detail/domain/profile_detail_use_case_impl.dart';
import 'package:golf_kakis/features/profile/account/profile_detail/view/profile_detail_view.dart';
import 'package:golf_kakis/features/profile/account/profile_detail/viewmodel/profile_detail_view_contract.dart';
import 'package:golf_kakis/features/profile/account/profile_detail/viewmodel/profile_detail_view_model.dart';

class ProfileDetailPage extends StatefulWidget {
  const ProfileDetailPage({required this.profile, super.key});

  final UserProfileModel profile;

  @override
  State<ProfileDetailPage> createState() => _ProfileDetailPageState();
}

class _ProfileDetailPageState extends State<ProfileDetailPage> {
  late final ProfileDetailViewModel _viewModel;
  SessionState? _lastSessionState;
  StreamSubscription<ProfileDetailNavEffect>? _navEffectSubscription;

  @override
  void initState() {
    super.initState();
    _viewModel = ProfileDetailViewModel(
      profile: widget.profile,
      useCase: const ProfileDetailUseCaseImpl(),
    );
    _navEffectSubscription = _viewModel.navEffects.listen(_handleNavEffect);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final sessionState = SessionScope.of(context).state;
    if (_lastSessionState != sessionState) {
      _lastSessionState = sessionState;
      _viewModel.onUserIntent(OnInitProfileDetails(sessionState));
    }
  }

  @override
  void dispose() {
    _navEffectSubscription?.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  void _handleNavEffect(ProfileDetailNavEffect effect) {
    if (!mounted) {
      return;
    }

    switch (effect) {
      case ProfileDetailNavigateBack():
        Navigator.of(context).maybePop();
      case ProfileDetailSaved():
        final loadedState = switch (_viewModel.viewState) {
          ProfileDetailDataLoaded() =>
            _viewModel.viewState as ProfileDetailDataLoaded,
        };
        SessionScope.of(context).updateProfile(
          fullName: loadedState.realName.trim(),
          nickname: loadedState.username.trim(),
          occupation: loadedState.gender.trim(),
          email: loadedState.email.trim(),
          phoneNumber: loadedState.phoneNumber.trim(),
          avatarIndex: loadedState.avatarIndex,
          avatarImagePath: loadedState.avatarImagePath,
        );
      case ProfileDetailDeactivated():
        unawaited(SessionScope.of(context).logout());
        Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile Details'),
            leading: IconButton(
              onPressed: () =>
                  _viewModel.onUserIntent(const OnProfileDetailBackClick()),
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          body: SafeArea(
            child: ProfileDetailView(
              state: _viewModel.viewState,
              onUserIntent: _viewModel.onUserIntent,
            ),
          ),
        );
      },
    );
  }
}
