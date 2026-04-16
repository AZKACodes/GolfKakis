import 'package:flutter/material.dart';

import '../data/home_repository.dart';
import '../data/home_overview_models.dart';
import 'widgets/deal_card.dart';
import 'widgets/quick_action_tile.dart';

const double _bottomNavScrollClearance = 136;

class HomeView extends StatefulWidget {
  const HomeView({
    required this.onNewBookingTap,
    required this.onCoursesTap,
    required this.onMyTeeTimesTap,
    super.key,
  });

  final VoidCallback onNewBookingTap;
  final VoidCallback onCoursesTap;
  final VoidCallback onMyTeeTimesTap;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final HomeRepository _repository;
  late final Future<String> _helloMessageFuture;
  late final Future<List<HomeHotDealItem>> _hotDealsFuture;

  @override
  void initState() {
    super.initState();
    _repository = HomeRepositoryImpl();
    _helloMessageFuture = _repository.fetchWelcomeMessage();
    _hotDealsFuture = _repository.fetchHotDeals();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, _bottomNavScrollClearance),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<String>(
            future: _helloMessageFuture,
            builder: (context, snapshot) {
              return _AtAGlanceCard(
                welcomeMessage: snapshot.data ?? 'Welcome back',
              );
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
              SizedBox(width: 10),
              Expanded(
                child: QuickActionTile(
                  icon: Icons.golf_course_outlined,
                  label: 'Courses',
                  onTap: widget.onCoursesTap,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: QuickActionTile(
                  icon: Icons.receipt_long_outlined,
                  label: 'My Tee Times',
                  onTap: widget.onMyTeeTimesTap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
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

class _AtAGlanceCard extends StatelessWidget {
  const _AtAGlanceCard({required this.welcomeMessage});

  final String welcomeMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF0A1F1A), Color(0xFF1E5B4A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            welcomeMessage,
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Kinrara Golf Club • 07:30 AM',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HeroTag(text: 'Starts in 1d 9h'),
              _HeroTag(text: 'Weather 28 C'),
              _HeroTag(text: 'Condition Fast Greens'),
              _HeroTag(text: 'Check-in Opens 3h prior'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroTag extends StatelessWidget {
  const _HeroTag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
