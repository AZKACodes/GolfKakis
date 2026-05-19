import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/enums/booking/time_period.dart';

class GolfKakisPeriodHeader extends StatelessWidget {
  const GolfKakisPeriodHeader({
    required this.selectedPeriod,
    required this.onPeriodChanged,
    super.key,
  });

  final TimePeriod selectedPeriod;
  final ValueChanged<TimePeriod> onPeriodChanged;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _GolfKakisPeriodHeaderDelegate(
        selectedPeriod: selectedPeriod,
        onPeriodChanged: onPeriodChanged,
      ),
    );
  }
}

class _GolfKakisPeriodHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _GolfKakisPeriodHeaderDelegate({
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  final TimePeriod selectedPeriod;
  final ValueChanged<TimePeriod> onPeriodChanged;

  @override
  double get minExtent => 54;

  @override
  double get maxExtent => 54;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final theme = Theme.of(context);

    return Container(
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('AM'),
            selected: selectedPeriod == TimePeriod.am,
            onSelected: (_) => onPeriodChanged(TimePeriod.am),
          ),

          const SizedBox(width: 8),

          ChoiceChip(
            label: const Text('PM'),
            selected: selectedPeriod == TimePeriod.pm,
            onSelected: (_) => onPeriodChanged(TimePeriod.pm),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _GolfKakisPeriodHeaderDelegate oldDelegate) {
    return oldDelegate.selectedPeriod != selectedPeriod ||
        oldDelegate.onPeriodChanged != onPeriodChanged;
  }
}
