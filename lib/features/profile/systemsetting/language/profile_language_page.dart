import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golf_kakis/app/app_language_scope.dart';

import 'view/profile_language_view.dart';
import 'viewmodel/profile_language_view_contract.dart';
import 'viewmodel/profile_language_view_model.dart';

class ProfileLanguagePage extends StatefulWidget {
  const ProfileLanguagePage({super.key});

  @override
  State<ProfileLanguagePage> createState() => _ProfileLanguagePageState();
}

class _ProfileLanguagePageState extends State<ProfileLanguagePage> {
  ProfileLanguageViewModel? _viewModel;
  StreamSubscription<ProfileLanguageNavEffect>? _navEffectSubscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_viewModel != null) {
      return;
    }

    final languageController = AppLanguageScope.of(context);
    final viewModel = ProfileLanguageViewModel(
      languageController: languageController,
    );
    _navEffectSubscription = viewModel.navEffects.listen(_handleNavEffect);
    _viewModel = viewModel;
  }

  @override
  void dispose() {
    _navEffectSubscription?.cancel();
    _viewModel?.dispose();
    super.dispose();
  }

  void _handleNavEffect(ProfileLanguageNavEffect effect) {
    if (!mounted) {
      return;
    }

    switch (effect) {
      case ProfileLanguageNavigateBack():
        Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = _viewModel;
    if (viewModel == null) {
      return const SizedBox.shrink();
    }

    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Language'),
            leading: IconButton(
              onPressed: () => viewModel.onUserIntent(
                const OnProfileLanguageBackClick(),
              ),
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          body: SafeArea(
            child: ProfileLanguageView(
              state: viewModel.viewState,
              onUserIntent: viewModel.onUserIntent,
            ),
          ),
        );
      },
    );
  }
}
