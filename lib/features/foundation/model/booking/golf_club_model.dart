class GolfClubModel {
  const GolfClubModel({
    required this.id,
    required this.slug,
    required this.name,
    required this.address,
    required this.noOfHoles,
    this.latitude,
    this.longitude,
    this.isEnabled = false,
    this.supportsNineHoles = false,
    this.supportedNines = const <String>[],
    this.buggyPolicy = '',
    this.paymentMethods = const <String>[],
    this.facilities = const <GolfClubFacilityModel>[],
    this.updatedAt = '',
  });

  final String id;
  final String slug;
  final String name;
  final String address;
  final int noOfHoles;
  final double? latitude;
  final double? longitude;
  final bool isEnabled;
  final bool supportsNineHoles;
  final List<String> supportedNines;
  final String buggyPolicy;
  final List<String> paymentMethods;
  final List<GolfClubFacilityModel> facilities;
  final String updatedAt;

  factory GolfClubModel.fromJson(Map<String, dynamic> json) {
    return GolfClubModel(
      id: json['id']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      noOfHoles: _parseHoleCount(json),
      latitude: _parseNullableDouble(json['latitude'] ?? json['lat']),
      longitude: _parseNullableDouble(json['longitude'] ?? json['lng']),
      isEnabled: _parseIsEnabled(json),
      supportsNineHoles: _parseSupportsNineHoles(json),
      supportedNines: _parseSupportedNines(json),
      buggyPolicy: json['buggyPolicy']?.toString() ?? '',
      paymentMethods: _parsePaymentMethods(json),
      facilities: _parseFacilities(json),
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'slug': slug,
      'name': name,
      'address': address,
      'noOfHoles': noOfHoles,
      'latitude': latitude,
      'longitude': longitude,
      'isEnabled': isEnabled,
      'supportsNineHoles': supportsNineHoles,
      'supportedNines': supportedNines,
      'buggyPolicy': buggyPolicy,
      'paymentMethods': paymentMethods,
      'facilities': facilities.map((item) => item.toJson()).toList(),
      'updatedAt': updatedAt,
    };
  }

  GolfClubModel copyWith({
    String? id,
    String? slug,
    String? name,
    String? address,
    int? noOfHoles,
    double? latitude,
    double? longitude,
    bool? isEnabled,
    bool? supportsNineHoles,
    List<String>? supportedNines,
    String? buggyPolicy,
    List<String>? paymentMethods,
    List<GolfClubFacilityModel>? facilities,
    String? updatedAt,
  }) {
    return GolfClubModel(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      name: name ?? this.name,
      address: address ?? this.address,
      noOfHoles: noOfHoles ?? this.noOfHoles,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isEnabled: isEnabled ?? this.isEnabled,
      supportsNineHoles: supportsNineHoles ?? this.supportsNineHoles,
      supportedNines: supportedNines ?? this.supportedNines,
      buggyPolicy: buggyPolicy ?? this.buggyPolicy,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      facilities: facilities ?? this.facilities,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static List<GolfClubFacilityModel> _parseFacilities(Map<String, dynamic> json) {
    final dynamic value = json['facilities'];

    if (value is List) {
      return value
          .whereType<Map<String, dynamic>>()
          .map(GolfClubFacilityModel.fromJson)
          .where((item) => item.facilityType.isNotEmpty || item.title.isNotEmpty)
          .toList();
    }

    return const <GolfClubFacilityModel>[];
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

  static List<String> _parsePaymentMethods(Map<String, dynamic> json) {
    final dynamic value = json['paymentMethods'] ?? json['payment_methods'];

    if (value is List) {
      return value
          .map((item) => item?.toString() ?? '')
          .where((item) => item.isNotEmpty)
          .toList();
    }

    return const <String>[];
  }

  static bool _parseSupportsNineHoles(Map<String, dynamic> json) {
    final dynamic value =
        json['supportsNineHoles'] ?? json['supports_nine_holes'];
    if (value is bool) {
      return value;
    }
    return value?.toString().toLowerCase() == 'true';
  }

  static bool _parseIsEnabled(Map<String, dynamic> json) {
    final dynamic value = json['isEnabled'] ?? json['is_enabled'];
    if (value is bool) {
      return value;
    }
    if (value != null) {
      return value.toString().toLowerCase() == 'true';
    }

    final slug = json['slug']?.toString().trim().toLowerCase() ?? '';
    final name = json['name']?.toString().trim().toLowerCase() ?? '';
    return slug == 'kinrara-golf-club' || name == 'kinrara golf club';
  }

  static double? _parseNullableDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '');
  }
}

class GolfClubFacilityModel {
  const GolfClubFacilityModel({
    required this.facilityType,
    required this.title,
  });

  final String facilityType;
  final String title;

  factory GolfClubFacilityModel.fromJson(Map<String, dynamic> json) {
    return GolfClubFacilityModel(
      facilityType:
          json['facility_type']?.toString() ??
          json['facilityType']?.toString() ??
          '',
      title: json['title']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'facility_type': facilityType,
      'title': title,
    };
  }
}
