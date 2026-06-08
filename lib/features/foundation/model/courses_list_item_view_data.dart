class CoursesListItemViewData {
  const CoursesListItemViewData({
    required this.slug,
    required this.name,
    required this.address,
    required this.holesLabel,
    required this.facilities,
    required this.isEnabled,
    this.distanceLabel,
    this.coverPhotoUrl,
  });

  final String slug;
  final String name;
  final String address;
  final String holesLabel;
  final List<CoursesListFacilityItemViewData> facilities;
  final bool isEnabled;
  final String? distanceLabel;
  final String? coverPhotoUrl;
}

class CoursesListFacilityItemViewData {
  const CoursesListFacilityItemViewData({
    required this.facilityType,
    required this.title,
  });

  final String facilityType;
  final String title;
}
