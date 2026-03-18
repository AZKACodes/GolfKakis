class GolfClubModel {
  const GolfClubModel({
    required this.id,
    required this.slug,
    required this.name,
    required this.address,
    required this.noOfHoles,
  });

  final String id;
  final String slug;
  final String name;
  final String address;
  final int noOfHoles;

  factory GolfClubModel.fromJson(Map<String, dynamic> json) {
    return GolfClubModel(
      id: json['id']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      noOfHoles: _parseHoleCount(json),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'slug': slug,
      'name': name,
      'address': address,
      'noOfHoles': noOfHoles,
    };
  }

  GolfClubModel copyWith({
    String? id,
    String? slug,
    String? name,
    String? address,
    int? noOfHoles,
  }) {
    return GolfClubModel(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      name: name ?? this.name,
      address: address ?? this.address,
      noOfHoles: noOfHoles ?? this.noOfHoles,
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
}
