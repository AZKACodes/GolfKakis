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
          'Quick actions',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          clipBehavior: Clip.none,
          child: Row(
            children: [
              HomeQuickActionItem(
                icon: Icons.golf_course_rounded,
                label: 'Book',
                backgroundColor: const Color(0xFFEAF6F0),
                iconColor: const Color(0xFF0D7A3A),
                onTap: () => onUserIntent(const OnNewBookingClick()),
              ),
              const SizedBox(width: 10),
              HomeQuickActionItem(
                icon: Icons.flag_rounded,
                label: 'Courses',
                backgroundColor: const Color(0xFFFFF7E6),
                iconColor: const Color(0xFFC6A969),
                onTap: () => onUserIntent(const OnGolfClubListClick()),
              ),
              const SizedBox(width: 10),
              HomeQuickActionItem(
                icon: Icons.local_offer_rounded,
                label: 'Deals',
                backgroundColor: const Color(0xFFFFF1D6),
                iconColor: const Color(0xFF9A3412),
                onTap: () => onUserIntent(const OnDealsClick()),
              ),
              const SizedBox(width: 10),
              HomeQuickActionItem(
                icon: Icons.hotel_rounded,
                label: 'Stay N Play',
                backgroundColor: const Color(0xFFEAF6F0),
                iconColor: const Color(0xFF1E5B4A),
                onTap: () => onUserIntent(const OnStayPlayClick()),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
