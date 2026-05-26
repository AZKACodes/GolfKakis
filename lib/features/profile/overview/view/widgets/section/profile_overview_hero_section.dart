import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/model/user_profile_model.dart';

import '../item/profile_overview_profile_avatar.dart';

class ProfileOverviewHeroSection extends StatelessWidget {
  const ProfileOverviewHeroSection({required this.profile, super.key});

  final UserProfileModel profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoggedIn = profile.isLoggedIn;

    if (!isLoggedIn) {
      return Row(
        children: [
          ProfileOverviewProfileAvatar(profile: profile, size: 56),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Guest',
              style: theme.textTheme.titleLarge?.copyWith(
                color: const Color(0xFF111827),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        ProfileOverviewProfileAvatar(profile: profile, size: 56),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            profile.displayName,
            style: theme.textTheme.titleLarge?.copyWith(
              color: const Color(0xFF111827),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
