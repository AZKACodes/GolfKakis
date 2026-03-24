import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golf_kakis/features/activity/booking/detail/activity_booking_detail_page.dart';
import 'package:golf_kakis/features/activity/booking/list/data/activity_booking_list_repository_impl.dart';

import 'view/activity_booking_list_view.dart';
import 'viewmodel/activity_booking_list_view_contract.dart';
import 'viewmodel/activity_booking_list_view_model.dart';

class ActivityBookingListPage extends StatefulWidget {
  const ActivityBookingListPage({super.key});

  @override
  State<ActivityBookingListPage> createState() =>
      _ActivityBookingListPageState();
}

class _ActivityBookingListPageState extends State<ActivityBookingListPage> with SingleTickerProviderStateMixin {
  late final ActivityBookingListViewModel _viewModel;
  late final TabController _tabController;
  
  StreamSubscription<ActivityBookingListNavEffect>? _navEffectSubscription;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();

    _viewModel = ActivityBookingListViewModel(repository: ActivityBookingListRepositoryImpl());
    _tabController = TabController(length: 2, vsync: this)..addListener(_handleTabChanged);

    _navEffectSubscription = _viewModel.navEffects.listen((effect) {
      if (effect is NavigateToBookingDetails) {
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
    
    _viewModel.onUserIntent(const OnInit());
  }

  void _handleTabChanged() {
    if (_tabController.index == _currentTabIndex) {
      return;
    }

    _currentTabIndex = _tabController.index;

    _viewModel.onUserIntent(
      OnTabChanged(
        _currentTabIndex == 0
            ? ActivityBookingListTab.upcoming
            : ActivityBookingListTab.past,
      ),
    );
  }

  @override
  void dispose() {
    _navEffectSubscription?.cancel();
    _tabController
      ..removeListener(_handleTabChanged)
      ..dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) => ActivityBookingListView(
            controller: _tabController,
            state: _viewModel.viewState,
            onRetryClick: (tab) => _viewModel.onUserIntent(OnRetryClick(tab)),
            onRefresh: _viewModel.onRefresh,
            onViewBookingDetailClick: (booking) =>
                _viewModel.onUserIntent(OnViewBookingDetailClick(booking)),
          ),
        ),
      ),
    );
  }
}
