import 'dart:async';

import 'package:flutter/material.dart';
import 'package:xxx_demo_app/features/activity/booking/list/activity_booking_list_page.dart';

import 'view/activity_overview_view.dart';
import 'viewmodel/activity_overview_view_contract.dart';
import 'viewmodel/activity_overview_view_model.dart';

class ActivityOverviewPage extends StatefulWidget {
  const ActivityOverviewPage({super.key});

  @override
  State<ActivityOverviewPage> createState() => _ActivityOverviewPageState();
}

class _ActivityOverviewPageState extends State<ActivityOverviewPage> {
  late final ActivityOverviewViewModel _viewModel;
  StreamSubscription<ActivityOverviewNavEffect>? _navEffectSubscription;

  @override
  void initState() {
    super.initState();
    _viewModel = ActivityOverviewViewModel();
    _navEffectSubscription = _viewModel.navEffects.listen((effect) {
      if (effect is NavigateToActivityBookingList) {
        if (!mounted) {
          return;
        }
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute<void>(
            builder: (_) => const ActivityBookingListPage(),
          ),
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
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ActivityOverviewDashboardView(
        onBookingListClick: () =>
            _viewModel.onUserIntent(const OnBookingListClick()),
      ),
    );
  }
}
