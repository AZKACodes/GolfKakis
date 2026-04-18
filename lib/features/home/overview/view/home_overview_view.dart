import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/session/session_scope.dart';
import 'package:golf_kakis/features/foundation/session/session_state.dart';

import '../data/home_overview_models.dart';
import '../data/home_repository.dart';
import 'widgets/deal_card.dart';
import 'widgets/quick_action_tile.dart';

const double _bottomNavScrollClearance = 136;

class HomeView extends StatefulWidget {
  const HomeView({
    required this.onNewBookingTap,
    required this.onCoursesTap,
    required this.onMyTeeTimesTap,
    required this.onQuickBookTap,
    super.key,
  });

  final VoidCallback onNewBookingTap;
  final VoidCallback onCoursesTap;
  final VoidCallback onMyTeeTimesTap;
  final ValueChanged<String> onQuickBookTap;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final HomeRepository _repository;
  late final Future<List<HomeHotDealItem>> _hotDealsFuture;
  late final Future<List<HomeQuickBookItem>> _quickBookFuture;
  late final PageController _announcementController;
  int _announcementPage = 0;

  @override
  void initState() {
    super.initState();
    _repository = HomeRepositoryImpl();
    _hotDealsFuture = _repository.fetchHotDeals();
    _quickBookFuture = _repository.fetchQuickBookItems();
    _announcementController = PageController(viewportFraction: 0.92);
  }

  @override
  void dispose() {
    _announcementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = SessionScope.of(context).state;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, _bottomNavScrollClearance),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AtAGlanceCard(greeting: _resolveGreeting(session)),
          const SizedBox(height: 24),
          _AnnouncementsCarousel(
            controller: _announcementController,
            currentPage: _announcementPage,
            onPageChanged: (value) {
              setState(() {
                _announcementPage = value;
              });
            },
          ),
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
                  onTap: widget.onNewBookingTap,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: QuickActionTile(
                  icon: Icons.golf_course_outlined,
                  label: 'Courses',
                  onTap: widget.onCoursesTap,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: QuickActionTile(
                  icon: Icons.receipt_long_outlined,
                  label: 'My Tee Times',
                  onTap: widget.onMyTeeTimesTap,
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
          FutureBuilder<List<HomeQuickBookItem>>(
            future: _quickBookFuture,
            builder: (context, snapshot) {
              final items = snapshot.data ?? const <HomeQuickBookItem>[];
              if (items.isEmpty) {
                return const SizedBox.shrink();
              }

              return Column(
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    _QuickBookCard(
                      item: items[i],
                      onTap: () => widget.onQuickBookTap(items[i].clubSlug),
                    ),
                    if (i != items.length - 1) const SizedBox(height: 10),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            "Today's Hot Deals",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<HomeHotDealItem>>(
            future: _hotDealsFuture,
            builder: (context, snapshot) {
              final items = snapshot.data ?? const [];
              return Column(
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    DealCard(
                      title: items[i].title,
                      subtitle: items[i].subtitle,
                      price: items[i].priceLabel,
                      badge: items[i].badge,
                    ),
                    if (i != items.length - 1) const SizedBox(height: 10),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QuickBookCard extends StatelessWidget {
  const _QuickBookCard({required this.item, required this.onTap});

  final HomeQuickBookItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE1E7E4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF6F0),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  item.badge,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF1E5B4A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                item.priceLabel,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF173B7A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            item.subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.black54,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.flash_on_outlined),
              label: const Text('Quick Book'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnnouncementsCarousel extends StatelessWidget {
  const _AnnouncementsCarousel({
    required this.controller,
    required this.currentPage,
    required this.onPageChanged,
  });

  final PageController controller;
  final int currentPage;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 176,
          child: PageView.builder(
            controller: controller,
            itemCount: _announcements.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, index) {
              final item = _announcements[index];
              final isLast = index == _announcements.length - 1;
              return Padding(
                padding: EdgeInsets.only(right: isLast ? 0 : 10),
                child: _AnnouncementCard(item: item),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List<Widget>.generate(_announcements.length, (index) {
            final isActive = index == currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 22 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF173B7A)
                    : const Color(0xFFD7DEE7),
                borderRadius: BorderRadius.circular(999),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({required this.item});

  final _AnnouncementItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: item.colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  item.tag,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              Icon(item.icon, color: Colors.white70),
            ],
          ),
          const Spacer(),
          Text(
            item.title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.88),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _AtAGlanceCard extends StatelessWidget {
  const _AtAGlanceCard({required this.greeting});

  final String greeting;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: <Color>[
            Color(0xFF0F3D2E),
            Color(0xFF1B5E4A),
            Color(0xFF2F855A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your next round starts here.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white70,
              height: 1.35,
            ),
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

class _AnnouncementItem {
  const _AnnouncementItem({
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
  });

  final String tag;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
}

const List<_AnnouncementItem> _announcements = <_AnnouncementItem>[
  _AnnouncementItem(
    tag: 'Club Notice',
    title: 'Weekend tee sheet opens earlier this Friday',
    subtitle:
        'Members can secure preferred morning slots from 6:00 PM onwards.',
    icon: Icons.event_available_outlined,
    colors: <Color>[Color(0xFF173B7A), Color(0xFF2F7BFF)],
  ),
  _AnnouncementItem(
    tag: 'Course Update',
    title: 'Kinrara greens maintenance scheduled tomorrow',
    subtitle:
        'Expect smoother front-nine play with light maintenance on selected holes.',
    icon: Icons.grass_outlined,
    colors: <Color>[Color(0xFF14532D), Color(0xFF2F855A)],
  ),
  _AnnouncementItem(
    tag: 'Promo',
    title: 'Early-bird weekday rounds now from MYR 39',
    subtitle:
        'Book selected morning sessions and lock in lower rates before noon.',
    icon: Icons.local_offer_outlined,
    colors: <Color>[Color(0xFF7C2D12), Color(0xFFEA580C)],
  ),
];
