import 'package:flutter/material.dart';

import 'widgets/book_now_card.dart';
import 'widgets/deal_card.dart';
import 'widgets/quick_action_tile.dart';
import 'widgets/upcoming_booking_card.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasUpcomingBooking = DateTime.now().day.isEven;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasUpcomingBooking)
            const UpcomingBookingCard()
          else
            const BookNowCard(),
          const SizedBox(height: 24),
          Text(
            'Quick Actions',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(
                child: QuickActionTile(
                  icon: Icons.add_box_outlined,
                  label: 'New Booking',
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: QuickActionTile(
                  icon: Icons.golf_course_outlined,
                  label: 'Courses',
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: QuickActionTile(
                  icon: Icons.receipt_long_outlined,
                  label: 'My Tee Times',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
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
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Promotion',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Weekday Tee Time Specials',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Book before 10 AM and get 20% off selected courses.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Today's Hot Deals",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          const DealCard(
            title: 'Sunrise Tee Time',
            subtitle: 'Green Valley Golf Club',
            price: '\$49',
            badge: 'Hot',
          ),
          const SizedBox(height: 10),
          const DealCard(
            title: 'Weekend Pair Deal',
            subtitle: '2 players at Harbor Links',
            price: '\$89',
            badge: 'Top',
          ),
          const SizedBox(height: 10),
          const DealCard(
            title: 'Twilight 9-Hole',
            subtitle: 'After 4:00 PM at Pine Hills',
            price: '\$29',
            badge: 'Deal',
          ),
        ],
      ),
    );
  }
}
