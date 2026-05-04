import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/model/home/home_hot_deal_view_data.dart';

import '../item/home_deals_item.dart';

class HomeDealsSection extends StatelessWidget {
  const HomeDealsSection({required this.items, super.key});

  final List<HomeHotDealViewData> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Deals & Deductions',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              HomeDealsItem(
                title: items[i].title,
                subtitle: items[i].subtitle,
                price: items[i].priceLabel,
                badge: items[i].badge,
              ),
              if (i != items.length - 1) const SizedBox(height: 10),
            ],
          ],
        ),
      ],
    );
  }
}
