import 'package:flutter/material.dart';

class UpcomingBookingCard extends StatelessWidget {
  const UpcomingBookingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color(0xFFEFF8F4),
        border: Border.all(color: const Color(0xFFD3E9DF)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upcoming Booking',
            style: TextStyle(
              color: Color(0xFF1E5B4A),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Green Valley Golf Club',
            style: TextStyle(
              color: Color(0xFF081512),
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Fri, 7:30 AM • 2 Players • Hole 1 Start',
            style: TextStyle(color: Color(0xFF486861)),
          ),
        ],
      ),
    );
  }
}
