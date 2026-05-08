import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/model/profile/user_profile_model.dart';

class ProfileOverviewAccountPreferencesSection extends StatelessWidget {
  const ProfileOverviewAccountPreferencesSection({
    required this.profile,
    required this.onPrimaryTouchpointClick,
    required this.onMyGolfKakisClick,
    required this.onLanguageClick,
    required this.onNotificationClick,
    super.key,
  });

  final UserProfileModel profile;
  final VoidCallback onPrimaryTouchpointClick;
  final VoidCallback onMyGolfKakisClick;
  final VoidCallback onLanguageClick;
  final VoidCallback onNotificationClick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoggedIn = profile.isLoggedIn;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (!isLoggedIn) ...[
          _MenuCard(
            child: _AccountMenuItem(
              title: 'Login or Register to Begin',
              onTap: onPrimaryTouchpointClick,
            ),
          ),
          const SizedBox(height: 24),
        ],
        if (isLoggedIn) ...[
          Text(
            'Account',
            style: theme.textTheme.titleLarge?.copyWith(
              color: const Color(0xFF111827),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _MenuCard(
            child: Column(
              children: [
                _AccountMenuItem(
                  title: 'Profile Details',
                  onTap: onPrimaryTouchpointClick,
                ),
                const _InsetDivider(),
                _AccountMenuItem(
                  title: 'Friendlist (My Kakis)',
                  onTap: onMyGolfKakisClick,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
        Text(
          'System Setting',
          style: theme.textTheme.titleLarge?.copyWith(
            color: const Color(0xFF111827),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        _SettingsCard(
          onLanguageTap: onLanguageClick,
          onNotificationTap: onNotificationClick,
        ),
      ],
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
      ),
      child: child,
    );
  }
}

class _AccountMenuItem extends StatelessWidget {
  const _AccountMenuItem({required this.title, this.onTap});

  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    final titleColor = isEnabled
        ? const Color(0xFF111827)
        : const Color(0xFF9CA3AF);
    final iconColor = isEnabled
        ? const Color(0xFF6B7280)
        : const Color(0xFFD1D5DB);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: titleColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: iconColor),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.onLanguageTap,
    required this.onNotificationTap,
  });

  final VoidCallback onLanguageTap;
  final VoidCallback onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return _MenuCard(
      child: Column(
        children: [
          _AccountMenuItem(title: 'Language', onTap: onLanguageTap),
          const _InsetDivider(),
          _AccountMenuItem(title: 'Notification', onTap: onNotificationTap),
        ],
      ),
    );
  }
}

class _InsetDivider extends StatelessWidget {
  const _InsetDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Colors.black.withValues(alpha: 0.08),
      ),
    );
  }
}
