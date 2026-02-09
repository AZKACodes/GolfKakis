import 'package:flutter/material.dart';

import '../../features/activity/activity_page.dart';
import '../../features/booking/booking_page.dart';
import '../../features/home/home_page.dart';
import '../../features/profile/profile_page.dart';
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
    HomePage(),
    BookingPage(),
    ActivityPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_items[_currentIndex].label),
      ),
      body: SafeArea(child: _pages[_currentIndex]),
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
