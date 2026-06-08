import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/model/stay_play_view_data.dart';

class StayPlayItemCard extends StatelessWidget {
  const StayPlayItemCard({required this.item, super.key});

  final StayPlayViewData item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = item.imageUrl?.trim();
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;
    final location = item.location?.trim();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE1E7E4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: hasImage
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const _StayPlayImagePlaceholder();
                      },
                    )
                  : const _StayPlayImagePlaceholder(),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (location != null && location.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.place_outlined,
                          size: 16,
                          color: Color(0xFF1E5B4A),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            location,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (item.description.trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      item.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _formatPrice(item.currency, item.price),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: const Color(0xFF0A1F1A),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      FilledButton(onPressed: () {}, child: const Text('View')),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StayPlayImagePlaceholder extends StatelessWidget {
  const _StayPlayImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[Color(0xFF0A1F1A), Color(0xFF2FBF71)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(Icons.hotel_outlined, color: Colors.white, size: 42),
      ),
    );
  }
}

String _formatPrice(String currency, num price) {
  if (price <= 0) {
    return 'Package pricing';
  }

  final amount = price % 1 == 0
      ? price.toInt().toString()
      : price.toStringAsFixed(2);
  return 'From ${currency.toUpperCase()} $amount';
}
