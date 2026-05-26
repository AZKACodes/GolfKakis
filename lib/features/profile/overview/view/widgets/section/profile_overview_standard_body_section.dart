import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/model/user_profile_model.dart';

import '../item/profile_overview_logout_button.dart';
import 'profile_overview_account_preferences_section.dart';

class ProfileOverviewStandardBodySection extends StatelessWidget {
  const ProfileOverviewStandardBodySection({
    required this.profile,
    required this.onPrimaryTouchpointClick,
    required this.onMyGolfKakisClick,
    required this.onLanguageClick,
    required this.onNotificationClick,
    required this.onLogoutClick,
    super.key,
  });

  final UserProfileModel profile;
  final VoidCallback onPrimaryTouchpointClick;
  final VoidCallback onMyGolfKakisClick;
  final VoidCallback onLanguageClick;
  final VoidCallback onNotificationClick;
  final VoidCallback onLogoutClick;

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = profile.isLoggedIn;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileOverviewAccountPreferencesSection(
          profile: profile,
          onPrimaryTouchpointClick: onPrimaryTouchpointClick,
          onMyGolfKakisClick: onMyGolfKakisClick,
          onLanguageClick: onLanguageClick,
          onNotificationClick: onNotificationClick,
        ),
        if (isLoggedIn) ...[
          const SizedBox(height: 24),
          ProfileOverviewLogoutButton(onLogoutClick: onLogoutClick),
        ],
      ],
    );
  }
}
