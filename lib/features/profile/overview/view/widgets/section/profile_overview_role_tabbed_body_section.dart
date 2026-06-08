import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/model/user_profile_model.dart';
import 'package:golf_kakis/features/home/overview/view/widgets/item/home_quick_action_item.dart';

import '../item/profile_overview_logout_button.dart';
import '../item/profile_overview_section_card.dart';
import 'profile_overview_account_preferences_section.dart';

class ProfileOverviewRoleTabbedBodySection extends StatelessWidget {
  const ProfileOverviewRoleTabbedBodySection({
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
    final dashboardTitle = profile.isAgent
        ? 'Agent Dashboard'
        : 'Admin Dashboard';
    final accent = profile.isAgent
        ? const Color(0xFF00A76F)
        : const Color(0xFF9C4DFF);

    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (context) {
          final controller = DefaultTabController.of(context);

          return AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              final selectedIndex = controller.index;
              final selectedBody = selectedIndex == 0
                  ? Column(
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
                          ProfileOverviewLogoutButton(
                            onLogoutClick: onLogoutClick,
                          ),
                        ],
                      ],
                    )
                  : _DashboardSection(
                      title: dashboardTitle,
                      accent: accent,
                      quickActions: profile.isAgent
                          ? const <_DashboardQuickAction>[
                              _DashboardQuickAction(
                                icon: Icons.event_note_outlined,
                                label: 'Manage Booking',
                              ),
                              _DashboardQuickAction(
                                icon: Icons.groups_outlined,
                                label: 'Lead Queue',
                              ),
                              _DashboardQuickAction(
                                icon: Icons.apartment_outlined,
                                label: 'Manage Organisation',
                              ),
                              _DashboardQuickAction(
                                icon: Icons.payments_outlined,
                                label: 'Commissions',
                              ),
                            ]
                          : const <_DashboardQuickAction>[
                              _DashboardQuickAction(
                                icon: Icons.event_note_outlined,
                                label: 'Manage Booking',
                              ),
                              _DashboardQuickAction(
                                icon: Icons.group_outlined,
                                label: 'Manage Users',
                              ),
                              _DashboardQuickAction(
                                icon: Icons.apartment_outlined,
                                label: 'Manage Organisation',
                              ),
                              _DashboardQuickAction(
                                icon: Icons.tune_outlined,
                                label: 'Platform Controls',
                              ),
                              _DashboardQuickAction(
                                icon: Icons.fact_check_outlined,
                                label: 'Audit Overview',
                              ),
                            ],
                    );

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: TabBar(
                          dividerColor: Colors.transparent,
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicator: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          labelStyle: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                          unselectedLabelStyle: Theme.of(
                            context,
                          ).textTheme.labelLarge,
                          labelColor: Colors.black87,
                          unselectedLabelColor: Colors.black54,
                          splashBorderRadius: BorderRadius.circular(8),
                          tabs: [
                            const Tab(text: 'Account'),
                            Tab(text: dashboardTitle),
                          ],
                        ),
                      ),
                    ),
                  ),
                  selectedBody,
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _DashboardSection extends StatelessWidget {
  const _DashboardSection({
    required this.title,
    required this.accent,
    required this.quickActions,
  });

  final String title;
  final Color accent;
  final List<_DashboardQuickAction> quickActions;

  @override
  Widget build(BuildContext context) {
    return ProfileOverviewSectionCard(
      title: title,
      accent: accent,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: quickActions
              .map(
                (action) => SizedBox(
                  width: 140,
                  child: HomeQuickActionItem(
                    icon: action.icon,
                    label: action.label,
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _DashboardQuickAction {
  const _DashboardQuickAction({required this.icon, required this.label});

  final IconData icon;
  final String label;
}
