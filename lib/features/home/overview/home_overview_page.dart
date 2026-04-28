import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golf_kakis/features/booking/list/booking_list_page.dart';
import 'package:golf_kakis/features/booking/submission/slot/booking_submission_slot_page.dart';
import 'package:golf_kakis/features/home/golf_club_list/home_golf_club_list_page.dart';

import 'view/home_overview_view.dart';
import 'viewmodel/home_view_contract.dart';
import 'viewmodel/home_view_model.dart';

class HomeOverviewPage extends StatefulWidget {
  const HomeOverviewPage({super.key});

  @override
  State<HomeOverviewPage> createState() => _HomeOverviewPageState();
}

class _HomeOverviewPageState extends State<HomeOverviewPage> {
  late final HomeViewModel _viewModel;
  StreamSubscription<HomeNavEffect>? _navEffectSubscription;

  @override
  void initState() {
    super.initState();

    _viewModel = HomeViewModel.create();
    _navEffectSubscription = _viewModel.navEffects.listen(_handleNavEffect);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _viewModel.onUserIntent(const OnInitHome());
    });
  }

  @override
  void dispose() {
    _navEffectSubscription?.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  void _handleNavEffect(HomeNavEffect effect) {
    if (!mounted) {
      return;
    }

    switch (effect) {
      case NavigateToBookingSlotSubmission():
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute<void>(
            builder: (_) => const BookingSubmissionSlotPage(),
          ),
        );
      case NavigateToGolfClubList():
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute<void>(builder: (_) => const HomeGolfClubListPage()),
        );
      case NavigateToBookingOverview():
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute<void>(builder: (_) => const BookingListPage()),
        );
      case NavigateToQuickBook():
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute<void>(
            builder: (_) =>
                BookingSubmissionSlotPage(initialClubSlug: effect.clubSlug),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return HomeView(
          state: _viewModel.viewState,
          onUserIntent: _viewModel.onUserIntent,
        );
      },
    );
  }
}
