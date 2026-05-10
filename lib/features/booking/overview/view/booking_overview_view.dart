import 'package:flutter/material.dart';
import 'package:golf_kakis/features/booking/overview/view/widgets/booking_details_item.dart';
import 'package:golf_kakis/features/booking/overview/viewmodel/booking_overview_view_contract.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_model.dart';

class BookingOverviewView extends StatelessWidget {
  const BookingOverviewView({
    required this.controller,
    required this.state,
    required this.onRefresh,
    required this.onStartBookingPressed,
    required this.onViewBookingDetailClick,
    super.key,
  });

  final TabController controller;
  final BookingOverviewViewState state;
  final Future<void> Function(BookingOverviewTab tab) onRefresh;
  final VoidCallback onStartBookingPressed;
  final ValueChanged<BookingModel> onViewBookingDetailClick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onStartBookingPressed,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Start A New Booking'),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Container(
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
        ),
        Expanded(
          child: TabBarView(
            controller: controller,
            children: [
              _BookingOverviewTabContent(
                bookings: state.upcomingBookings,
                emptyLabel: 'No Upcoming Bookings Yet',
                isLoading: state.isUpcomingLoading,
                hasLoaded: state.hasLoadedUpcoming,
                tab: BookingOverviewTab.upcoming,
                onRefresh: onRefresh,
                onViewBookingDetailClick: onViewBookingDetailClick,
              ),
              _BookingOverviewTabContent(
                bookings: state.pastBookings,
                emptyLabel: 'No Past Bookings Available',
                isLoading: state.isPastLoading,
                hasLoaded: state.hasLoadedPast,
                tab: BookingOverviewTab.past,
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

class _BookingOverviewTabContent extends StatelessWidget {
  const _BookingOverviewTabContent({
    required this.bookings,
    required this.emptyLabel,
    required this.isLoading,
    required this.hasLoaded,
    required this.tab,
    required this.onRefresh,
    required this.onViewBookingDetailClick,
  });

  final List<BookingModel> bookings;
  final String emptyLabel;
  final bool isLoading;
  final bool hasLoaded;
  final BookingOverviewTab tab;
  final Future<void> Function(BookingOverviewTab tab) onRefresh;
  final ValueChanged<BookingModel> onViewBookingDetailClick;

  @override
  Widget build(BuildContext context) {
    if (isLoading && !hasLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => onRefresh(tab),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (bookings.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    emptyLabel,
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList.separated(
                itemCount: bookings.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, index) => BookingDetailsItem(
                  item: bookings[index],
                  onViewBookingDetailClick: onViewBookingDetailClick,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
