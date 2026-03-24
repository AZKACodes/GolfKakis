import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/model/booking/golf_club_model.dart';

const double _bottomNavScrollClearance = 136;

class BookingOverviewDashboardView extends StatelessWidget {
  const BookingOverviewDashboardView({
    required this.onBookingSubmissionClick,
    required this.onPopularClubClick,
    required this.onBookingListClick,
    required this.onUpcomingBookingDetailClick,
    required this.onRecentRoundOneDetailClick,
    required this.onRecentRoundTwoDetailClick,
    super.key,
  });

  final VoidCallback onBookingSubmissionClick;
  final ValueChanged<GolfClubModel> onPopularClubClick;
  final VoidCallback onBookingListClick;
  final VoidCallback onUpcomingBookingDetailClick;
  final VoidCallback onRecentRoundOneDetailClick;
  final VoidCallback onRecentRoundTwoDetailClick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, _bottomNavScrollClearance),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onBookingSubmissionClick,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Start New Booking'),
            ),
          ),

          const SizedBox(height: 18),

          _BookingListTouchpoint(onTap: onBookingListClick),

          const SizedBox(height: 18),

          const _SectionTitle(title: 'Upcoming Booking'),

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

          const SizedBox(height: 18),

          const _SectionTitle(title: 'Popular Clubs Today'),

          const SizedBox(height: 10),

          SizedBox(
            height: 212,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _popularClubs.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final item = _popularClubs[index];
                return SizedBox(
                  width: 250,
                  child: _PopularClubCard(
                    item: item,
                    onTap: () => onPopularClubClick(item.club),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 18),

          const _SectionTitle(title: 'Recent Rounds'),

          const SizedBox(height: 10),

          SizedBox(
            height: 208,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                SizedBox(
                  width: 252,
                  child: _RoundCard(
                    course: 'Saujana G&CC',
                    dateLabel: 'Tue, Feb 25',
                    scoreLabel: '75 (+3)',
                    durationLabel: '4h 12m',
                    fairwaysLabel: '71%',
                    girLabel: '61%',
                    puttsLabel: '31',
                    onOpenDetails: onRecentRoundOneDetailClick,
                  ),
                ),

                const SizedBox(width: 12),

                SizedBox(
                  width: 252,
                  child: _RoundCard(
                    course: 'Kota Permai',
                    dateLabel: 'Sat, Mar 1',
                    scoreLabel: '72 (E)',
                    durationLabel: '3h 58m',
                    fairwaysLabel: '78%',
                    girLabel: '67%',
                    puttsLabel: '29',
                    onOpenDetails: onRecentRoundTwoDetailClick,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final List<_PopularClubItem> _popularClubs = <_PopularClubItem>[
  _PopularClubItem(
    club: GolfClubModel(
      id: '1',
      slug: 'kinrara-golf-club',
      name: 'Kinrara Golf Club',
      address: 'Bandar Kinrara, Puchong',
      noOfHoles: 18,
    ),
    distanceLabel: '9 km away',
    openSlotsLabel: '14 morning slots',
    greenFeeLabel: 'From MYR 39',
    peakLabel: 'Peak 7:20 AM',
  ),

  _PopularClubItem(
    club: GolfClubModel(
      id: '2',
      slug: 'saujana-golf-country-club',
      name: 'Saujana Golf & Country Club',
      address: 'Shah Alam, Selangor',
      noOfHoles: 36,
    ),
    distanceLabel: '15 km away',
    openSlotsLabel: '11 morning slots',
    greenFeeLabel: 'From MYR 52',
    peakLabel: 'Peak 8:00 AM',
  ),

  _PopularClubItem(
    club: GolfClubModel(
      id: '4',
      slug: 'mines-resort-golf-club',
      name: 'The Mines Resort & Golf Club',
      address: 'Serdang, Selangor',
      noOfHoles: 18,
    ),
    distanceLabel: '21 km away',
    openSlotsLabel: '9 morning slots',
    greenFeeLabel: 'From MYR 47',
    peakLabel: 'Peak 7:40 AM',
  ),
];

class _PopularClubItem {
  const _PopularClubItem({
    required this.club,
    required this.distanceLabel,
    required this.openSlotsLabel,
    required this.greenFeeLabel,
    required this.peakLabel,
  });

  final GolfClubModel club;
  final String distanceLabel;
  final String openSlotsLabel;
  final String greenFeeLabel;
  final String peakLabel;
}

class _BookingListTouchpoint extends StatelessWidget {
  const _BookingListTouchpoint({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
      ),
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
          FilledButton(onPressed: onTap, child: const Text('Open')),
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

class _PopularClubCard extends StatelessWidget {
  const _PopularClubCard({required this.item, required this.onTap});

  final _PopularClubItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF7FBF9), Color(0xFFFFFFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDCE9E2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.club.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),

          const SizedBox(height: 4),

          Text(
            item.club.address,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.black54),
          ),

          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Tag(text: item.distanceLabel, color: const Color(0xFF215E4D)),
              _Tag(text: item.openSlotsLabel, color: const Color(0xFF2F7BFF)),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _ClubMetric(
                  label: 'Green Fee',
                  value: item.greenFeeLabel,
                ),
              ),
              Expanded(
                child: _ClubMetric(label: 'Peak', value: item.peakLabel),
              ),
            ],
          ),

          const SizedBox(height: 10),
          
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
                textStyle: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              onPressed: onTap,
              child: const Text('View Club'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClubMetric extends StatelessWidget {
  const _ClubMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.black54),
        ),
      ],
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF163C33), Color(0xFF255C4E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.event_available_outlined, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  course,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              _SurfaceTag(text: countdownLabel),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _SurfaceTag(text: dateLabel),
              _SurfaceTag(text: timeLabel),
              _SurfaceTag(text: playersLabel),
              _SurfaceTag(text: weatherLabel),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  checkInStatus,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: onOpenDetails,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24),
                ),
                child: const Text('Modify'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: onOpenDetails,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF163C33),
                ),
                child: const Text('Details'),
              ),
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE1E7E4)),
      ),
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
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MetricTile(label: 'Score', value: scoreLabel),
              ),
              Expanded(
                child: _MetricTile(label: 'Duration', value: durationLabel),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _MetricTile(label: 'Fairways', value: fairwaysLabel),
              ),
              Expanded(
                child: _MetricTile(label: 'GIR', value: girLabel),
              ),
              Expanded(
                child: _MetricTile(label: 'Putts', value: puttsLabel),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onOpenDetails,
              icon: const Icon(Icons.visibility_outlined),
              label: const Text('View Details'),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.black54),
        ),
      ],
    );
  }
}

class _SurfaceTag extends StatelessWidget {
  const _SurfaceTag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
