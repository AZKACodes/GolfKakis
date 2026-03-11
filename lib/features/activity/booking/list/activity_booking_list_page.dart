import 'dart:async';

import 'package:flutter/material.dart';
import 'package:xxx_demo_app/features/activity/booking/detail/activity_booking_detail_page.dart';

import 'view/activity_booking_list_view.dart';
import 'viewmodel/activity_booking_list_view_contract.dart';
import 'viewmodel/activity_booking_list_view_model.dart';

class ActivityBookingListPage extends StatefulWidget {
  const ActivityBookingListPage({super.key});

  @override
  State<ActivityBookingListPage> createState() =>
      _ActivityBookingListPageState();
}

class _ActivityBookingListPageState extends State<ActivityBookingListPage> {
  late final ActivityBookingListViewModel _viewModel;
  StreamSubscription<ActivityBookingListNavEffect>? _navEffectSubscription;

  @override
  void initState() {
    super.initState();
    _viewModel = ActivityBookingListViewModel();
    _navEffectSubscription = _viewModel.navEffects.listen((effect) {
      if (effect is NavigateToActivityBookingDetail) {
        if (!mounted) {
          return;
        }
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ActivityBookingDetailPage(booking: effect.booking),
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
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: SafeArea(
        child: ActivityBookingListView(
          state: _viewModel.viewState,
          onViewBookingDetailClick: (booking) =>
              _viewModel.onUserIntent(OnViewBookingDetailClick(booking)),
        ),
      ),
    );
  }
}
