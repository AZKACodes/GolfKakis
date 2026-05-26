import 'package:flutter/material.dart';

class CourseDetailsBottomBarSection extends StatelessWidget {
  const CourseDetailsBottomBarSection({
    required this.onBookNowTap,
    required this.onQuickBookTap,
    super.key,
  });

  final VoidCallback onBookNowTap;
  final VoidCallback onQuickBookTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: [
          Expanded(
            flex: 7,
            child: FilledButton.icon(
              onPressed: onBookNowTap,
              icon: const Icon(Icons.calendar_month_outlined),
              label: const Text('Book Now'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: OutlinedButton.icon(
              onPressed: onQuickBookTap,
              icon: const Icon(Icons.flash_on_outlined),
              label: const Text('Quick Book'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
