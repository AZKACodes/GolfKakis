import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/widgets/golf_kakis_searchbar.dart';

import 'course_nearby_button.dart';

class CourseListSearchbarSection extends StatelessWidget {
  const CourseListSearchbarSection({
    required this.initialValue,
    required this.isLocationSortActive,
    required this.onSearchChanged,
    required this.onLocationTap,
    super.key,
  });

  final String initialValue;
  final bool isLocationSortActive;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onLocationTap;

  @override
  Widget build(BuildContext context) {
    return GolfKakisSearchbar(
      initialValue: initialValue,
      hintText: 'Search courses, locations, or facilities',
      onChanged: onSearchChanged,
      trailing: CourseNearbyButton(
        isActive: isLocationSortActive,
        onTap: onLocationTap,
      ),
    );
  }
}
