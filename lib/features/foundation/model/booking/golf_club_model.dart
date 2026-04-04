class GolfClubModel {
  const GolfClubModel({
    required this.id,
    required this.slug,
    required this.name,
    required this.address,
    required this.noOfHoles,
    this.supportedNines = const <String>[],
  });

  final String id;
  final String slug;
  final String name;
  final String address;
  final int noOfHoles;
  final List<String> supportedNines;

  factory GolfClubModel.fromJson(Map<String, dynamic> json) {
    return GolfClubModel(
      id: json['id']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      noOfHoles: _parseHoleCount(json),
      supportedNines: _parseSupportedNines(json),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'slug': slug,
      'name': name,
      'address': address,
      'noOfHoles': noOfHoles,
      'supportedNines': supportedNines,
    };
  }

  GolfClubModel copyWith({
    String? id,
    String? slug,
    String? name,
    String? address,
    int? noOfHoles,
    List<String>? supportedNines,
  }) {
    return GolfClubModel(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      name: name ?? this.name,
      address: address ?? this.address,
      noOfHoles: noOfHoles ?? this.noOfHoles,
      supportedNines: supportedNines ?? this.supportedNines,
    );
  }

  static int _parseHoleCount(Map<String, dynamic> json) {
    final dynamic value =
        json['noOfHoles'] ?? json['no_of_holes'] ?? json['holes'];

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static List<String> _parseSupportedNines(Map<String, dynamic> json) {
    final dynamic value = json['supportedNines'] ?? json['supported_nines'];

    if (value is List) {
      return value
          .map((item) => item?.toString() ?? '')
          .where((item) => item.isNotEmpty)
          .toList();
    }

    return const <String>[];
  }
}
