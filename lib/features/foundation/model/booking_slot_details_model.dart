import 'package:golf_kakis/features/foundation/default_values.dart';
import 'package:golf_kakis/features/foundation/util/default_constant_util.dart';

class BookingSlotDetailsModel {
  const BookingSlotDetailsModel({
    required this.quoteId,
    required this.slotId,
    required this.golfClubSlug,
    required this.golfClubName,
    required this.bookingDate,
    required this.teeTimeSlot,
    required this.noOfHoles,
    required this.playerCount,
    required this.playType,
    required this.currency,
    required this.pricePerPerson,
    required this.totalEstimate,
    this.selectedNine,
    this.categoryPricing = const <BookingSlotCategoryPriceModel>[],
    this.pricingBreakdown = const BookingSlotPricingBreakdownModel(),
  });

  final String quoteId;
  final String slotId;
  final String golfClubSlug;
  final String golfClubName;
  final DateTime bookingDate;
  final String teeTimeSlot;
  final int noOfHoles;
  final int playerCount;
  final String playType;
  final String? selectedNine;
  final String currency;
  final double pricePerPerson;
  final double totalEstimate;
  final List<BookingSlotCategoryPriceModel> categoryPricing;
  final BookingSlotPricingBreakdownModel pricingBreakdown;

  factory BookingSlotDetailsModel.fromJson(Map<String, dynamic> json) {
    final currency =
        json['currency']?.toString().toUpperCase() ??
        json['currencyCode']?.toString().toUpperCase() ??
        _readMap(json['pricing'])['currency']?.toString().toUpperCase() ??
        DefaultConstantUtil.defaultCurrency;
    final categoryPricing = _parseCategoryPricing(
      json['categoryPricing'] ?? json['category_pricing'] ?? json['categories'],
    );
    final pricePerPerson =
        _readDouble(
          json['pricePerPerson'] ??
              json['price_per_person'] ??
              json['fromPrice'] ??
              json['price'],
        ) ??
        (categoryPricing.isEmpty ? 0 : categoryPricing.first.amount);
    final playerCount =
        _readInt(json['playerCount'] ?? json['player_count']) ?? 0;
    final totalEstimate =
        _readDouble(
          json['totalEstimate'] ??
              json['total_estimate'] ??
              json['estimatedTotal'] ??
              json['total'],
        ) ??
        pricePerPerson * playerCount;

    return BookingSlotDetailsModel(
      quoteId:
          json['quoteId']?.toString() ??
          json['quote_id']?.toString() ??
          json['id']?.toString() ??
          emptyString,
      slotId:
          json['slotId']?.toString() ??
          json['slot_id']?.toString() ??
          emptyString,
      golfClubSlug:
          json['golfClubSlug']?.toString() ??
          json['golf_club_slug']?.toString() ??
          emptyString,
      golfClubName:
          json['golfClubName']?.toString() ??
          json['golf_club_name']?.toString() ??
          emptyString,
      bookingDate:
          DateTime.tryParse(
            json['bookingDate']?.toString() ??
                json['booking_date']?.toString() ??
                emptyString,
          ) ??
          DateTime.now(),
      teeTimeSlot:
          json['teeTimeSlot']?.toString() ??
          json['tee_time_slot']?.toString() ??
          json['time']?.toString() ??
          emptyString,
      noOfHoles:
          _readInt(json['noOfHoles'] ?? json['no_of_holes'] ?? json['holes']) ??
          18,
      playerCount: playerCount,
      playType:
          json['playType']?.toString() ??
          json['play_type']?.toString() ??
          emptyString,
      selectedNine:
          json['selectedNine']?.toString() ?? json['selected_nine']?.toString(),
      currency: currency,
      pricePerPerson: pricePerPerson,
      totalEstimate: totalEstimate,
      categoryPricing: categoryPricing,
      pricingBreakdown: BookingSlotPricingBreakdownModel.fromJson(
        _readMap(
          json['pricingBreakdown'] ??
              json['priceBreakdown'] ??
              json['pricing_breakdown'] ??
              json['price_breakdown'] ??
              _readMap(json['pricing'])['breakdown'],
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'quoteId': quoteId,
      'slotId': slotId,
      'golfClubSlug': golfClubSlug,
      'golfClubName': golfClubName,
      'bookingDate': bookingDate.toIso8601String(),
      'teeTimeSlot': teeTimeSlot,
      'noOfHoles': noOfHoles,
      'playerCount': playerCount,
      'playType': playType,
      if (selectedNine != null) 'selectedNine': selectedNine,
      'currency': currency,
      'pricePerPerson': pricePerPerson,
      'totalEstimate': totalEstimate,
      'categoryPricing': categoryPricing.map((item) => item.toJson()).toList(),
      'priceBreakdown': pricingBreakdown.toJson(),
    };
  }

  static List<BookingSlotCategoryPriceModel> _parseCategoryPricing(
    dynamic value,
  ) {
    if (value is! List) {
      return const <BookingSlotCategoryPriceModel>[];
    }

    return value
        .whereType<Map<String, dynamic>>()
        .map(BookingSlotCategoryPriceModel.fromJson)
        .where((item) => item.label.isNotEmpty)
        .toList();
  }

  static Map<String, dynamic> _readMap(dynamic value) {
    return value is Map<String, dynamic> ? value : <String, dynamic>{};
  }

  static double? _readDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? emptyString);
  }

  static int? _readInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? emptyString);
  }
}

class BookingSlotCategoryPriceModel {
  const BookingSlotCategoryPriceModel({
    required this.label,
    required this.description,
    required this.amount,
  });

  final String label;
  final String description;
  final double amount;

  factory BookingSlotCategoryPriceModel.fromJson(Map<String, dynamic> json) {
    return BookingSlotCategoryPriceModel(
      label: json['label']?.toString() ?? json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      amount:
          BookingSlotDetailsModel._readDouble(
            json['amount'] ?? json['price'] ?? json['pricePerPerson'],
          ) ??
          0,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'label': label,
      'description': description,
      'amount': amount,
    };
  }
}

class BookingSlotPricingBreakdownModel {
  const BookingSlotPricingBreakdownModel({
    this.golfCartSurcharge = 0,
    this.caddySurcharge = 0,
  });

  final double golfCartSurcharge;
  final double caddySurcharge;

  bool get hasAnySurcharge => golfCartSurcharge > 0 || caddySurcharge > 0;

  factory BookingSlotPricingBreakdownModel.fromJson(Map<String, dynamic> json) {
    return BookingSlotPricingBreakdownModel(
      golfCartSurcharge:
          BookingSlotDetailsModel._readDouble(
            json['golfCartSurcharge'] ?? json['golf_cart_surcharge'],
          ) ??
          0,
      caddySurcharge:
          BookingSlotDetailsModel._readDouble(
            json['caddySurcharge'] ?? json['caddy_surcharge'],
          ) ??
          0,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'golfCartSurcharge': golfCartSurcharge,
      'caddySurcharge': caddySurcharge,
    };
  }
}
