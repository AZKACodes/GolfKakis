import 'package:flutter/material.dart';

class ActivityOverviewPage extends StatelessWidget {
  const ActivityOverviewPage({super.key});

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
            'Track upcoming rounds, recent results, and booking events.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 20),
          const _SectionTitle(title: 'Upcoming'),
          const SizedBox(height: 10),
          const _UpcomingCard(
            course: 'Kinrara Golf Club',
            dateLabel: 'Fri, Feb 21',
            timeLabel: '07:30 AM',
            playersLabel: '2 Players',
            countdownLabel: 'Starts in 1d 9h',
            weatherLabel: '28 C, light wind',
            checkInStatus: 'Check-in opens in 3h',
          ),
          const SizedBox(height: 24),
          const _SectionTitle(title: 'Recent Rounds'),
          const SizedBox(height: 10),
          const _RoundCard(
            course: 'Saujana G&CC',
            dateLabel: 'Tue, Feb 18',
            scoreLabel: '75 (+3)',
            durationLabel: '4h 12m',
            fairwaysLabel: '71%',
            girLabel: '61%',
            puttsLabel: '31',
          ),
          const SizedBox(height: 10),
          const _RoundCard(
            course: 'Kota Permai',
            dateLabel: 'Sat, Feb 15',
            scoreLabel: '72 (E)',
            durationLabel: '3h 58m',
            fairwaysLabel: '78%',
            girLabel: '67%',
            puttsLabel: '29',
          ),
          const SizedBox(height: 24),
          const _SectionTitle(title: 'Booking Timeline'),
          const SizedBox(height: 10),
          const _TimelineCard(
            events: [
              _TimelineEvent(
                title: 'Booking confirmed',
                detail: 'Kinrara Golf Club - Fri, Feb 21 at 07:30 AM',
                timeAgo: '2h ago',
                type: _EventType.positive,
              ),
              _TimelineEvent(
                title: 'Tee time updated',
                detail: 'Changed from 07:10 AM to 07:30 AM',
                timeAgo: '2h ago',
                type: _EventType.info,
              ),
              _TimelineEvent(
                title: 'Payment received',
                detail: 'Deposit paid - USD 24.00',
                timeAgo: '2h ago',
                type: _EventType.neutral,
              ),
              _TimelineEvent(
                title: 'Round completed',
                detail: 'Saujana G&CC - Score 75 (+3)',
                timeAgo: '1d ago',
                type: _EventType.positive,
              ),
              _TimelineEvent(
                title: 'Cancellation refunded',
                detail: 'Mines Resort - USD 18.00 refunded',
                timeAgo: '4d ago',
                type: _EventType.warning,
              ),
            ],
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
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
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
  });

  final String course;
  final String dateLabel;
  final String timeLabel;
  final String playersLabel;
  final String countdownLabel;
  final String weatherLabel;
  final String checkInStatus;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.event_available_outlined, color: Color(0xFF0A1F1A)),
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
              OutlinedButton(onPressed: () {}, child: const Text('Modify')),
              const SizedBox(width: 8),
              FilledButton(onPressed: () {}, child: const Text('Check In')),
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
  });

  final String course;
  final String dateLabel;
  final String scoreLabel;
  final String durationLabel;
  final String fairwaysLabel;
  final String girLabel;
  final String puttsLabel;

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
              _Tag(text: 'Fairways $fairwaysLabel', color: const Color(0xFF2A6654)),
              _Tag(text: 'GIR $girLabel', color: const Color(0xFF2A6654)),
              _Tag(text: 'Putts $puttsLabel', color: const Color(0xFF2A6654)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              TextButton(onPressed: () {}, child: const Text('View Details')),
              const SizedBox(width: 6),
              TextButton(onPressed: () {}, child: const Text('Book Again')),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.events});

  final List<_TimelineEvent> events;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        children: [
          for (int i = 0; i < events.length; i++)
            _TimelineRow(
              event: events[i],
              isLast: i == events.length - 1,
            ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.event, required this.isLast});

  final _TimelineEvent event;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final color = switch (event.type) {
      _EventType.positive => const Color(0xFF1E8E5B),
      _EventType.warning => const Color(0xFFB26B1E),
      _EventType.info => const Color(0xFF2C6EA3),
      _EventType.neutral => const Color(0xFF486068),
    };

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 26,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: Colors.black12,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                      ),
                      Text(
                        event.timeAgo,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.black54,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    event.detail,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black87,
                        ),
                  ),
                ],
              ),
            ),
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
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
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

class _TimelineEvent {
  const _TimelineEvent({
    required this.title,
    required this.detail,
    required this.timeAgo,
    required this.type,
  });

  final String title;
  final String detail;
  final String timeAgo;
  final _EventType type;
}

enum _EventType {
  positive,
  warning,
  info,
  neutral,
}
