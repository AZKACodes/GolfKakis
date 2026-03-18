import 'package:flutter/material.dart';
import 'dart:async';

import '../navigation/booking_nav_graph.dart';
import '../navigation/home_nav_graph.dart';
import '../navigation/profile_nav_graph.dart';
import 'nav_item.dart';
import 'viewmodel/root_view_contract.dart';
import 'viewmodel/root_view_model.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  static const double _navHorizontalInset = 16;
  static const double _navBottomGap = 14;

  late final RootViewModel _viewModel;
  StreamSubscription<RootNavEffect>? _navEffectSubscription;

  static const List<NavItem> _items = [
    NavItem(label: 'Home', icon: Icons.home_outlined),
    NavItem(label: 'Booking', icon: Icons.event_outlined),
    NavItem(label: 'Profile', icon: Icons.person_outline),
  ];

  static const List<Widget> _pages = [
    HomeNavGraph(),
    BookingNavGraph(),
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
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final currentIndex = _viewModel.viewState.currentIndex;
        final bottomInset = MediaQuery.of(context).padding.bottom;

        return Scaffold(
          extendBody: true,
          body: Stack(
            children: [
              SafeArea(
                bottom: false,
                child: IndexedStack(index: currentIndex, children: _pages),
              ),
              Positioned(
                left: _navHorizontalInset,
                right: _navHorizontalInset,
                bottom: bottomInset + _navBottomGap,
                child: _FloatingNavBar(
                  items: _items,
                  currentIndex: currentIndex,
                  onTap: (index) =>
                      _viewModel.onUserIntent(RootTabSelectedIntent(index)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.black12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 24,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: List<Widget>.generate(items.length, (index) {
            final item = items[index];
            final isSelected = index == currentIndex;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () => onTap(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF173B7A)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF5A6473),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF5A6473),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
