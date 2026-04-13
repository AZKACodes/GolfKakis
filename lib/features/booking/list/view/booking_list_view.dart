import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_model.dart';

import '../viewmodel/booking_list_view_contract.dart';
import 'booking_list_content.dart';

class BookingListView extends StatelessWidget {
  const BookingListView({
    required this.controller,
    required this.state,
    required this.onRefresh,
    required this.onViewBookingDetailClick,
    super.key,
  });

  final TabController controller;
  final BookingListViewState state;
  final Future<void> Function(BookingListTab tab) onRefresh;
  final ValueChanged<BookingModel> onViewBookingDetailClick;

  @override
  Widget build(BuildContext context) {
    return BookingListContent(
      controller: controller,
      state: state,
      onRefresh: onRefresh,
      onViewBookingDetailClick: onViewBookingDetailClick,
    );
  }
}
