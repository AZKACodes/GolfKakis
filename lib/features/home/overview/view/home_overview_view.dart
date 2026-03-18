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
  late final Future<List<HomeSmartRebookItem>> _smartRebookFuture;
  late final Future<List<HomeHotDealItem>> _hotDealsFuture;

  @override
  void initState() {
    super.initState();
    _repository = HomeRepositoryImpl();
    _helloMessageFuture = _repository.fetchWelcomeMessage();
    _smartRebookFuture = _repository.fetchSmartRebookItems();
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
          const SizedBox(height: 18),
          const _MomentumStrip(),
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
          const _PersonalCaddieCard(),
          const SizedBox(height: 24),
          Text(
            'Smart Rebook',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<HomeSmartRebookItem>>(
            future: _smartRebookFuture,
            builder: (context, snapshot) {
              return _SmartRebookRow(items: snapshot.data ?? const []);
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

class _MomentumStrip extends StatelessWidget {
  const _MomentumStrip();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _MomentumTile(
            label: 'Rounds This Month',
            value: '06',
            accent: Color(0xFF1E5B4A),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _MomentumTile(
            label: 'Best Score',
            value: '72',
            accent: Color(0xFF2F7BFF),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _MomentumTile(
            label: 'Active Offers',
            value: '03',
            accent: Color(0xFFFF9F1C),
          ),
        ),
      ],
    );
  }
}

class _MomentumTile extends StatelessWidget {
  const _MomentumTile({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF12332A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
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

class _SmartRebookRow extends StatelessWidget {
  const _SmartRebookRow({required this.items});

  final List<HomeSmartRebookItem> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 162,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _RebookCard(
              title: items[i].title,
              subtitle: items[i].subtitle,
              price: items[i].priceLabel,
            ),
            if (i != items.length - 1) const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }
}

class _RebookCard extends StatelessWidget {
  const _RebookCard({
    required this.title,
    required this.subtitle,
    required this.price,
  });

  final String title;
  final String subtitle;
  final String price;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.black54),
          ),
          const Spacer(),
          Row(
            children: [
              Text(
                price,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF12332A),
                ),
              ),
              const Spacer(),
              FilledButton(onPressed: () {}, child: const Text('Rebook')),
            ],
          ),
        ],
      ),
    );
  }
}

class _PersonalCaddieCard extends StatelessWidget {
  const _PersonalCaddieCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF4DD), Color(0xFFFFFBF1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFFFFE0A8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9F1C).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.assistant_outlined,
                  color: Color(0xFF9A5A00),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Personal Caddie',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TextButton(onPressed: () {}, child: const Text('Review')),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'You usually play early on weekends. Saujana and Kinrara both have sub-MYR 55 morning windows available.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.black87),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _InsightChip(label: 'Best value: Kinrara'),
              _InsightChip(label: 'Weather edge: Saturday'),
              _InsightChip(label: '2 slots almost full'),
            ],
          ),
        ],
      ),
    );
  }
}

class _InsightChip extends StatelessWidget {
  const _InsightChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFFFE0A8)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: const Color(0xFF6D4B00),
        ),
      ),
    );
  }
}
