import 'package:flutter/material.dart';

class BookNowCard extends StatelessWidget {
  const BookNowCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF0A1F1A), Color(0xFF2A7A62)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No Upcoming Booking',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Book Now and Own the Fairway',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Find your perfect tee time and lock it in seconds.',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
