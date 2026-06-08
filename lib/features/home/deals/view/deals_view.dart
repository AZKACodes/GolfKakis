import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/widgets/container/golf_kakis_loading_container.dart';

import '../../overview/view/widgets/item/home_deals_item.dart';
import '../viewmodel/deals_view_contract.dart';
import 'widgets/deals_empty_state.dart';

const double _bottomNavScrollClearance = 136;

class DealsView extends StatelessWidget {
  const DealsView({required this.state, required this.onUserIntent, super.key});

  final DealsViewState state;
  final ValueChanged<DealsUserIntent> onUserIntent;

  @override
  Widget build(BuildContext context) {
    final loadedState = switch (state) {
      DealsDataLoaded() => state as DealsDataLoaded,
    };

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(46)),
      child: ColoredBox(
        color: Colors.white,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            22,
            MediaQuery.paddingOf(context).top + 8,
            22,
            _bottomNavScrollClearance,
          ),
          itemCount: loadedState.deals.isEmpty
              ? 2
              : loadedState.deals.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _DealsHeader(
                onBackTap: () => Navigator.of(context).maybePop(),
              );
            }

            if (loadedState.isLoading && loadedState.deals.isEmpty) {
              return const Padding(
                padding: EdgeInsets.only(top: 84),
                child: Center(
                  child: GolfKakisLoadingContainer(message: 'Loading deals...'),
                ),
              );
            }

            if (loadedState.deals.isEmpty) {
              return Padding(
                padding: const EdgeInsets.only(top: 84),
                child: DealsEmptyState(
                  title: loadedState.errorMessage != null
                      ? 'Unable to load deals'
                      : 'No Deals Available',
                  message: loadedState.errorMessage != null
                      ? 'Pull to refresh and try again.'
                      : 'New promotions will appear here once available.',
                ),
              );
            }

            final deal = loadedState.deals[index - 1];
            return Padding(
              padding: EdgeInsets.only(
                top: index == 1 ? 24 : 0,
                bottom: index == loadedState.deals.length ? 0 : 14,
              ),
              child: HomeDealsItem(
                dealId: deal.dealId,
                slotId: deal.slotId,
                title: deal.title,
                description: deal.description,
                price: deal.price,
                discountedPrice: deal.discountedPrice,
                currency: deal.currency,
                golfClubSlug: deal.golfClubSlug,
                slotDate: deal.slotDate,
                slotTime: deal.slotTime,
                noOfHoles: deal.noOfHoles,
                imageUrl: deal.imageUrl,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DealsHeader extends StatelessWidget {
  const _DealsHeader({required this.onBackTap});

  final VoidCallback onBackTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            onPressed: onBackTap,
            icon: const Icon(Icons.chevron_left_rounded, size: 34),
          ),
        ),
        Text(
          'Deals',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
