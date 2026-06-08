import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/widgets/container/golf_kakis_loading_container.dart';

import '../viewmodel/stay_play_view_contract.dart';
import 'widgets/stay_play_empty_state.dart';
import 'widgets/stay_play_item_card.dart';

const double _bottomNavScrollClearance = 136;

class StayPlayView extends StatelessWidget {
  const StayPlayView({
    required this.state,
    required this.onUserIntent,
    super.key,
  });

  final StayPlayViewState state;
  final ValueChanged<StayPlayUserIntent> onUserIntent;

  @override
  Widget build(BuildContext context) {
    final loadedState = switch (state) {
      StayPlayDataLoaded() => state as StayPlayDataLoaded,
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
          itemCount: loadedState.items.isEmpty
              ? 2
              : loadedState.items.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _StayPlayHeader(
                onBackTap: () => Navigator.of(context).maybePop(),
              );
            }

            if (loadedState.isLoading && loadedState.items.isEmpty) {
              return const Padding(
                padding: EdgeInsets.only(top: 84),
                child: Center(
                  child: GolfKakisLoadingContainer(
                    message: 'Loading packages...',
                  ),
                ),
              );
            }

            if (loadedState.items.isEmpty) {
              return Padding(
                padding: const EdgeInsets.only(top: 84),
                child: StayPlayEmptyState(
                  title: loadedState.errorMessage != null
                      ? 'Unable to load Stay N Play'
                      : 'No Stay N Play Available',
                  message: loadedState.errorMessage != null
                      ? 'Pull to refresh and try again.'
                      : 'Stay N Play packages will appear here once available.',
                ),
              );
            }

            final item = loadedState.items[index - 1];
            return Padding(
              padding: EdgeInsets.only(
                top: index == 1 ? 24 : 0,
                bottom: index == loadedState.items.length ? 0 : 14,
              ),
              child: StayPlayItemCard(item: item),
            );
          },
        ),
      ),
    );
  }
}

class _StayPlayHeader extends StatelessWidget {
  const _StayPlayHeader({required this.onBackTap});

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
          'Stay N Play',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
