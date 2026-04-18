class GolfClubModel {
  const GolfClubModel({
    required this.id,
    required this.slug,
    required this.name,
    required this.address,
    required this.noOfHoles,
    this.latitude,
    this.longitude,
    this.supportsNineHoles = false,
    this.supportedNines = const <String>[],
    this.buggyPolicy = '',
    this.paymentMethods = const <String>[],
    this.updatedAt = '',
  });

  final String id;
  final String slug;
  final String name;
  final String address;
  final int noOfHoles;
  final double? latitude;
  final double? longitude;
  final bool supportsNineHoles;
  final List<String> supportedNines;
  final String buggyPolicy;
  final List<String> paymentMethods;
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
      supportsNineHoles: _parseSupportsNineHoles(json),
      supportedNines: _parseSupportedNines(json),
      buggyPolicy: json['buggyPolicy']?.toString() ?? '',
      paymentMethods: _parsePaymentMethods(json),
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
      'supportsNineHoles': supportsNineHoles,
      'supportedNines': supportedNines,
      'buggyPolicy': buggyPolicy,
      'paymentMethods': paymentMethods,
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
    bool? supportsNineHoles,
    List<String>? supportedNines,
    String? buggyPolicy,
    List<String>? paymentMethods,
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
      supportsNineHoles: supportsNineHoles ?? this.supportsNineHoles,
      supportedNines: supportedNines ?? this.supportedNines,
      buggyPolicy: buggyPolicy ?? this.buggyPolicy,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      updatedAt: updatedAt ?? this.updatedAt,
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

  static double? _parseNullableDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '');
  }
}
