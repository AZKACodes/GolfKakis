import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/model/home_announcement_view_data.dart';

class HomeAnnouncementItemCard extends StatelessWidget {
  const HomeAnnouncementItemCard({
    required this.item,
    required this.index,
    this.onTap,
    super.key,
  });

  final HomeAnnouncementViewData item;
  final int index;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = item.imageUrl?.trim();
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (hasImage)
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _GradientAnnouncementBackground(index: index);
                    },
                  )
                else
                  _GradientAnnouncementBackground(index: index),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: hasImage
                          ? <Color>[
                              Colors.black.withValues(alpha: 0.16),
                              Colors.black.withValues(alpha: 0.58),
                            ]
                          : <Color>[
                              Colors.black.withValues(alpha: 0.04),
                              Colors.black.withValues(alpha: 0.18),
                            ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Positioned(
                  left: 18,
                  right: 18,
                  bottom: 18,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.18),
                          ),
                        ),
                        child: Text(
                          item.announcementType,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item.title,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 24,
                          height: 1.05,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (item.subtitle.trim().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          item.subtitle,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            height: 1.3,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Positioned(
                  right: 14,
                  top: 14,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Icon(
                      _announcementIcons[index % _announcementIcons.length],
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GradientAnnouncementBackground extends StatelessWidget {
  const _GradientAnnouncementBackground({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _announcementGradients[index % _announcementGradients.length],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

const List<List<Color>> _announcementGradients = <List<Color>>[
  <Color>[Color(0xFF0A1F1A), Color(0xFF2FBF71)],
  <Color>[Color(0xFF12332A), Color(0xFFC6A969)],
  <Color>[Color(0xFF1E5B4A), Color(0xFF35C7A5)],
];

const List<IconData> _announcementIcons = <IconData>[
  Icons.campaign_outlined,
  Icons.grass_outlined,
  Icons.local_offer_outlined,
];
