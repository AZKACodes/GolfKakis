import 'package:flutter/material.dart';

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

    if (loadedState.isLoading && loadedState.courses.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (loadedState.errorMessage != null && loadedState.courses.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          _bottomNavScrollClearance,
        ),
        children: [
          CourseListSearchbarSection(
            initialValue: loadedState.searchQuery,
            isLocationSortActive: loadedState.isLocationSortActive,
            onSearchChanged: (value) =>
                onUserIntent(OnSearchCoursesQueryChanged(value)),
            onLocationTap: () =>
                onUserIntent(const OnSortCoursesByLocationClick()),
          ),
          const SizedBox(height: 16),
          const CourseListEmptyState(
            title: 'Unable to load courses',
            message: 'Pull to refresh and try again.',
          ),
        ],
      );
    }

    if (loadedState.courses.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          _bottomNavScrollClearance,
        ),
        children: [
          CourseListSearchbarSection(
            initialValue: loadedState.searchQuery,
            isLocationSortActive: loadedState.isLocationSortActive,
            onSearchChanged: (value) =>
                onUserIntent(OnSearchCoursesQueryChanged(value)),
            onLocationTap: () =>
                onUserIntent(const OnSortCoursesByLocationClick()),
          ),
          const SizedBox(height: 16),
          CourseListEmptyState(
            title: hasActiveSearch ? 'No matching courses' : 'No courses found',
            message: hasActiveSearch
                ? 'Try a different keyword or filter.'
                : 'Try again in a moment.',
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, _bottomNavScrollClearance),
      itemCount: loadedState.courses.length + 2,
      itemBuilder: (context, index) {
        if (index == 0) {
          return CourseListSearchbarSection(
            initialValue: loadedState.searchQuery,
            isLocationSortActive: loadedState.isLocationSortActive,
            onSearchChanged: (value) =>
                onUserIntent(OnSearchCoursesQueryChanged(value)),
            onLocationTap: () =>
                onUserIntent(const OnSortCoursesByLocationClick()),
          );
        }
        if (index == 1) {
          return const SizedBox(height: 16);
        }

        final club = loadedState.courses[index - 2];
        return Padding(
          padding: EdgeInsets.only(
            bottom: index == loadedState.courses.length + 1 ? 0 : 12,
          ),
          child: CourseListItem(
            club: club,
            onTap: () => onUserIntent(OnCourseDetailsClick(club.slug)),
          ),
        );
      },
    );
  }
}
