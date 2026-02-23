import 'package:flutter/material.dart';

import '../data/home_repository.dart';
import 'widgets/deal_card.dart';
import 'widgets/quick_action_tile.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final Future<String> _helloMessageFuture;

  @override
  void initState() {
    super.initState();
    _helloMessageFuture = HomeRepositoryImpl().fetchWelcomeMessage();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _AtAGlanceCard(),
          const SizedBox(height: 24),
          Text(
            'Quick Actions',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(
                child: QuickActionTile(
                  icon: Icons.add_box_outlined,
                  label: 'New Booking',
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: QuickActionTile(
                  icon: Icons.golf_course_outlined,
                  label: 'Courses',
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: QuickActionTile(
                  icon: Icons.receipt_long_outlined,
                  label: 'My Tee Times',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Smart Rebook',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          const _SmartRebookRow(),
          const SizedBox(height: 24),
          Text(
            'Action Queue',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          const _ActionQueueCard(),
          const SizedBox(height: 24),
          Text(
            'Progress Strip',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          const _ProgressStripCard(),
          const SizedBox(height: 24),
          Text(
            "Today's Hot Deals",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          const DealCard(
            title: 'Sunrise Tee Time',
            subtitle: 'Green Valley Golf Club',
            price: '\$49',
            badge: 'Hot',
          ),
          const SizedBox(height: 10),
          const DealCard(
            title: 'Weekend Pair Deal',
            subtitle: '2 players at Harbor Links',
            price: '\$89',
            badge: 'Top',
          ),
        ],
      ),
    );
  }
}

class _AtAGlanceCard extends StatelessWidget {
  const _AtAGlanceCard();

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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today at a Glance',
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

class _SmartRebookRow extends StatelessWidget {
  const _SmartRebookRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 162,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: const [
          _RebookCard(
            title: 'Saujana G&CC',
            subtitle: 'Last played Tue, 07:20 AM',
            price: 'From \$52',
          ),
          SizedBox(width: 10),
          _RebookCard(
            title: 'Kinrara Golf Club',
            subtitle: 'Last played Sat, 07:30 AM',
            price: 'From \$39',
          ),
          SizedBox(width: 10),
          _RebookCard(
            title: 'Kota Permai',
            subtitle: 'Last played Fri, 08:10 AM',
            price: 'From \$47',
          ),
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

class _ActionQueueCard extends StatelessWidget {
  const _ActionQueueCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: const Column(
        children: [
          _ActionRow(
            title: 'Pending deposit',
            subtitle: 'Mines Resort - USD 18 due today',
            action: 'Pay',
          ),
          Divider(height: 18),
          _ActionRow(
            title: 'Confirm pairing',
            subtitle: 'Kinrara - add 1 player before 9 PM',
            action: 'Confirm',
          ),
          Divider(height: 18),
          _ActionRow(
            title: 'Promo expiring',
            subtitle: 'Morning Saver ends in 14h',
            action: 'Use Now',
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.title,
    required this.subtitle,
    required this.action,
  });

  final String title;
  final String subtitle;
  final String action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(color: Colors.black54)),
            ],
          ),
        ),
        TextButton(onPressed: () {}, child: Text(action)),
      ],
    );
  }
}

class _ProgressStripCard extends StatelessWidget {
  const _ProgressStripCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: const Column(
        children: [
          _ProgressRow(
            label: 'Handicap Trend',
            value: '7.8 -> 7.2',
            progress: 0.82,
          ),
          SizedBox(height: 10),
          _ProgressRow(
            label: 'Last 5 Scores Avg',
            value: '74.6',
            progress: 0.74,
          ),
          SizedBox(height: 10),
          _ProgressRow(
            label: 'Weekly Fairway Goal (>70%)',
            value: '68%',
            progress: 0.68,
          ),
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.label,
    required this.value,
    required this.progress,
  });

  final String label;
  final String value;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF12332A),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Color(0xFFE7EFEB),
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2FBF71)),
          ),
        ),
      ],
    );
  }
}
