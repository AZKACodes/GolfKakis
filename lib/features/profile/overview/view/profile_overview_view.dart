import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/model/profile/user_profile_model.dart';
import 'package:golf_kakis/features/home/overview/view/widgets/quick_action_tile.dart';

import '../viewmodel/profile_overview_view_contract.dart';

class ProfileOverviewView extends StatelessWidget {
  const ProfileOverviewView({
    required this.state,
    required this.onRefresh,
    required this.onPrimaryTouchpointClick,
    required this.onLogoutClick,
    super.key,
  });

  final ProfileOverviewViewState state;
  final Future<void> Function() onRefresh;
  final VoidCallback onPrimaryTouchpointClick;
  final VoidCallback onLogoutClick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = state.profile;

    if (state.isLoading && profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (profile == null) {
      return Center(
        child: Text(
          state.errorMessage ?? 'No profile available.',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    final body = profile.isAgent || profile.isAdmin
        ? _RoleTabbedBody(
            profile: profile,
            onPrimaryTouchpointClick: onPrimaryTouchpointClick,
            onLogoutClick: onLogoutClick,
          )
        : _StandardBody(
            profile: profile,
            onPrimaryTouchpointClick: onPrimaryTouchpointClick,
            onLogoutClick: onLogoutClick,
          );

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFFBF3), Color(0xFFF4F7FF), Color(0xFFF2FCF8)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            if (state.isUsingFallback) ...[
              const _InfoBanner(
                message:
                    'Showing temporary fallback profile until the user profile endpoint is ready.',
              ),
              const SizedBox(height: 12),
            ],
            if (state.errorMessage != null) ...[
              _ErrorBanner(message: state.errorMessage!),
              const SizedBox(height: 12),
            ],
            if (state.isLoading) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 12),
            ],
            _HeroCard(profile: profile),
            const SizedBox(height: 14),
            body,
          ],
        ),
      ),
    );
  }
}

class _StandardBody extends StatelessWidget {
  const _StandardBody({
    required this.profile,
    required this.onPrimaryTouchpointClick,
    required this.onLogoutClick,
  });

  final UserProfileModel profile;
  final VoidCallback onPrimaryTouchpointClick;
  final VoidCallback onLogoutClick;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PrimaryTouchpoint(profile: profile, onTap: onPrimaryTouchpointClick),
        const SizedBox(height: 16),
        const _AccountAndPreferencesSection(),
        if (profile.isLoggedIn) ...[
          const SizedBox(height: 18),
          _LogoutButton(onLogoutClick: onLogoutClick),
        ],
      ],
    );
  }
}

class _RoleTabbedBody extends StatelessWidget {
  const _RoleTabbedBody({
    required this.profile,
    required this.onPrimaryTouchpointClick,
    required this.onLogoutClick,
  });

  final UserProfileModel profile;
  final VoidCallback onPrimaryTouchpointClick;
  final VoidCallback onLogoutClick;

  @override
  Widget build(BuildContext context) {
    final dashboardTitle = profile.isAgent
        ? 'Agent Dashboard'
        : 'Admin Dashboard';
    final accent = profile.isAgent
        ? const Color(0xFF00A76F)
        : const Color(0xFF9C4DFF);

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.black12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x10000000),
                  blurRadius: 14,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TabBar(
                      dividerColor: Colors.transparent,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelColor: accent,
                      unselectedLabelColor: Colors.black54,
                      tabs: [
                        const Tab(text: 'Account'),
                        Tab(text: dashboardTitle),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 360,
                  child: TabBarView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: ListView(
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _PrimaryTouchpoint(
                              profile: profile,
                              onTap: onPrimaryTouchpointClick,
                            ),
                            const SizedBox(height: 16),
                            const _AccountAndPreferencesSection(),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: _DashboardSection(
                          title: dashboardTitle,
                          accent: accent,
                          quickActions: profile.isAgent
                              ? const [
                                  _DashboardQuickAction(
                                    icon: Icons.event_note_outlined,
                                    label: 'Manage Booking',
                                  ),
                                  _DashboardQuickAction(
                                    icon: Icons.apartment_outlined,
                                    label: 'Manage Organisation',
                                  ),
                                ]
                              : const [
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
                                ],
                          items: profile.isAgent
                              ? const [
                                  _DashboardItem(
                                    title: 'Lead Queue',
                                    subtitle: 'Review incoming customer leads.',
                                  ),
                                  _DashboardItem(
                                    title: 'Booking Follow Up',
                                    subtitle:
                                        'Track active booking assistance.',
                                  ),
                                  _DashboardItem(
                                    title: 'Commission Snapshot',
                                    subtitle:
                                        'Monitor pending and confirmed payouts.',
                                  ),
                                ]
                              : const [
                                  _DashboardItem(
                                    title: 'User Management',
                                    subtitle:
                                        'Monitor account approvals and flags.',
                                  ),
                                  _DashboardItem(
                                    title: 'Platform Controls',
                                    subtitle:
                                        'Manage operational settings and releases.',
                                  ),
                                  _DashboardItem(
                                    title: 'Audit Overview',
                                    subtitle:
                                        'Inspect recent admin-level actions.',
                                  ),
                                ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _LogoutButton(onLogoutClick: onLogoutClick),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.profile});

  final UserProfileModel profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF173B7A), Color(0xFF2F7BFF), Color(0xFF35C7A5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x332F7BFF),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
            ),
            child: Center(
              child: Text(
                profile.initials,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.displayName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.membershipLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
              ],
            ),
          ),
          _RoleBadge(label: profile.roleLabel),
        ],
      ),
    );
  }
}

