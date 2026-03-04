import 'package:flutter/material.dart';

import 'view/activity_booking_list_view.dart';
import 'viewmodel/activity_booking_list_view_model.dart';

class ActivityBookingListPage extends StatefulWidget {
  const ActivityBookingListPage({super.key});

  @override
  State<ActivityBookingListPage> createState() =>
      _ActivityBookingListPageState();
}

class _ActivityBookingListPageState extends State<ActivityBookingListPage> {
  late final ActivityBookingListViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ActivityBookingListViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: const SafeArea(
        child: ActivityBookingListView(),
      ),
    );
  }
}
