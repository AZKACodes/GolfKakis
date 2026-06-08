import 'package:flutter/material.dart';
import 'package:golf_kakis/features/booking/submission/slot/view/widgets/bottomsheet/golf_club_selection_bottom_sheet.dart';
import 'package:golf_kakis/features/booking/submission/start/viewmodel/booking_submission_start_view_contract.dart';
import 'package:golf_kakis/features/booking/submission/start/viewmodel/booking_submission_start_view_model.dart';
import 'package:golf_kakis/features/foundation/model/golf_club_model.dart';
import 'package:golf_kakis/features/foundation/widgets/app_nav_bar.dart';
import 'package:golf_kakis/features/foundation/widgets/card/golf_kakis_count_selection_card.dart';
import 'package:golf_kakis/features/foundation/widgets/container/golf_kakis_loading_container.dart';

class BookingSubmissionStartView extends StatelessWidget {
  const BookingSubmissionStartView({required this.viewModel, super.key});

  final BookingSubmissionStartViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final state = viewModel.viewState;

        return switch (state) {
          BookingSubmissionStartDataLoaded() => Scaffold(
            appBar: AppNavBar(
              title: 'New Booking',
              onBackPressed: () => viewModel.onUserIntent(const OnBackClick()),
            ),
            body: state.isLoadingGolfClubs && state.golfClubList.isEmpty
                ? const Center(
                    child: GolfKakisLoadingContainer(
                      message: 'Loading golf clubs...',
                    ),
                  )
                : _BookingSubmissionStartContent(
                    state: state,
                    viewModel: viewModel,
                  ),
          ),
        };
      },
    );
  }
}

class _BookingSubmissionStartContent extends StatelessWidget {
  const _BookingSubmissionStartContent({
    required this.state,
    required this.viewModel,
  });

  final BookingSubmissionStartDataLoaded state;
  final BookingSubmissionStartViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Start your booking',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Choose a club and your group size before finding available tee times.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 24),
                _BookingSearchCard(
                  state: state,
                  onGolfClubTap: () => _openGolfClubPicker(context),
                  onPlayerCountChanged: (value) =>
                      viewModel.onUserIntent(OnStartPlayerCountChanged(value)),
                  onSearchTap: () =>
                      viewModel.onUserIntent(const OnSearchBookingSlotsClick()),
                ),
                if (state.errorMessage.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    state.errorMessage,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openGolfClubPicker(BuildContext context) async {
    await viewModel.onFetchGolfClubList();
    if (!context.mounted) {
      return;
    }
    final latestState = viewModel.currentDataState;
    GolfClubSelectionBottomSheet.show(
      context: context,
      clubs: latestState.golfClubList,
      selectedClub: latestState.selectedGolfClub,
      isNearbySortActive: latestState.isNearbySortActive,
      onNearbyTap: () =>
          viewModel.onUserIntent(const OnSortStartGolfClubsByNearbyClick()),
      onClubSelected: (club) {
        viewModel.onUserIntent(OnSelectStartGolfClub(club));
      },
    );
  }
}

class _BookingSearchCard extends StatelessWidget {
  const _BookingSearchCard({
    required this.state,
    required this.onGolfClubTap,
    required this.onPlayerCountChanged,
    required this.onSearchTap,
  });

  final BookingSubmissionStartDataLoaded state;
  final VoidCallback onGolfClubTap;
  final ValueChanged<int> onPlayerCountChanged;
  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE1E7E4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _GolfClubField(
            selectedClub: state.selectedGolfClub,
            isLoading: state.isLoadingGolfClubs,
            onTap: onGolfClubTap,
          ),
          const SizedBox(height: 14),
          GolfKakisCountSelectionCard(
            title: 'No Of Players',
            subtitle: 'Select how many players will join this booking.',
            value: state.playerCount,
            minValue: 2,
            maxValue: 6,
            onChanged: onPlayerCountChanged,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: state.canSearch ? onSearchTap : null,
              icon: const Icon(Icons.search_rounded),
              label: const Text('Search'),
            ),
          ),
        ],
      ),
    );
  }
}

class _GolfClubField extends StatelessWidget {
  const _GolfClubField({
    required this.selectedClub,
    required this.isLoading,
    required this.onTap,
  });

  final GolfClubModel? selectedClub;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final club = selectedClub;

    return Material(
      color: const Color(0xFFF8F8F6),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE1E7E4)),
          ),
          child: Row(
            children: [
              const Icon(Icons.golf_course_rounded, color: Color(0xFF0D7A3A)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Golf Club',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0A1F1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isLoading
                          ? 'Loading golf clubs...'
                          : club?.name ?? 'Select Golf Club',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: club == null ? Colors.black45 : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.keyboard_arrow_down_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
