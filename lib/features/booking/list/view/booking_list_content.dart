import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_model.dart';

import 'widgets/booking_tab_content.dart';
import '../viewmodel/booking_list_view_contract.dart';

class BookingListContent extends StatelessWidget {
  const BookingListContent({
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
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: TabBar(
                    controller: controller,
                    dividerColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    labelStyle: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    unselectedLabelStyle: theme.textTheme.labelLarge,
                    labelColor: Colors.black87,
                    unselectedLabelColor: Colors.black54,
                    splashBorderRadius: BorderRadius.circular(8),
                    tabs: const [
                      Tab(text: 'Upcoming'),

                      Tab(text: 'Past'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: TabBarView(
            controller: controller,
            children: [
              BookingTabContent(
                bookings: state.upcomingBookings,
                emptyLabel: 'No Upcoming Bookings Yet',
                isLoading: state.isUpcomingLoading,
                hasLoaded: state.hasLoadedUpcoming,
                tab: BookingListTab.upcoming,
                onRefresh: onRefresh,
                onViewBookingDetailClick: onViewBookingDetailClick,
              ),

              BookingTabContent(
                bookings: state.pastBookings,
                emptyLabel: 'No Past Bookings Available',
                isLoading: state.isPastLoading,
                hasLoaded: state.hasLoadedPast,
                tab: BookingListTab.past,
                onRefresh: onRefresh,
                onViewBookingDetailClick: onViewBookingDetailClick,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
