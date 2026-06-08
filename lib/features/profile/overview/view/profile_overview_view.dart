import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/widgets/error_banner.dart';
import 'package:golf_kakis/features/foundation/widgets/container/golf_kakis_shimmer_container.dart';

import '../viewmodel/profile_overview_view_contract.dart';
import 'widgets/section/profile_overview_hero_section.dart';
import 'widgets/section/profile_overview_role_tabbed_body_section.dart';
import 'widgets/section/profile_overview_standard_body_section.dart';

const double _bottomNavScrollClearance = 136;

class ProfileOverviewView extends StatelessWidget {
  const ProfileOverviewView({
    required this.state,
    required this.onRefresh,
    required this.onPrimaryTouchpointClick,
    required this.onMyGolfKakisClick,
    required this.onLanguageClick,
    required this.onNotificationClick,
    required this.onLogoutClick,
    super.key,
  });

  final ProfileOverviewViewState state;
  final Future<void> Function() onRefresh;
  final VoidCallback onPrimaryTouchpointClick;
  final VoidCallback onMyGolfKakisClick;
  final VoidCallback onLanguageClick;
  final VoidCallback onNotificationClick;
  final VoidCallback onLogoutClick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = state.profile;

    if (state.isLoading && profile == null) {
      return const _ProfileOverviewLoadingShimmer();
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
        ? ProfileOverviewRoleTabbedBodySection(
            profile: profile,
            onPrimaryTouchpointClick: onPrimaryTouchpointClick,
            onMyGolfKakisClick: onMyGolfKakisClick,
            onLanguageClick: onLanguageClick,
            onNotificationClick: onNotificationClick,
            onLogoutClick: onLogoutClick,
          )
        : ProfileOverviewStandardBodySection(
            profile: profile,
            onPrimaryTouchpointClick: onPrimaryTouchpointClick,
            onMyGolfKakisClick: onMyGolfKakisClick,
            onLanguageClick: onLanguageClick,
            onNotificationClick: onNotificationClick,
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
          padding: const EdgeInsets.fromLTRB(
            16,
            16,
            16,
            _bottomNavScrollClearance,
          ),
          children: [
            if (state.errorMessage != null) ...[
              ErrorBanner(message: state.errorMessage!),
              const SizedBox(height: 12),
            ],
            if (state.isLoading) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 12),
            ],
            ProfileOverviewHeroSection(profile: profile),
            const SizedBox(height: 16),
            Divider(color: Colors.black.withValues(alpha: 0.12), height: 1),
            const SizedBox(height: 16),
            body,
          ],
        ),
      ),
    );
  }
}

class _ProfileOverviewLoadingShimmer extends StatelessWidget {
  const _ProfileOverviewLoadingShimmer();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFFBF3), Color(0xFFF4F7FF), Color(0xFFF2FCF8)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          _bottomNavScrollClearance,
        ),
        children: const [
          Row(
            children: [
              GolfKakisShimmerContainer(
                width: 56,
                height: 56,
                borderRadius: 999,
              ),
              SizedBox(width: 12),
              Expanded(
                child: GolfKakisShimmerContainer(height: 24, borderRadius: 8),
              ),
            ],
          ),
          SizedBox(height: 16),
          Divider(height: 1),
          SizedBox(height: 16),
          _ProfilePreferenceLoadingCard(),
          SizedBox(height: 12),
          _ProfilePreferenceLoadingCard(),
          SizedBox(height: 12),
          _ProfilePreferenceLoadingCard(),
          SizedBox(height: 24),
          GolfKakisShimmerContainer(height: 52, borderRadius: 16),
        ],
      ),
    );
  }
}

class _ProfilePreferenceLoadingCard extends StatelessWidget {
  const _ProfilePreferenceLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
      ),
      child: const Row(
        children: [
          GolfKakisShimmerContainer(width: 44, height: 44, borderRadius: 14),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GolfKakisShimmerContainer(height: 16, borderRadius: 8),
                SizedBox(height: 8),
                GolfKakisShimmerContainer(
                  width: 180,
                  height: 13,
                  borderRadius: 7,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
