import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/session/session_scope.dart';
import 'package:golf_kakis/features/foundation/session/session_state.dart';

import '../viewmodel/home_view_contract.dart';
import 'widgets/deal_card.dart';
import 'widgets/home_announcements_carousel.dart';
import 'widgets/home_at_a_glance_card.dart';
import 'widgets/home_quick_book_card.dart';
import 'widgets/quick_action_tile.dart';

const double _bottomNavScrollClearance = 136;

class HomeView extends StatelessWidget {
  const HomeView({required this.state, required this.onUserIntent, super.key});

  final HomeViewState state;
  final ValueChanged<HomeUserIntent> onUserIntent;

  @override
  Widget build(BuildContext context) {
    final loadedState = switch (state) {
      HomeDataLoaded() => state as HomeDataLoaded,
    };
    final theme = Theme.of(context);
    final session = SessionScope.of(context).state;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, _bottomNavScrollClearance),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeAtAGlanceCard(greeting: _resolveGreeting(session)),

          const SizedBox(height: 24),

          const HomeAnnouncementsCarousel(),

          const SizedBox(height: 24),

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
                child: QuickActionTile(
                  icon: Icons.add_box_outlined,
                  label: 'New Booking',
                  onTap: () => onUserIntent(const OnNewBookingClick()),
                ),
              ),
              const SizedBox(width: 10),

              Expanded(
                child: QuickActionTile(
                  icon: Icons.golf_course_outlined,
                  label: 'Courses',
                  onTap: () => onUserIntent(const OnGolfClubListClick()),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: QuickActionTile(
                  icon: Icons.receipt_long_outlined,
                  label: 'My Tee Times',
                  onTap: () => onUserIntent(const OnBookingListClick()),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Text(
            'Quick Book',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 12),

          if (loadedState.quickBookItems.isNotEmpty)
            Column(
              children: [
                for (var i = 0; i < loadedState.quickBookItems.length; i++) ...[
                  HomeQuickBookCard(
                    item: loadedState.quickBookItems[i],
                    onTap: () => onUserIntent(
                      OnQuickBookClick(loadedState.quickBookItems[i].clubSlug),
                    ),
                  ),
                  if (i != loadedState.quickBookItems.length - 1)
                    const SizedBox(height: 10),
                ],
              ],
            )
          else if (loadedState.isLoading)
            const SizedBox.shrink(),

          const SizedBox(height: 24),

          Text(
            "Today's Hot Deals",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 12),
          Column(
            children: [
              for (var i = 0; i < loadedState.hotDeals.length; i++) ...[
                DealCard(
                  title: loadedState.hotDeals[i].title,
                  subtitle: loadedState.hotDeals[i].subtitle,
                  price: loadedState.hotDeals[i].priceLabel,
                  badge: loadedState.hotDeals[i].badge,
                ),
                if (i != loadedState.hotDeals.length - 1)
                  const SizedBox(height: 10),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

String _resolveGreeting(SessionState session) {
  if (session.isLoggedIn) {
    final rawName =
        session.profileFullName?.trim() ??
        session.authenticatedUsername?.trim() ??
        '';
    if (rawName.isNotEmpty) {
      final firstName = rawName.split(RegExp(r'\s+')).first;
      return 'Welcome back, $firstName';
    }
    return 'Welcome back';
  }
  return 'Welcome, Guest';
}
