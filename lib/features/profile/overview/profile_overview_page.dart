import 'package:flutter/material.dart';

class ProfileOverviewPage extends StatefulWidget {
  const ProfileOverviewPage({super.key});

  @override
  State<ProfileOverviewPage> createState() => _ProfileOverviewPageState();
}

class _ProfileOverviewPageState extends State<ProfileOverviewPage> {
  bool _roundReadyAlerts = true;
  bool _swingInsights = true;
  bool _autoCheckIn = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        const Positioned.fill(child: _FuturisticBackground()),
        Positioned.fill(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _ProfileHeroCard(),
                  const SizedBox(height: 16),
                  const _SectionTitle('Performance Snapshot'),
                  const SizedBox(height: 10),
                  const _PerformanceCard(),
                  const SizedBox(height: 16),
                  const _SectionTitle('Trophy Cabinet'),
                  const SizedBox(height: 10),
                  const _AchievementRow(),
                  const SizedBox(height: 16),
                  _SectionTitle(
                    'Command Center',
                    action: TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Customize'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _ControlCard(
                    title: 'Round Ready Alerts',
                    subtitle: 'Weather, tee-time, and pace notifications',
                    icon: Icons.notifications_active_outlined,
                    value: _roundReadyAlerts,
                    onChanged: (value) =>
                        setState(() => _roundReadyAlerts = value),
                  ),
                  const SizedBox(height: 10),
                  _ControlCard(
                    title: 'AI Swing Insights',
                    subtitle: 'Track trends from your recent rounds',
                    icon: Icons.insights_outlined,
                    value: _swingInsights,
                    onChanged: (value) => setState(() => _swingInsights = value),
                  ),
                  const SizedBox(height: 10),
                  _ControlCard(
                    title: 'Auto Check-In',
                    subtitle: 'Check in when arriving at your selected course',
                    icon: Icons.golf_course_outlined,
                    value: _autoCheckIn,
                    onChanged: (value) => setState(() => _autoCheckIn = value),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      backgroundColor: const Color(0xFF34F3B3),
                      foregroundColor: const Color(0xFF03251B),
                      textStyle: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                    icon: const Icon(Icons.rocket_launch_outlined),
                    label: const Text('Launch Pro Membership'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FuturisticBackground extends StatelessWidget {
  const _FuturisticBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF031514), Color(0xFF08292A), Color(0xFF091A2E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -130,
            right: -70,
            child: _GlowOrb(
              size: 280,
              color: const Color(0xFF2CFFC2).withValues(alpha: 0.20),
            ),
          ),
          Positioned(
            top: 260,
            left: -80,
            child: _GlowOrb(
              size: 220,
              color: const Color(0xFF3DB8FF).withValues(alpha: 0.16),
            ),
          ),
          Positioned(
            bottom: -120,
            right: -80,
            child: _GlowOrb(
              size: 250,
              color: const Color(0xFF58FFCF).withValues(alpha: 0.14),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard();

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF45FFD7), Color(0xFF2B8CFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: const Color(0xFFB5FFEE).withValues(alpha: 0.60),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'ZG',
                    style: TextStyle(
                      color: Color(0xFF04191B),
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Zack Green',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Quantum Member - Handicap 7.2',
                      style: TextStyle(
                        color: Color(0xFFC9F7EB),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.qr_code_2),
                color: const Color(0xFFCCFFF3),
                tooltip: 'Member QR',
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: 'Rounds',
                  value: '128',
                  tint: Color(0xFF34F3B3),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                  label: 'Fairway %',
                  value: '74',
                  suffix: '%',
                  tint: Color(0xFF6FC9FF),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                  label: 'Best',
                  value: '68',
                  tint: Color(0xFFFFD46C),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.tint,
    this.suffix = '',
  });

  final String label;
  final String value;
  final String suffix;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tint.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Text(
            '$value$suffix',
            style: TextStyle(
              color: tint,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFCCEFE5),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, {this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        const Spacer(),
        ?action,
      ],
    );
  }
}

class _PerformanceCard extends StatelessWidget {
  const _PerformanceCard();

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: const Column(
        children: [
          _PerformanceRow(
            label: 'Driving Accuracy',
            value: 0.74,
            valueLabel: '74%',
            color: Color(0xFF40F8BB),
          ),
          SizedBox(height: 12),
          _PerformanceRow(
            label: 'Greens In Regulation',
            value: 0.62,
            valueLabel: '62%',
            color: Color(0xFF5FCCFF),
          ),
          SizedBox(height: 12),
          _PerformanceRow(
            label: 'Scramble Success',
            value: 0.58,
            valueLabel: '58%',
            color: Color(0xFFFFD778),
          ),
        ],
      ),
    );
  }
}

class _PerformanceRow extends StatelessWidget {
  const _PerformanceRow({
    required this.label,
    required this.value,
    required this.valueLabel,
    required this.color,
  });

  final String label;
  final double value;
  final String valueLabel;
  final Color color;

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
                style: const TextStyle(
                  color: Color(0xFFDEFFF7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              valueLabel,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _AchievementRow extends StatelessWidget {
  const _AchievementRow();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _BadgeChip(
          icon: Icons.bolt_outlined,
          label: '3 Birdie Burst',
          tint: Color(0xFF3DF6B9),
        ),
        _BadgeChip(
          icon: Icons.flight_takeoff,
          label: '300y Drive',
          tint: Color(0xFF62CEFF),
        ),
        _BadgeChip(
          icon: Icons.flag_outlined,
          label: 'Low Round 68',
          tint: Color(0xFFFFD67A),
        ),
        _BadgeChip(
          icon: Icons.emoji_events_outlined,
          label: 'Top 5 League',
          tint: Color(0xFFFFA36C),
        ),
      ],
    );
  }
}

class _BadgeChip extends StatelessWidget {
  const _BadgeChip({
    required this.icon,
    required this.label,
    required this.tint,
  });

  final IconData icon;
  final String label;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tint.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: tint),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFE6FFF8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlCard extends StatelessWidget {
  const _ControlCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF59FFD0).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF79FFE2).withValues(alpha: 0.40),
              ),
            ),
            child: Icon(icon, color: const Color(0xFF7EFFDE)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFFBEEFE2),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF102C34).withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF7FFFE0).withValues(alpha: 0.22),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
