import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/model/home/home_advertisement_view_data.dart';

class HomeAnnouncementItemCard extends StatelessWidget {
  const HomeAnnouncementItemCard({
    required this.item,
    required this.index,
    super.key,
  });

  final HomeAdvertisementViewData item;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _announcementGradients[index % _announcementGradients.length],
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
        mainAxisSize: MainAxisSize.min,
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
              Icon(
                _announcementIcons[index % _announcementIcons.length],
                color: Colors.white70,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            item.subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.88),
              height: 1.35,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.campaign_outlined, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  'View promotion',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const List<List<Color>> _announcementGradients = <List<Color>>[
  <Color>[Color(0xFF173B7A), Color(0xFF2F7BFF)],
  <Color>[Color(0xFF14532D), Color(0xFF2F855A)],
  <Color>[Color(0xFF7C2D12), Color(0xFFEA580C)],
];

const List<IconData> _announcementIcons = <IconData>[
  Icons.campaign_outlined,
  Icons.grass_outlined,
  Icons.local_offer_outlined,
];
