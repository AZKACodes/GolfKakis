import 'package:flutter/material.dart';

class ActivityOverviewDashboardView extends StatelessWidget {
  const ActivityOverviewDashboardView({
    required this.onBookingListClick,
    required this.onUpcomingBookingDetailClick,
    required this.onRecentRoundOneDetailClick,
    required this.onRecentRoundTwoDetailClick,
    super.key,
  });

  final VoidCallback onBookingListClick;
  final VoidCallback onUpcomingBookingDetailClick;
  final VoidCallback onRecentRoundOneDetailClick;
  final VoidCallback onRecentRoundTwoDetailClick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity Center',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Track upcoming rounds and recent booking activity.',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 20),
          _BookingListTouchpoint(onTap: onBookingListClick),
          const SizedBox(height: 24),
          const _SectionTitle(title: 'Upcoming'),
          const SizedBox(height: 10),
          _UpcomingCard(
            course: 'Kinrara Golf Club',
            dateLabel: 'Fri, Mar 6',
            timeLabel: '07:30 AM',
            playersLabel: '2 Players',
            countdownLabel: 'Starts in 1d 9h',
            weatherLabel: '28 C, light wind',
            checkInStatus: 'Check-in opens in 3h',
            onOpenDetails: onUpcomingBookingDetailClick,
          ),
          const SizedBox(height: 24),
          const _SectionTitle(title: 'Recent Rounds'),
          const SizedBox(height: 10),
          _RoundCard(
            course: 'Saujana G&CC',
            dateLabel: 'Tue, Feb 25',
            scoreLabel: '75 (+3)',
            durationLabel: '4h 12m',
            fairwaysLabel: '71%',
            girLabel: '61%',
            puttsLabel: '31',
            onOpenDetails: onRecentRoundOneDetailClick,
          ),
          const SizedBox(height: 10),
          _RoundCard(
            course: 'Kota Permai',
            dateLabel: 'Sat, Mar 1',
            scoreLabel: '72 (E)',
            durationLabel: '3h 58m',
            fairwaysLabel: '78%',
            girLabel: '67%',
            puttsLabel: '29',
            onOpenDetails: onRecentRoundTwoDetailClick,
          ),
        ],
      ),
    );
  }
}

class _BookingListTouchpoint extends StatelessWidget {
  const _BookingListTouchpoint({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Row(
        children: [
          const Icon(Icons.list_alt_outlined, color: Color(0xFF0A1F1A)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Booking Overview',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'View all upcoming and past bookings',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: onTap,
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}

class _UpcomingCard extends StatelessWidget {
  const _UpcomingCard({
    required this.course,
    required this.dateLabel,
    required this.timeLabel,
    required this.playersLabel,
    required this.countdownLabel,
    required this.weatherLabel,
    required this.checkInStatus,
    required this.onOpenDetails,
  });

  final String course;
  final String dateLabel;
  final String timeLabel;
  final String playersLabel;
  final String countdownLabel;
  final String weatherLabel;
  final String checkInStatus;
  final VoidCallback onOpenDetails;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.event_available_outlined,
                color: Color(0xFF0A1F1A),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  course,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _Tag(text: countdownLabel, color: const Color(0xFF1E5B4A)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Tag(text: dateLabel, color: const Color(0xFF215E4D)),
              _Tag(text: timeLabel, color: const Color(0xFF215E4D)),
              _Tag(text: playersLabel, color: const Color(0xFF215E4D)),
              _Tag(text: weatherLabel, color: const Color(0xFF3B6D91)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  checkInStatus,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              OutlinedButton(onPressed: onOpenDetails, child: const Text('Modify')),
              const SizedBox(width: 8),
              FilledButton(onPressed: onOpenDetails, child: const Text('Details')),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoundCard extends StatelessWidget {
  const _RoundCard({
    required this.course,
    required this.dateLabel,
    required this.scoreLabel,
    required this.durationLabel,
    required this.fairwaysLabel,
    required this.girLabel,
    required this.puttsLabel,
    required this.onOpenDetails,
  });

  final String course;
  final String dateLabel;
  final String scoreLabel;
  final String durationLabel;
  final String fairwaysLabel;
  final String girLabel;
  final String puttsLabel;
  final VoidCallback onOpenDetails;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  course,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                dateLabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.black54,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _MetricTile(label: 'Score', value: scoreLabel),
              const SizedBox(width: 8),
              _MetricTile(label: 'Duration', value: durationLabel),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Tag(
                text: 'Fairways $fairwaysLabel',
                color: const Color(0xFF2A6654),
              ),
              _Tag(text: 'GIR $girLabel', color: const Color(0xFF2A6654)),
              _Tag(text: 'Putts $puttsLabel', color: const Color(0xFF2A6654)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              TextButton(onPressed: onOpenDetails, child: const Text('View Details')),
              const SizedBox(width: 6),
              TextButton(onPressed: onOpenDetails, child: const Text('Book Again')),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFFF1F6F4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x11000000)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}
