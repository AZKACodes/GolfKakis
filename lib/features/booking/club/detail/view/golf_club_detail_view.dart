import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/widgets/error_banner.dart';
import 'package:golf_kakis/features/foundation/widgets/info_banner.dart';

import '../viewmodel/golf_club_detail_view_contract.dart';

class GolfClubDetailView extends StatelessWidget {
  const GolfClubDetailView({
    required this.state,
    required this.onRefresh,
    required this.onBookNowClick,
    super.key,
  });

  final GolfClubDetailViewState state;
  final Future<void> Function() onRefresh;
  final VoidCallback onBookNowClick;

  @override
  Widget build(BuildContext context) {
    final detail = state.detail;
    final club = detail.club;
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          if (state.isUsingFallback) ...[
            const InfoBanner(
              message:
                  'Showing fallback golf club detail until the club detail endpoint is ready.',
            ),
            const SizedBox(height: 12),
          ],
          if (state.errorMessage != null) ...[
            ErrorBanner(message: state.errorMessage!),
            const SizedBox(height: 12),
          ],
          if (state.isLoading) ...[
            const LinearProgressIndicator(),
            const SizedBox(height: 12),
          ],
          _HeroCard(
            clubName: club.name,
            address: club.address,
            bestForLabel: detail.bestForLabel,
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Overview',
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _StatTile(
                        label: 'Distance',
                        value: detail.distanceLabel,
                        accent: const Color(0xFF1E5B4A),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatTile(
                        label: 'Green Fee',
                        value: detail.greenFeeLabel,
                        accent: const Color(0xFF2F7BFF),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _StatTile(
                        label: 'Availability',
                        value: detail.openSlotsLabel,
                        accent: const Color(0xFF2FBF71),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatTile(
                        label: 'Peak Slot',
                        value: detail.peakLabel,
                        accent: const Color(0xFFFF9F1C),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'About This Club',
            child: Text(
              detail.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Facilities',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final item in detail.facilityLabels)
                  _FacilityChip(label: item),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Course Snapshot',
            child: Row(
              children: [
                Expanded(
                  child: _SnapshotTile(
                    icon: Icons.golf_course_outlined,
                    label: 'Holes',
                    value: '${club.noOfHoles}',
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: _SnapshotTile(
                    icon: Icons.wb_sunny_outlined,
                    label: 'Best Window',
                    value: 'Morning',
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: _SnapshotTile(
                    icon: Icons.groups_outlined,
                    label: 'Pace',
                    value: 'Smooth',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onBookNowClick,
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Start Booking Here'),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.clubName,
    required this.address,
    required this.bestForLabel,
  });

  final String clubName;
  final String address;
  final String bestForLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF0A1F1A), Color(0xFF1E5B4A), Color(0xFF35C7A5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Golf Club Detail',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            clubName,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            address,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          if (bestForLabel.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                bestForLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
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
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.black54,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _SnapshotTile extends StatelessWidget {
  const _SnapshotTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF1E5B4A)),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FacilityChip extends StatelessWidget {
  const _FacilityChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6F2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1A3A32),
        ),
      ),
    );
  }
}
