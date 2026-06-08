import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/widgets/container/golf_kakis_loading_container.dart';

import '../viewmodel/courses_list_view_contract.dart';
import 'widgets/course_list_item.dart';
import 'widgets/course_list_empty_state.dart';
import 'widgets/course_list_searchbar_section.dart';

const double _bottomNavScrollClearance = 136;

class CoursesListView extends StatelessWidget {
  const CoursesListView({
    required this.state,
    required this.onUserIntent,
    super.key,
  });

  final CoursesListViewState state;
  final ValueChanged<CoursesListUserIntent> onUserIntent;

  @override
  Widget build(BuildContext context) {
    final loadedState = switch (state) {
      CoursesListDataLoaded() => state as CoursesListDataLoaded,
    };
    final hasActiveSearch = loadedState.searchQuery.trim().isNotEmpty;

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
          itemCount: loadedState.courses.isEmpty
              ? 3
              : loadedState.courses.length + 2,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _CoursesListHeader(
                onBackTap: () => Navigator.of(context).maybePop(),
              );
            }
            if (index == 1) {
              return Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 22),
                child: CourseListSearchbarSection(
                  initialValue: loadedState.searchQuery,
                  isLocationSortActive: loadedState.isLocationSortActive,
                  onSearchChanged: (value) =>
                      onUserIntent(OnSearchCoursesQueryChanged(value)),
                  onLocationTap: () =>
                      onUserIntent(const OnSortCoursesByLocationClick()),
                ),
              );
            }

            if (loadedState.isLoading && loadedState.courses.isEmpty) {
              return const _CoursesListLoadingState();
            }

            if (loadedState.courses.isEmpty) {
              return CourseListEmptyState(
                title: loadedState.errorMessage != null
                    ? 'Unable to load courses'
                    : hasActiveSearch
                    ? 'No matching courses'
                    : 'No courses found',
                message: loadedState.errorMessage != null
                    ? 'Pull to refresh and try again.'
                    : hasActiveSearch
                    ? 'Try a different keyword or filter.'
                    : 'Try again in a moment.',
              );
            }

            final club = loadedState.courses[index - 2];
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == loadedState.courses.length + 1 ? 0 : 32,
              ),
              child: CourseListItem(
                club: club,
                onTap: () => onUserIntent(OnCourseDetailsClick(club.slug)),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CoursesListLoadingState extends StatelessWidget {
  const _CoursesListLoadingState();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: const Center(
        child: GolfKakisLoadingContainer(message: 'Loading courses...'),
      ),
    );
  }
}

class _CoursesListHeader extends StatelessWidget {
  const _CoursesListHeader({required this.onBackTap});

  final VoidCallback onBackTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
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
              'Courses',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
