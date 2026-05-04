import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/session/session_scope.dart';
import 'package:golf_kakis/features/foundation/session/session_state.dart';

import '../viewmodel/home_view_contract.dart';
import 'widgets/section/home_announcement_section.dart';
import 'widgets/section/home_deals_section.dart';
import 'widgets/section/home_header_section.dart';
import 'widgets/section/home_quick_action_section.dart';

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
    final session = SessionScope.of(context).state;
    final displayName = loadedState.headerDisplayName.trim().isNotEmpty
        ? loadedState.headerDisplayName
        : _resolveHeaderName(session);
    final greeting = session.isLoggedIn
        ? 'Welcome back, $displayName'
        : 'Welcome, Guest';

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, _bottomNavScrollClearance),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeHeaderSection(
            greeting: greeting,
            showAvatar: session.isLoggedIn,
            avatarIndex: loadedState.headerAvatarIndex,
          ),

          const SizedBox(height: 24),
          HomeAnnouncementSection(items: loadedState.advertisements),

          const SizedBox(height: 24),
          HomeQuickActionSection(onUserIntent: onUserIntent),

          const SizedBox(height: 24),
          HomeDealsSection(items: loadedState.deals),
        ],
      ),
    );
  }
}

String _resolveHeaderName(SessionState session) {
  if (session.isLoggedIn) {
    final rawName =
        session.profileFullName?.trim() ??
        session.authenticatedUsername?.trim() ??
        '';
    if (rawName.isNotEmpty) {
      return rawName.split(RegExp(r'\s+')).first;
    }
    return 'Golfer';
  }
  return 'Guest';
}
