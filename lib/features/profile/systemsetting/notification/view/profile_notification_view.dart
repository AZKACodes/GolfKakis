import 'package:flutter/material.dart';

import '../viewmodel/profile_notification_view_contract.dart';

class ProfileNotificationView extends StatelessWidget {
  const ProfileNotificationView({
    required this.state,
    required this.onUserIntent,
    super.key,
  });

  final ProfileNotificationViewState state;
  final ValueChanged<ProfileNotificationUserIntent> onUserIntent;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _NotificationCard(
          children: [
            _NotificationToggleTile(
              title: 'Push Notifications',
              subtitle: 'Receive important updates from GolfKakis.',
              value: state.pushNotificationsEnabled,
              onChanged: (value) => onUserIntent(
                OnProfileNotificationPushToggled(value),
              ),
            ),
            const _InsetDivider(),
            _NotificationToggleTile(
              title: 'Booking Reminders',
              subtitle: 'Get reminded before your tee times and bookings.',
              value: state.bookingRemindersEnabled,
              onChanged: (value) => onUserIntent(
                OnProfileNotificationBookingRemindersToggled(value),
              ),
            ),
            const _InsetDivider(),
            _NotificationToggleTile(
              title: 'Promotions & Updates',
              subtitle: 'Stay in the loop on offers and new features.',
              value: state.promotionsEnabled,
              onChanged: (value) => onUserIntent(
                OnProfileNotificationPromotionsToggled(value),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
      ),
      child: Column(children: children),
    );
  }
}

class _NotificationToggleTile extends StatelessWidget {
  const _NotificationToggleTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF111827),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
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
