import 'package:golf_kakis/features/foundation/network/api_config.dart';

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
    this.isBookable = false,
    this.availabilityLabel = '',
    this.supportsNineHoles = false,
    this.supportedNines = const <String>[],
    this.buggyPolicy = '',
    this.paymentMethods = const <String>[],
    this.facilities = const <GolfClubFacilityModel>[],
    this.imageUrls = const <String>[],
    this.galleryImageUrls = const <String>[],
    this.coverPhotoUrl,
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
  final bool isBookable;
  final String availabilityLabel;
  final bool supportsNineHoles;
  final List<String> supportedNines;
  final String buggyPolicy;
  final List<String> paymentMethods;
  final List<GolfClubFacilityModel> facilities;
  final List<String> imageUrls;
  final List<String> galleryImageUrls;
  final String? coverPhotoUrl;
  final String updatedAt;

  factory GolfClubModel.fromJson(Map<String, dynamic> json) {
    final imageUrls = _parseImageUrls(json);
    final galleryImageUrls = _parseGalleryImageUrls(json);

    return GolfClubModel(
      id: json['id']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      noOfHoles: _parseHoleCount(json),
      latitude: _parseNullableDouble(json['latitude'] ?? json['lat']),
      longitude: _parseNullableDouble(json['longitude'] ?? json['lng']),
      isEnabled: _parseIsEnabled(json),
      isBookable: _parseIsBookable(json),
      availabilityLabel: json['availabilityLabel']?.toString() ?? '',
      supportsNineHoles: _parseSupportsNineHoles(json),
      supportedNines: _parseSupportedNines(json),
      buggyPolicy: json['buggyPolicy']?.toString() ?? '',
      paymentMethods: _parsePaymentMethods(json),
      facilities: _parseFacilities(json),
      imageUrls: imageUrls,
      galleryImageUrls: galleryImageUrls,
      coverPhotoUrl: _parseCoverPhotoUrl(json, imageUrls),
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
      'isBookable': isBookable,
      'availabilityLabel': availabilityLabel,
      'supportsNineHoles': supportsNineHoles,
      'supportedNines': supportedNines,
      'buggyPolicy': buggyPolicy,
      'paymentMethods': paymentMethods,
      'facilities': facilities.map((item) => item.toJson()).toList(),
      'imageUrls': imageUrls,
      'galleryImageUrls': galleryImageUrls,
      'coverPhotoUrl': coverPhotoUrl,
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
    bool? isBookable,
    String? availabilityLabel,
    bool? supportsNineHoles,
    List<String>? supportedNines,
    String? buggyPolicy,
    List<String>? paymentMethods,
    List<GolfClubFacilityModel>? facilities,
    List<String>? imageUrls,
    List<String>? galleryImageUrls,
    String? coverPhotoUrl,
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
      isBookable: isBookable ?? this.isBookable,
      availabilityLabel: availabilityLabel ?? this.availabilityLabel,
      supportsNineHoles: supportsNineHoles ?? this.supportsNineHoles,
      supportedNines: supportedNines ?? this.supportedNines,
      buggyPolicy: buggyPolicy ?? this.buggyPolicy,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      facilities: facilities ?? this.facilities,
      imageUrls: imageUrls ?? this.imageUrls,
      galleryImageUrls: galleryImageUrls ?? this.galleryImageUrls,
      coverPhotoUrl: coverPhotoUrl ?? this.coverPhotoUrl,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static String? _parseCoverPhotoUrl(
    Map<String, dynamic> json,
    List<String> imageUrls,
  ) {
    final value =
        json['coverPhotoUrl'] ??
        json['cover_photo_url'] ??
        json['coverPhoto'] ??
        json['cover_photo'] ??
        json['coverImageUrl'] ??
        json['cover_image_url'] ??
        json['coverImage'] ??
        json['cover_image'] ??
        json['imageUrl'] ??
        json['image_url'] ??
        json['image'];
    final explicitUrls = <String>[];
    _appendImageUrls(explicitUrls, value);
    final text = explicitUrls.isEmpty ? '' : explicitUrls.first;
    if (text.isNotEmpty) {
      return _normalizeImageUrl(text);
    }
    return imageUrls.isEmpty ? null : imageUrls.first;
  }

  static List<String> _parseImageUrls(Map<String, dynamic> json) {
    final candidates = <dynamic>[
      json['imageUrls'],
      json['image_urls'],
      json['images'],
      json['photos'],
      json['gallery'],
      json['media'],
      json['coverPhotoUrl'],
      json['cover_photo_url'],
      json['coverPhoto'],
      json['cover_photo'],
      json['coverImageUrl'],
      json['cover_image_url'],
      json['coverImage'],
      json['cover_image'],
      json['imageUrl'],
      json['image_url'],
      json['image'],
      json['photo'],
    ];

    final urls = <String>[];
    for (final candidate in candidates) {
      _appendImageUrls(urls, candidate);
    }

    return urls.toSet().toList();
  }

  static List<String> _parseGalleryImageUrls(Map<String, dynamic> json) {
    final images = json['images'];
    final candidates = <dynamic>[
      if (images is Map<String, dynamic>) images['gallery'],
      if (images is Map)
        images.map((key, item) => MapEntry(key.toString(), item))['gallery'],
      json['gallery'],
    ];

    final urls = <String>[];
    for (final candidate in candidates) {
      _appendImageUrls(urls, candidate);
    }

    return urls.toSet().toList();
  }

  static void _appendImageUrls(List<String> urls, dynamic value) {
    if (value == null) {
      return;
    }

    if (value is List) {
      for (final item in value) {
        _appendImageUrls(urls, item);
      }
      return;
    }

    if (value is Map<String, dynamic>) {
      final nestedValue =
          value['url'] ??
          value['imageUrl'] ??
          value['image_url'] ??
          value['src'] ??
          value['path'] ??
          value['location'];
      if (nestedValue != null) {
        _appendImageUrls(urls, nestedValue);
        return;
      }

      final imageValues = <dynamic>[
        value['cover'],
        value['thumbnail'],
        value['logo'],
        value['gallery'],
        value['images'],
        value['photos'],
      ];
      for (final item in imageValues) {
        _appendImageUrls(urls, item);
      }
      return;
    }

    if (value is Map) {
      _appendImageUrls(
        urls,
        value.map((key, item) => MapEntry(key.toString(), item)),
      );
      return;
    }

    final text = value.toString().trim();
    if (text.isNotEmpty) {
      urls.add(_normalizeImageUrl(text));
    }
  }

  static String _normalizeImageUrl(String url) {
    final text = url.trim();
    if (text.startsWith('//')) {
      return 'https:$text';
    }
    final uri = Uri.tryParse(text);
    if (uri != null && uri.hasScheme) {
      return text;
    }

    final baseUrl = ApiConfig.baseUrl.endsWith('/')
        ? ApiConfig.baseUrl
        : '${ApiConfig.baseUrl}/';
    return Uri.parse(baseUrl).resolve(text).toString();
  }

  static List<GolfClubFacilityModel> _parseFacilities(
    Map<String, dynamic> json,
  ) {
    final dynamic value = json['facilities'];

    if (value is List) {
      return value
          .whereType<Map<String, dynamic>>()
          .map(GolfClubFacilityModel.fromJson)
          .where(
            (item) => item.facilityType.isNotEmpty || item.title.isNotEmpty,
          )
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

    return int.tryParse(value?.toString() ?? '') ?? 18;
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

  static bool _parseIsBookable(Map<String, dynamic> json) {
    final dynamic value =
        json['isBookable'] ?? json['is_bookable'] ?? json['bookable'];
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
    return <String, dynamic>{'facility_type': facilityType, 'title': title};
  }
}
