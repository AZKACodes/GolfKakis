import 'dart:async';

import 'package:flutter/material.dart';

import 'view/profile_notification_view.dart';
import 'viewmodel/profile_notification_view_contract.dart';
import 'viewmodel/profile_notification_view_model.dart';

class ProfileNotificationPage extends StatefulWidget {
  const ProfileNotificationPage({super.key});

  @override
  State<ProfileNotificationPage> createState() => _ProfileNotificationPageState();
}

class _ProfileNotificationPageState extends State<ProfileNotificationPage> {
  late final ProfileNotificationViewModel _viewModel;
  StreamSubscription<ProfileNotificationNavEffect>? _navEffectSubscription;

  @override
  void initState() {
    super.initState();
    _viewModel = ProfileNotificationViewModel();
    _navEffectSubscription = _viewModel.navEffects.listen(_handleNavEffect);
    _viewModel.onUserIntent(const OnProfileNotificationInit());
  }

  @override
  void dispose() {
    _navEffectSubscription?.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  void _handleNavEffect(ProfileNotificationNavEffect effect) {
    if (!mounted) {
      return;
    }

    switch (effect) {
      case ProfileNotificationNavigateBack():
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
            title: const Text('Notification'),
            leading: IconButton(
              onPressed: () => _viewModel.onUserIntent(
                const OnProfileNotificationBackClick(),
              ),
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          body: SafeArea(
            child: ProfileNotificationView(
              state: _viewModel.viewState,
              onUserIntent: _viewModel.onUserIntent,
            ),
          ),
        );
      },
    );
  }
}
