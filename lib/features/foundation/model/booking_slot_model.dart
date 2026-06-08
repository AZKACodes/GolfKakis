import 'package:golf_kakis/features/foundation/util/default_constant_util.dart';

class BookingSlotModel {
  const BookingSlotModel({
    this.slotId = '',
    required this.time,
    required this.price,
    required this.noOfHoles,
    this.currency = DefaultConstantUtil.defaultCurrency,
    this.pricingLabel = '',
    this.minPlayers = 1,
    this.maxPlayers = 4,
    this.startAt,
    this.endAt,
    this.remainingPlayerCapacity = 0,
    this.remainingCaddieCapacity = 0,
    this.remainingGolfCartCapacity = 0,
    this.isAvailable = true,
  });

  final String slotId;
  final String time;
  final double price;
  final int noOfHoles;
  final String currency;
  final String pricingLabel;
  final int minPlayers;
  final int maxPlayers;
  final DateTime? startAt;
  final DateTime? endAt;
  final int remainingPlayerCapacity;
  final int remainingCaddieCapacity;
  final int remainingGolfCartCapacity;
  final bool isAvailable;

  factory BookingSlotModel.fromJson(Map<String, dynamic> json) {
    final price = _parsePrice(json);
    final maxPlayers = _parseInt(json['maxPlayers'] ?? json['max_players']);
    final minPlayers = _parseInt(json['minPlayers'] ?? json['min_players']);
    final remainingPlayerCapacity =
        _parseInt(
          json['remainingPlayerCapacity'] ??
              json['remaining_player_capacity'] ??
              json['remainingCapacity'] ??
              json['remaining_capacity'],
        ) ??
        maxPlayers ??
        0;

    return BookingSlotModel(
      slotId:
          json['slotId']?.toString() ??
          json['slot_id']?.toString() ??
          json['id']?.toString() ??
          '',
      time: _normalizeTimeLabel(
        json['time']?.toString() ??
            json['slotTime']?.toString() ??
            json['teeTimeSlot']?.toString() ??
            json['teeTime']?.toString() ??
            json['localTime']?.toString() ??
            json['local_time']?.toString() ??
            json['slot']?.toString() ??
            '',
      ),
      price: price,
      noOfHoles:
          _parseInt(
            json['noOfHoles'] ?? json['no_of_holes'] ?? json['holes'],
          ) ??
          _parseHoleCountFromPlayType(json['playType'] ?? json['play_type']) ??
          18,
      currency:
          json['currency']?.toString().toUpperCase() ??
          json['currencyCode']?.toString().toUpperCase() ??
          DefaultConstantUtil.defaultCurrency,
      pricingLabel: json['pricingLabel']?.toString() ?? '',
      minPlayers: minPlayers ?? 1,
      maxPlayers: maxPlayers ?? 4,
      startAt: _parseDateTime(json['startAt'] ?? json['start_at']),
      endAt: _parseDateTime(json['endAt'] ?? json['end_at']),
      remainingPlayerCapacity: remainingPlayerCapacity,
      remainingCaddieCapacity:
          _parseInt(
            json['remainingCaddieCapacity'] ??
                json['remaining_caddie_capacity'],
          ) ??
          0,
      remainingGolfCartCapacity:
          _parseInt(
            json['remainingGolfCartCapacity'] ??
                json['remaining_golf_cart_capacity'],
          ) ??
          0,
      isAvailable:
          _parseBool(
            json['isAvailable'] ?? json['is_available'] ?? json['available'],
          ) ??
          true,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'slotId': slotId,
      'time': time,
      'price': price,
      'noOfHoles': noOfHoles,
      'currency': currency,
      'pricingLabel': pricingLabel,
      'minPlayers': minPlayers,
      'maxPlayers': maxPlayers,
      'startAt': startAt?.toIso8601String(),
      'endAt': endAt?.toIso8601String(),
      'remainingPlayerCapacity': remainingPlayerCapacity,
      'remainingCaddieCapacity': remainingCaddieCapacity,
      'remainingGolfCartCapacity': remainingGolfCartCapacity,
      'isAvailable': isAvailable,
    };
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value.toString());
  }

  static double _parsePrice(Map<String, dynamic> json) {
    final value =
        json['price'] ??
        json['pricePerPerson'] ??
        json['price_per_person'] ??
        json['fromPrice'] ??
        json['from_price'] ??
        json['amount'];
    if (value is Map<String, dynamic>) {
      return _parseDouble(
            value['adult'] ??
                value['default'] ??
                value['amount'] ??
                value['price'],
          ) ??
          0;
    }
    if (value is Map) {
      final normalized = value.map(
        (key, item) => MapEntry(key.toString(), item),
      );
      return _parsePrice(<String, dynamic>{'price': normalized});
    }
    return _parseDouble(value) ?? 0;
  }

  static int? _parseHoleCountFromPlayType(dynamic value) {
    final text = value?.toString().toLowerCase() ?? '';
    if (text.contains('18')) {
      return 18;
    }
    if (text.contains('9')) {
      return 9;
    }
    return null;
  }

  static int? _parseInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '');
  }

  static double? _parseDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '');
  }

  static bool? _parseBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    final text = value?.toString().toLowerCase();
    if (text == 'true') {
      return true;
    }
    if (text == 'false') {
      return false;
    }
    return null;
  }

  static String _normalizeTimeLabel(String value) {
    if (value.isEmpty) {
      return value;
    }

    return value
        .replaceAllMapped(
          RegExp(r'\b(am|pm)\b', caseSensitive: false),
          (match) => match.group(0)?.toUpperCase() ?? '',
        )
        .trim();
  }
}
