import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/model/home_hot_deal_view_data.dart';

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
          "Today's Hot Deals",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              HomeDealsItem(
                dealId: items[i].dealId,
                slotId: items[i].slotId,
                title: items[i].title,
                description: items[i].description,
                price: items[i].price,
                discountedPrice: items[i].discountedPrice,
                currency: items[i].currency,
                golfClubSlug: items[i].golfClubSlug,
                slotDate: items[i].slotDate,
                slotTime: items[i].slotTime,
                noOfHoles: items[i].noOfHoles,
                imageUrl: items[i].imageUrl,
              ),
              if (i != items.length - 1) const SizedBox(height: 10),
            ],
          ],
        ),
      ],
    );
  }
}
