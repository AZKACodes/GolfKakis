import 'package:flutter/material.dart';

class HomeDealsItem extends StatelessWidget {
  const HomeDealsItem({
    required this.dealId,
    required this.slotId,
    required this.title,
    required this.description,
    required this.price,
    required this.discountedPrice,
    required this.currency,
    required this.golfClubSlug,
    required this.slotDate,
    required this.slotTime,
    required this.noOfHoles,
    this.imageUrl,
    super.key,
  });

  final String dealId;
  final String slotId;
  final String title;
  final String description;
  final num price;
  final num discountedPrice;
  final String currency;
  final String golfClubSlug;
  final String slotDate;
  final String slotTime;
  final int noOfHoles;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final pricing = _resolveDealPricing(
      price: price,
      discountedPrice: discountedPrice,
      currency: currency,
    );
    final formattedDate = _formatSlotDate(slotDate);
    final bannerUrl = imageUrl?.trim();
    final hasImage = bannerUrl != null && bannerUrl.isNotEmpty;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            Positioned.fill(
              child: hasImage
                  ? Image.network(
                      bannerUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const _DealGradientBackground();
                      },
                    )
                  : const _DealGradientBackground(),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: hasImage
                        ? <Color>[
                            Colors.black.withValues(alpha: 0.18),
                            Colors.black.withValues(alpha: 0.68),
                          ]
                        : <Color>[
                            Colors.white.withValues(alpha: 0.0),
                            Colors.black.withValues(alpha: 0.14),
                          ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
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
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                        child: Text(
                          pricing.discountBadge,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.local_fire_department_outlined,
                        color: Colors.white70,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                  if (formattedDate != null)
                    Text(
                      formattedDate,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.74),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {},
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF7C2D12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          icon: const Icon(Icons.arrow_outward_rounded, size: 18),
                          label: const Text('Book Now'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            pricing.currentPriceLabel,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            pricing.originalPriceLabel,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Colors.white70,
                                  decoration: TextDecoration.lineThrough,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
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

({
  String currentPriceLabel,
  String originalPriceLabel,
  String discountBadge,
}) _resolveDealPricing({
  required num price,
  required num discountedPrice,
  required String currency,
}) {
  final safeOriginal = price <= 0 ? discountedPrice : price;
  final safeDiscounted = discountedPrice <= 0 ? safeOriginal : discountedPrice;
  final savings = safeOriginal - safeDiscounted;
  final currencyPrefix = currency.toUpperCase();

  if (safeOriginal <= 0 && safeDiscounted <= 0) {
    return (
      currentPriceLabel: currencyPrefix,
      originalPriceLabel: 'Promo pricing',
      discountBadge: _badgeFallback,
    );
  }

  final formattedCurrent = _formatAmount(safeDiscounted);
  final formattedOriginal = _formatAmount(safeOriginal);
  final formattedSavings = _formatAmount(savings <= 0 ? 0 : savings);

  return (
    currentPriceLabel: 'Now $currencyPrefix $formattedCurrent',
    originalPriceLabel: 'Was $currencyPrefix $formattedOriginal',
    discountBadge: savings > 0
        ? 'Save $currencyPrefix $formattedSavings'
        : _badgeFallback,
  );
}

String _formatAmount(num value) {
  return value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(2);
}

String? _formatSlotDate(String rawDate) {
  final trimmed = rawDate.trim();
  if (trimmed.isEmpty) {
    return null;
  }

  final parsed = DateTime.tryParse(trimmed);
  if (parsed == null) {
    return trimmed;
  }

  return '${parsed.day} ${_monthNames[parsed.month - 1]} ${parsed.year}';
}

const String _badgeFallback = 'Special rate';

const List<String> _monthNames = <String>[
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

class _DealGradientBackground extends StatelessWidget {
  const _DealGradientBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7C2D12), Color(0xFFEA580C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}
