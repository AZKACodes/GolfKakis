import 'package:flutter/material.dart';

class ActivityBookingListView extends StatelessWidget {
  const ActivityBookingListView({super.key});

  static const List<_BookingItem> _upcomingBookings = [
    _BookingItem(
      courseName: 'Kinrara Golf Club',
      dateLabel: 'Fri, Mar 6',
      timeLabel: '07:30 AM',
      playersLabel: '2 Players',
      feeLabel: 'MYR 39',
      statusLabel: 'Confirmed',
      highlightColor: Color(0xFF1E7D66),
    ),
    _BookingItem(
      courseName: 'Saujana Golf & Country Club',
      dateLabel: 'Sun, Mar 8',
      timeLabel: '08:10 AM',
      playersLabel: '4 Players',
      feeLabel: 'MYR 52',
      statusLabel: 'Pending Payment',
      highlightColor: Color(0xFF9A6A00),
    ),
    _BookingItem(
      courseName: 'Mines Resort & Golf Club',
      dateLabel: 'Wed, Mar 11',
      timeLabel: '07:50 AM',
      playersLabel: '3 Players',
      feeLabel: 'MYR 47',
      statusLabel: 'Confirmed',
      highlightColor: Color(0xFF1E7D66),
    ),
  ];

  static const List<_BookingItem> _pastBookings = [
    _BookingItem(
      courseName: 'Kota Permai Golf & Country Club',
      dateLabel: 'Sat, Mar 1',
      timeLabel: '07:20 AM',
      playersLabel: '4 Players',
      feeLabel: 'MYR 50',
      statusLabel: 'Completed',
      highlightColor: Color(0xFF345C8A),
    ),
    _BookingItem(
      courseName: 'Tropicana Golf & Country Resort',
      dateLabel: 'Tue, Feb 25',
      timeLabel: '08:00 AM',
      playersLabel: '3 Players',
      feeLabel: 'MYR 44',
      statusLabel: 'Completed',
      highlightColor: Color(0xFF345C8A),
    ),
    _BookingItem(
      courseName: 'Seri Selangor Golf Club',
      dateLabel: 'Fri, Feb 21',
      timeLabel: '07:40 AM',
      playersLabel: '2 Players',
      feeLabel: 'MYR 34',
      statusLabel: 'Cancelled',
      highlightColor: Color(0xFF8A3D3D),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Column(
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
          const Expanded(
            child: TabBarView(
              children: [
                _BookingList(bookings: _upcomingBookings),
                _BookingList(bookings: _pastBookings),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  const _BookingList({required this.bookings});

  final List<_BookingItem> bookings;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: bookings.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, index) => _BookingCard(item: bookings[index]),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.item});

  final _BookingItem item;

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
                backgroundColor: item.highlightColor,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(icon: Icons.calendar_today_outlined, text: item.dateLabel),
              _MetaChip(icon: Icons.schedule_outlined, text: item.timeLabel),
              _MetaChip(icon: Icons.groups_outlined, text: item.playersLabel),
              _MetaChip(
                icon: Icons.account_balance_wallet_outlined,
                text: item.feeLabel,
              ),
            ],
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
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingItem {
  const _BookingItem({
    required this.courseName,
    required this.dateLabel,
    required this.timeLabel,
    required this.playersLabel,
    required this.feeLabel,
    required this.statusLabel,
    required this.highlightColor,
  });

  final String courseName;
  final String dateLabel;
  final String timeLabel;
  final String playersLabel;
  final String feeLabel;
  final String statusLabel;
  final Color highlightColor;
}
