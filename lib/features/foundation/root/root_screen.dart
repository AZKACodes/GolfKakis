import 'package:flutter/material.dart';

import '../navigation/activity_nav_graph.dart';
import '../navigation/booking_nav_graph.dart';
import '../navigation/home_nav_graph.dart';
import '../navigation/profile_nav_graph.dart';
import '../enums/session/session_status.dart';
import '../session/session_scope.dart';
import 'nav_item.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _currentIndex = 0;

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
  Widget build(BuildContext context) {
    final sessionManager = SessionScope.of(context);
    final session = sessionManager.state;
    final sessionLabel = session.status == SessionStatus.loggedIn
        ? 'Logged in as ${session.effectiveUsername}'
        : 'Guest: ${session.effectiveUsername}';

    return Scaffold(
      appBar: AppBar(
        title: Text(_items[_currentIndex].label),
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
        child: IndexedStack(index: _currentIndex, children: _pages),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
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
  }
}
