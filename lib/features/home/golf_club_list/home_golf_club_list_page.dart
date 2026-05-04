import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golf_kakis/features/booking/club/detail/golf_club_detail_page.dart';
import 'package:golf_kakis/features/home/golf_club_list/domain/home_golf_club_list_use_case_impl.dart';

import 'view/home_golf_club_list_view.dart';
import 'viewmodel/home_golf_club_list_view_contract.dart';
import 'viewmodel/home_golf_club_list_view_model.dart';

class HomeGolfClubListPage extends StatefulWidget {
  const HomeGolfClubListPage({super.key});

  @override
  State<HomeGolfClubListPage> createState() => _HomeGolfClubListPageState();
}

class _HomeGolfClubListPageState extends State<HomeGolfClubListPage> {
  late final HomeGolfClubListViewModel _viewModel;
  StreamSubscription<HomeGolfClubListNavEffect>? _navEffectSubscription;

  @override
  void initState() {
    super.initState();

    _viewModel = HomeGolfClubListViewModel(
      useCase: HomeGolfClubListUseCaseImpl.create(),
    );
    _navEffectSubscription = _viewModel.navEffects.listen(_handleNavEffect);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _viewModel.onUserIntent(const OnInitHomeGolfClubList());
    });
  }

  @override
  void dispose() {
    _navEffectSubscription?.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  void _handleNavEffect(HomeGolfClubListNavEffect effect) {
    if (!mounted) {
      return;
    }

    switch (effect) {
      case NavigateToHomeGolfClubDetail():
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => GolfClubDetailPage(
              clubSlug: effect.club.slug,
              initialClub: effect.club,
            ),
          ),
        );
    }
  }

  Future<void> _handleRefresh() async {
    _viewModel.onUserIntent(const OnRefreshHomeGolfClubList());
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Golf Club List')),
          body: RefreshIndicator(
            onRefresh: _handleRefresh,
            child: HomeGolfClubListView(
              state: _viewModel.viewState,
              onUserIntent: _viewModel.onUserIntent,
            ),
          ),
        );
      },
    );
  }
}
