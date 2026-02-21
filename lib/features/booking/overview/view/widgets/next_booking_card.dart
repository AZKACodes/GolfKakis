import 'package:flutter/material.dart';

class NextBookingCard extends StatelessWidget {
  const NextBookingCard({required this.onOpenSubmission, super.key});

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
