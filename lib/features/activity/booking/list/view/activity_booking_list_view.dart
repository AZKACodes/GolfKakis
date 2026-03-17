import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_model.dart';

import '../viewmodel/activity_booking_list_view_contract.dart';

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
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Bookings',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'View all your upcoming and past bookings in one place.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 14),
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
              _BookingTabBody(
                bookings: state.upcomingBookings,
                emptyLabel: 'No upcoming bookings yet.',
                isLoading: state.isUpcomingLoading,
                hasLoaded: state.hasLoadedUpcoming,
                isUsingFallback: state.isUsingUpcomingFallback,
                errorMessage: state.upcomingErrorMessage,
                tab: ActivityBookingListTab.upcoming,
                onRetryClick: onRetryClick,
                onRefresh: onRefresh,
                onViewBookingDetailClick: onViewBookingDetailClick,
              ),
              _BookingTabBody(
                bookings: state.pastBookings,
                emptyLabel: 'No past bookings yet.',
                isLoading: state.isPastLoading,
                hasLoaded: state.hasLoadedPast,
                isUsingFallback: state.isUsingPastFallback,
                errorMessage: state.pastErrorMessage,
                tab: ActivityBookingListTab.past,
                onRetryClick: onRetryClick,
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

class _BookingTabBody extends StatelessWidget {
  const _BookingTabBody({
    required this.bookings,
    required this.emptyLabel,
    required this.isLoading,
    required this.hasLoaded,
    required this.isUsingFallback,
    required this.errorMessage,
    required this.tab,
    required this.onRetryClick,
    required this.onRefresh,
    required this.onViewBookingDetailClick,
  });

  final List<BookingModel> bookings;
  final String emptyLabel;
  final bool isLoading;
  final bool hasLoaded;
  final bool isUsingFallback;
  final String? errorMessage;
  final ActivityBookingListTab tab;
  final ValueChanged<ActivityBookingListTab> onRetryClick;
  final Future<void> Function(ActivityBookingListTab tab) onRefresh;
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
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate.fixed([
                if (isUsingFallback) ...[
                  const _InfoBanner(
                    message:
                        'Showing fallback bookings until this endpoint is ready.',
                  ),
                  const SizedBox(height: 12),
                ],
                if (errorMessage != null) ...[
                  _ErrorBanner(
                    message: errorMessage!,
                    onRetryClick: () => onRetryClick(tab),
                  ),
                  const SizedBox(height: 12),
                ],
              ]),
            ),
          ),
          if (bookings.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  emptyLabel,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList.separated(
                itemCount: bookings.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, index) => _BookingCard(
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

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF3D6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9C46A)),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: const Color(0xFF7A5B00),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onRetryClick});

  final String message;
  final VoidCallback onRetryClick;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDECEC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE7A1A1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF8A3D3D),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          TextButton(onPressed: onRetryClick, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.item,
    required this.onViewBookingDetailClick,
  });

  final BookingModel item;
  final ValueChanged<BookingModel> onViewBookingDetailClick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.courseName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _StatusChip(
                label: item.statusLabel,
                backgroundColor: item.statusColor,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(
                icon: Icons.calendar_today_outlined,
                text: item.dateLabel,
              ),
              _MetaChip(icon: Icons.schedule_outlined, text: item.timeLabel),
              _MetaChip(icon: Icons.groups_outlined, text: item.playersLabel),
              _MetaChip(
                icon: Icons.account_balance_wallet_outlined,
                text: item.feeLabel,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => onViewBookingDetailClick(item),
              icon: const Icon(Icons.visibility_outlined),
              label: const Text('View Details'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.backgroundColor});

  final String label;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.black54),
          const SizedBox(width: 6),
          Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
