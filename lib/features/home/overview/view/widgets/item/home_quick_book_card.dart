import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/model/home/home_quick_book_view_data.dart';

class HomeQuickBookCard extends StatelessWidget {
  const HomeQuickBookCard({required this.item, required this.onTap, super.key});

  final HomeQuickBookViewData item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pricing = _resolvePricing(item.priceLabel);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE1E7E4)),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF6F0),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  item.badge,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF1E5B4A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1D6),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  pricing.discountLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF9A3412),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            item.subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.black54,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                pricing.currentPriceLabel,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF173B7A),
                ),
              ),
              Text(
                pricing.originalPriceLabel,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black45,
                  decoration: TextDecoration.lineThrough,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.flash_on_outlined),
              label: const Text('Quick Book'),
            ),
          ),
        ],
      ),
    );
  }
}

({String currentPriceLabel, String originalPriceLabel, String discountLabel})
_resolvePricing(String rawPriceLabel) {
  final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(rawPriceLabel);
  final amount = double.tryParse(match?.group(1) ?? '');
  if (amount == null) {
    return (
      currentPriceLabel: rawPriceLabel,
      originalPriceLabel: 'Limited pricing',
      discountLabel: 'Featured rate',
    );
  }

  final original = amount + 18;
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
    discountLabel: 'Save MYR $formattedSavings',
  );
}
