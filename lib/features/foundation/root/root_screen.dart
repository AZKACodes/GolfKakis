import 'package:flutter/material.dart';
import 'dart:async';

import '../navigation/activity_nav_graph.dart';
import '../navigation/booking_nav_graph.dart';
import '../navigation/home_nav_graph.dart';
import '../navigation/profile_nav_graph.dart';
import '../enums/session/session_status.dart';
import '../session/session_scope.dart';
import 'nav_item.dart';
import 'viewmodel/root_view_contract.dart';
import 'viewmodel/root_view_model.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  late final RootViewModel _viewModel;
  StreamSubscription<RootNavEffect>? _navEffectSubscription;

  static const List<NavItem> _items = [
    NavItem(label: 'Home', icon: Icons.home_outlined),
    NavItem(label: 'Booking', icon: Icons.event_outlined),
    NavItem(label: 'Activity', icon: Icons.local_activity_outlined),
    NavItem(label: 'Profile', icon: Icons.person_outline),
  ];

  static const List<Widget> _pages = [
    HomeNavGraph(),
    BookingNavGraph(),
    ActivityNavGraph(),
    ProfileNavGraph(),
  ];

  @override
  void initState() {
    super.initState();
    _viewModel = RootViewModel();
    _navEffectSubscription = _viewModel.navEffects.listen((effect) {
      if (effect is RootTabChangedNavEffect) {
        // Tab body is bound to view state. This marks effect consumption.
      }
    });
  }

  @override
  void dispose() {
    _navEffectSubscription?.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessionManager = SessionScope.of(context);
    final session = sessionManager.state;
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final currentIndex = _viewModel.viewState.currentIndex;
        final sessionLabel = session.status == SessionStatus.loggedIn
            ? 'Logged in as ${session.effectiveUsername}'
            : 'Guest: ${session.effectiveUsername}';

        return Scaffold(
          appBar: AppBar(
            title: Text(_items[currentIndex].label),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(26),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  sessionLabel,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
            ),
          ),
          body: SafeArea(
            child: IndexedStack(index: currentIndex, children: _pages),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: currentIndex,
            type: BottomNavigationBarType.fixed,
            onTap: (index) =>
                _viewModel.onUserIntent(RootTabSelectedIntent(index)),
            items: _items
                .map(
                  (item) => BottomNavigationBarItem(
                    icon: Icon(item.icon),
                    label: item.label,
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}
