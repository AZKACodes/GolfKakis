import 'package:flutter/material.dart';

import '../../../viewmodel/home_view_contract.dart';
import '../item/home_quick_action_item.dart';

class HomeQuickActionSection extends StatelessWidget {
  const HomeQuickActionSection({required this.onUserIntent, super.key});

  final ValueChanged<HomeUserIntent> onUserIntent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: HomeQuickActionItem(
                icon: Icons.add_box_outlined,
                label: 'New Booking',
                onTap: () => onUserIntent(const OnNewBookingClick()),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: HomeQuickActionItem(
                icon: Icons.golf_course_outlined,
                label: 'Courses',
                onTap: () => onUserIntent(const OnGolfClubListClick()),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: HomeQuickActionItem(
                icon: Icons.receipt_long_outlined,
                label: 'My Booking',
                onTap: () => onUserIntent(const OnBookingListClick()),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
