import 'package:flutter/material.dart';

import 'widgets/booking_health_card.dart';
import 'widgets/club_availability_card.dart';
import 'widgets/next_booking_card.dart';

class BookingOverviewDashboardView extends StatelessWidget {
  const BookingOverviewDashboardView({
    required this.onBookingSubmissionClick,
    super.key,
  });

  final VoidCallback onBookingSubmissionClick;

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
          NextBookingCard(onOpenSubmission: onBookingSubmissionClick),
          const SizedBox(height: 18),
          Text(
            'Popular Clubs Today',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          const ClubAvailabilityCard(
            clubName: 'Kinrara Golf Club',
            distanceLabel: '9 km away',
            openSlotsLabel: '14 morning slots',
            greenFeeLabel: 'From USD 39',
            peakLabel: 'Peak 7:20 AM',
          ),
          const SizedBox(height: 10),
          const ClubAvailabilityCard(
            clubName: 'Saujana Golf & Country Club',
            distanceLabel: '15 km away',
            openSlotsLabel: '11 morning slots',
            greenFeeLabel: 'From USD 52',
            peakLabel: 'Peak 8:00 AM',
          ),
          const SizedBox(height: 10),
          const ClubAvailabilityCard(
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
          const BookingHealthCard(),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onBookingSubmissionClick,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Start New Booking'),
            ),
          ),
        ],
      ),
    );
  }
}
