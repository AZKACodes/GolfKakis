import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_model.dart';

import '../viewmodel/activity_booking_list_view_contract.dart';
import 'activity_booking_list_content.dart';

class ActivityBookingListView extends StatelessWidget {
  const ActivityBookingListView({
    required this.controller,
    required this.state,
    required this.onRetryClick,
    required this.onRefresh,
    required this.onViewBookingDetailClick,
    super.key,
  });

  final TabController controller;
  final ActivityBookingListViewState state;
  final ValueChanged<ActivityBookingListTab> onRetryClick;
  final Future<void> Function(ActivityBookingListTab tab) onRefresh;
  final ValueChanged<BookingModel> onViewBookingDetailClick;

  @override
  Widget build(BuildContext context) {
    return ActivityBookingListContent(
      controller: controller,
      state: state,
      onRetryClick: onRetryClick,
      onRefresh: onRefresh,
      onViewBookingDetailClick: onViewBookingDetailClick,
    );
  }
}