class _PrimaryTouchpoint extends StatelessWidget {
  const _PrimaryTouchpoint({required this.profile, required this.onTap});

  final UserProfileModel profile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = profile.isLoggedIn ? 'Edit Profile' : 'Login or Register';
    final subtitle = profile.isLoggedIn
        ? 'Manage your visible profile details and preferences.'
        : 'Login or register to personalize your account.';
    final accent = profile.isLoggedIn
        ? const Color(0xFF2F7BFF)
        : const Color(0xFFFF9F1C);
    final icon = profile.isLoggedIn
        ? Icons.edit_outlined
        : Icons.login_outlined;

    return _TouchpointTile(
      icon: icon,
      title: title,
      subtitle: subtitle,
      accent: accent,
      isPrimary: true,
      onTap: onTap,
    );
  }
}

class _AccountAndPreferencesSection extends StatelessWidget {
  const _AccountAndPreferencesSection();

  @override
  Widget build(BuildContext context) {
    return const _SectionCard(
      title: 'Account & Preferences',
      accent: Color(0xFF2F7BFF),
      children: [
        _TouchpointTile(
          icon: Icons.manage_accounts_outlined,
          title: 'Manage Account',
          subtitle: 'Update account details and linked access later.',
          accent: Color(0xFF2F7BFF),
        ),
        _TouchpointTile(
          icon: Icons.notifications_none_outlined,
          title: 'Notifications',
          subtitle: 'Control alerts and reminders.',
          accent: Color(0xFFFF9F1C),
        ),
        _TouchpointTile(
          icon: Icons.language_outlined,
          title: 'Language',
          subtitle: 'Choose your preferred app language.',
          accent: Color(0xFF00A76F),
        ),
      ],
    );
  }
}

class _DashboardSection extends StatelessWidget {
  const _DashboardSection({
    required this.title,
    required this.accent,
    required this.quickActions,
    required this.items,
  });

  final String title;
  final Color accent;
  final List<_DashboardQuickAction> quickActions;
  final List<_DashboardItem> items;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
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
                  width: quickActions.length == 2 ? 132 : 120,
                  child: QuickActionTile(
                    icon: action.icon,
                    label: action.label,
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 18),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
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

class _DashboardItem {
  const _DashboardItem({required this.title, required this.subtitle});

  final String title;
  final String subtitle;
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.accent,
    required this.children,
  });

  final String title;
  final Color accent;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _TouchpointTile extends StatelessWidget {
  const _TouchpointTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    this.isPrimary = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final bool isPrimary;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          margin: EdgeInsets.only(bottom: isPrimary ? 0 : 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isPrimary ? accent.withValues(alpha: 0.08) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: accent.withValues(alpha: 0.22)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: accent),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onLogoutClick});

  final VoidCallback onLogoutClick;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onLogoutClick,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          foregroundColor: const Color(0xFF9F2D2D),
          side: const BorderSide(color: Color(0xFFE7A1A1)),
          backgroundColor: Colors.white,
        ),
        icon: const Icon(Icons.logout_outlined),
        label: const Text('Logout'),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: const Color(0xFF173B7A),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF3D6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9C46A)),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: const Color(0xFF7A5B00),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDECEC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE7A1A1)),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: const Color(0xFF8A3D3D),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
