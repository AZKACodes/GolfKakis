import 'package:flutter/material.dart';

class HomeDealsItem extends StatelessWidget {
  const HomeDealsItem({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.badge,
    super.key,
  });

  final String title;
  final String subtitle;
  final String price;
  final String badge;

  @override
  Widget build(BuildContext context) {
    final pricing = _resolveDealPricing(price);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C2D12), Color(0xFFEA580C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
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
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
              height: 1.4,
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pricing.originalPriceLabel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
    );
  }
}

({
  String currentPriceLabel,
  String originalPriceLabel,
  String discountBadge,
}) _resolveDealPricing(String rawPriceLabel) {
  final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(rawPriceLabel);
  final amount = double.tryParse(match?.group(1) ?? '');
  if (amount == null) {
    return (
      currentPriceLabel: rawPriceLabel,
      originalPriceLabel: 'Promo pricing',
      discountBadge: _badgeFallback,
    );
  }

  final original = amount + 22;
  final savings = original - amount;
  final formattedCurrent = amount % 1 == 0
      ? amount.toInt().toString()
      : amount.toStringAsFixed(2);
  final formattedOriginal = original % 1 == 0
      ? original.toInt().toString()
      : original.toStringAsFixed(2);
  final formattedSavings = savings % 1 == 0
      ? savings.toInt().toString()
      : savings.toStringAsFixed(2);

  return (
    currentPriceLabel: 'Now MYR $formattedCurrent',
    originalPriceLabel: 'Was MYR $formattedOriginal',
    discountBadge: 'Save MYR $formattedSavings',
  );
}

const String _badgeFallback = 'Special rate';
