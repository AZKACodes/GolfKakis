import 'package:flutter/material.dart';

import '../../../foundation/navigation/booking_nav_graph.dart';

class BookingOverviewDashboardView extends StatelessWidget {
  const BookingOverviewDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booking Overview',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Browse your next round opportunities before entering submission.',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 20),
          _NextBookingCard(
            onOpenSubmission: () => Navigator.of(context).pushNamed(
              BookingNavGraph.submission,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Popular Clubs Today',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          const _ClubAvailabilityCard(
            clubName: 'Kinrara Golf Club',
            distanceLabel: '9 km away',
            openSlotsLabel: '14 morning slots',
            greenFeeLabel: 'From USD 39',
            peakLabel: 'Peak 7:20 AM',
          ),
          const SizedBox(height: 10),
          const _ClubAvailabilityCard(
            clubName: 'Saujana Golf & Country Club',
            distanceLabel: '15 km away',
            openSlotsLabel: '11 morning slots',
            greenFeeLabel: 'From USD 52',
            peakLabel: 'Peak 8:00 AM',
          ),
          const SizedBox(height: 10),
          const _ClubAvailabilityCard(
            clubName: 'Mines Resort & Golf Club',
            distanceLabel: '21 km away',
            openSlotsLabel: '9 morning slots',
            greenFeeLabel: 'From USD 47',
            peakLabel: 'Peak 7:40 AM',
          ),
          const SizedBox(height: 18),
          Text(
            'Your Booking Health',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          const _BookingHealthCard(),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => Navigator.of(context).pushNamed(
                BookingNavGraph.submission,
              ),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Start New Booking'),
            ),
          ),
        ],
      ),
    );
  }
}

class _NextBookingCard extends StatelessWidget {
  const _NextBookingCard({required this.onOpenSubmission});

  final VoidCallback onOpenSubmission;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF0A1F1A), Color(0xFF1E5B4A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Start',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ready to lock your next tee time?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Open submission to choose club, date, and exact slot.',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onOpenSubmission,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0A1F1A),
            ),
            child: const Text('Open Submission'),
          ),
        ],
      ),
    );
  }
}

class _ClubAvailabilityCard extends StatelessWidget {
  const _ClubAvailabilityCard({
    required this.clubName,
    required this.distanceLabel,
    required this.openSlotsLabel,
    required this.greenFeeLabel,
    required this.peakLabel,
  });

  final String clubName;
  final String distanceLabel;
  final String openSlotsLabel;
  final String greenFeeLabel;
  final String peakLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            clubName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(text: distanceLabel),
              _InfoChip(text: openSlotsLabel),
              _InfoChip(text: greenFeeLabel),
              _InfoChip(text: peakLabel),
            ],
          ),
        ],
      ),
    );
  }
}

class _BookingHealthCard extends StatelessWidget {
  const _BookingHealthCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: const Column(
        children: [
          _HealthRow(label: 'Upcoming Confirmed', value: '2'),
          SizedBox(height: 10),
          _HealthRow(label: 'Pending Payment', value: '1'),
          SizedBox(height: 10),
          _HealthRow(label: 'Avg Booking Lead Time', value: '3.4 days'),
        ],
      ),
    );
  }
}

class _HealthRow extends StatelessWidget {
  const _HealthRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF12332A),
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6F2),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A3A32),
        ),
      ),
    );
  }
}
