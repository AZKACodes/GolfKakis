class LocalGolfClubDisplayContent {
  const LocalGolfClubDisplayContent({
    required this.summary,
    required this.facilities,
    required this.photoUrls,
    required this.latitude,
    required this.longitude,
  });

  final String summary;
  final List<String> facilities;
  final List<String> photoUrls;
  final double latitude;
  final double longitude;
}

const Map<String, LocalGolfClubDisplayContent>
localCourseDisplayContent = <String, LocalGolfClubDisplayContent>{
  'kinrara-golf-club': LocalGolfClubDisplayContent(
    summary:
        'Kinrara Golf Club is a well-established golf destination located in Puchong, Malaysia, offering a scenic and challenging 18-hole championship course. Surrounded by lush greenery and natural lakes, the course provides an enjoyable experience for golfers of all skill levels. Known for its well-maintained fairways and welcoming atmosphere, Kinrara Golf Club is a popular choice for both casual rounds and competitive play.',
    facilities: <String>[
      '18-hole championship golf course',
      'Driving range',
      'Practice putting green',
      'Golf pro shop',
      'Locker rooms & shower facilities',
      'Restaurant & cafe',
      'Function / event rooms',
      'Buggy & equipment rental',
      'Golf coaching / academy',
    ],
    photoUrls: <String>[
      'https://images.unsplash.com/photo-1535131749006-b7f58c99034b?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1517466787929-bc90951d0974?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1592919505780-303950717480?auto=format&fit=crop&w=1200&q=80',
    ],
    latitude: 3.04703,
    longitude: 101.64744,
  ),
};
