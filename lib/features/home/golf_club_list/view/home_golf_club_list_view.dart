import 'package:flutter/material.dart';

import '../viewmodel/home_golf_club_list_view_contract.dart';
import 'widgets/home_golf_club_list_card.dart';
import 'widgets/home_golf_club_list_empty_state.dart';

const double _bottomNavScrollClearance = 136;

class HomeGolfClubListView extends StatelessWidget {
  const HomeGolfClubListView({
    required this.state,
    required this.onUserIntent,
    super.key,
  });

  final HomeGolfClubListViewState state;
  final ValueChanged<HomeGolfClubListUserIntent> onUserIntent;

  @override
  Widget build(BuildContext context) {
    final loadedState = switch (state) {
      HomeGolfClubListDataLoaded() => state as HomeGolfClubListDataLoaded,
    };

    if (loadedState.isLoading && loadedState.golfClubList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (loadedState.errorMessage != null && loadedState.golfClubList.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          16,
          32,
          16,
          _bottomNavScrollClearance,
        ),
        children: const [
          HomeGolfClubListEmptyState(
            title: 'Unable to load golf clubs',
            message: 'Pull to refresh and try again.',
          ),
        ],
      );
    }

    if (loadedState.golfClubList.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          16,
          32,
          16,
          _bottomNavScrollClearance,
        ),
        children: const [
          HomeGolfClubListEmptyState(
            title: 'No golf clubs found',
            message: 'Try again in a moment.',
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, _bottomNavScrollClearance),
      itemCount: loadedState.golfClubList.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final club = loadedState.golfClubList[index];
        return HomeGolfClubListCard(
          club: club,
          onTap: () => onUserIntent(OnGolfClubDetailClick(club)),
        );
      },
    );
  }
}
