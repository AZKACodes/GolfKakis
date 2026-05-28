import 'dart:async';

import 'package:flutter/material.dart';

import 'domain/stay_play_use_case_impl.dart';
import 'view/stay_play_view.dart';
import 'viewmodel/stay_play_view_contract.dart';
import 'viewmodel/stay_play_view_model.dart';

class StayPlayPage extends StatefulWidget {
  const StayPlayPage({super.key});

  @override
  State<StayPlayPage> createState() => _StayPlayPageState();
}

class _StayPlayPageState extends State<StayPlayPage> {
  late final StayPlayViewModel _viewModel;
  StreamSubscription<StayPlayNavEffect>? _navEffectSubscription;

  @override
  void initState() {
    super.initState();

    _viewModel = StayPlayViewModel(useCase: StayPlayUseCaseImpl.create());
    _navEffectSubscription = _viewModel.navEffects.listen(_handleNavEffect);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _viewModel.onUserIntent(const OnInitStayPlay());
    });
  }

  @override
  void dispose() {
    _navEffectSubscription?.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  void _handleNavEffect(StayPlayNavEffect effect) {}

  Future<void> _handleRefresh() async {
    await _viewModel.handleIntent(const OnRefreshStayPlay());
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFCDEEFF),
          body: RefreshIndicator(
            onRefresh: _handleRefresh,
            child: StayPlayView(
              state: _viewModel.viewState,
              onUserIntent: _viewModel.onUserIntent,
            ),
          ),
        );
      },
    );
  }
}
