import 'dart:async';

import 'package:flutter/material.dart';

import 'domain/deals_use_case_impl.dart';
import 'view/deals_view.dart';
import 'viewmodel/deals_view_contract.dart';
import 'viewmodel/deals_view_model.dart';

class DealsPage extends StatefulWidget {
  const DealsPage({super.key});

  @override
  State<DealsPage> createState() => _DealsPageState();
}

class _DealsPageState extends State<DealsPage> {
  late final DealsViewModel _viewModel;
  StreamSubscription<DealsNavEffect>? _navEffectSubscription;

  @override
  void initState() {
    super.initState();

    _viewModel = DealsViewModel(useCase: DealsUseCaseImpl.create());
    _navEffectSubscription = _viewModel.navEffects.listen(_handleNavEffect);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _viewModel.onUserIntent(const OnInitDeals());
    });
  }

  @override
  void dispose() {
    _navEffectSubscription?.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  void _handleNavEffect(DealsNavEffect effect) {}

  Future<void> _handleRefresh() async {
    await _viewModel.handleIntent(const OnRefreshDeals());
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
            child: DealsView(
              state: _viewModel.viewState,
              onUserIntent: _viewModel.onUserIntent,
            ),
          ),
        );
      },
    );
  }
}
