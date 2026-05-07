import 'package:flutter/material.dart';

import '../viewmodel/courses_list_view_contract.dart';
import 'widgets/course_list_item.dart';
import 'widgets/course_list_empty_state.dart';

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
          _CourseSearchControls(
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
          _CourseSearchControls(
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
          return _CourseSearchControls(
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

class _CourseSearchControls extends StatelessWidget {
  const _CourseSearchControls({
    required this.initialValue,
    required this.isLocationSortActive,
    required this.onSearchChanged,
    required this.onLocationTap,
  });

  final String initialValue;
  final bool isLocationSortActive;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onLocationTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _CourseSearchBar(
            initialValue: initialValue,
            onChanged: onSearchChanged,
          ),
        ),
        const SizedBox(width: 12),
        _LocationSortButton(
          isActive: isLocationSortActive,
          onTap: onLocationTap,
        ),
      ],
    );
  }
}

class _CourseSearchBar extends StatefulWidget {
  const _CourseSearchBar({required this.initialValue, required this.onChanged});

  final String initialValue;
  final ValueChanged<String> onChanged;

  @override
  State<_CourseSearchBar> createState() => _CourseSearchBarState();
}

class _CourseSearchBarState extends State<_CourseSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant _CourseSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.initialValue,
        selection: TextSelection.collapsed(offset: widget.initialValue.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search courses, locations, or facilities',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE1E7E4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE1E7E4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF173B7A), width: 1.2),
        ),
      ),
    );
  }
}

class _LocationSortButton extends StatelessWidget {
  const _LocationSortButton({required this.isActive, required this.onTap});

  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? const Color(0xFF173B7A) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive
                  ? const Color(0xFF173B7A)
                  : const Color(0xFFE1E7E4),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.my_location,
                size: 18,
                color: isActive ? Colors.white : const Color(0xFF173B7A),
              ),
              const SizedBox(width: 8),
              Text(
                'Nearby',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isActive ? Colors.white : const Color(0xFF173B7A),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
