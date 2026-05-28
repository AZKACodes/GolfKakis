import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/model/home_hot_deal_view_data.dart';
import 'package:golf_kakis/features/foundation/widgets/container/golf_kakis_shimmer_container.dart';

import '../item/home_deals_item.dart';

class HomeDealsSection extends StatelessWidget {
  const HomeDealsSection({
    required this.items,
    required this.isLoading,
    super.key,
  });

  final List<HomeHotDealViewData> items;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shouldShowLoading = isLoading && items.isEmpty;

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
        if (shouldShowLoading)
          const Column(
            children: [
              _DealLoadingCard(),
              SizedBox(height: 10),
              _DealLoadingCard(),
            ],
          )
        else
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

class _DealLoadingCard extends StatelessWidget {
  const _DealLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8E6)),
      ),
      child: const Row(
        children: [
          GolfKakisShimmerContainer(width: 96, height: 96, borderRadius: 14),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GolfKakisShimmerContainer(height: 18, borderRadius: 8),
                SizedBox(height: 10),
                GolfKakisShimmerContainer(
                  width: 180,
                  height: 12,
                  borderRadius: 6,
                ),
                SizedBox(height: 8),
                GolfKakisShimmerContainer(
                  width: 136,
                  height: 12,
                  borderRadius: 6,
                ),
                SizedBox(height: 18),
                GolfKakisShimmerContainer(
                  width: 112,
                  height: 22,
                  borderRadius: 11,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
