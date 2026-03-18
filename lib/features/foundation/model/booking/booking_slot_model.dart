import 'package:golf_kakis/features/foundation/util/default_constant_util.dart';

class BookingSlotModel {
  const BookingSlotModel({
    this.slotId = '',
    required this.time,
    required this.price,
    required this.noOfHoles,
    this.currency = DefaultConstantUtil.defaultCurrency,
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
  final DateTime? startAt;
  final DateTime? endAt;
  final int remainingPlayerCapacity;
  final int remainingCaddieCapacity;
  final int remainingGolfCartCapacity;
  final bool isAvailable;

  factory BookingSlotModel.fromJson(Map<String, dynamic> json) {
    return BookingSlotModel(
      slotId:
          json['slotId']?.toString() ??
          json['slot_id']?.toString() ??
          json['id']?.toString() ??
          '',
      time:
          json['time']?.toString() ??
          json['slotTime']?.toString() ??
          json['teeTimeSlot']?.toString() ??
          json['teeTime']?.toString() ??
          json['slot']?.toString() ??
          '',
      price:
          (json['price'] as num?)?.toDouble() ??
          (json['pricePerPerson'] as num?)?.toDouble() ??
          (json['price_per_person'] as num?)?.toDouble() ??
          (json['amount'] as num?)?.toDouble() ??
          0,
      noOfHoles:
          (json['noOfHoles'] as num?)?.toInt() ??
          (json['no_of_holes'] as num?)?.toInt() ??
          (json['holes'] as num?)?.toInt() ??
          18,
      currency:
          json['currency']?.toString().toUpperCase() ??
          json['currencyCode']?.toString().toUpperCase() ??
          DefaultConstantUtil.defaultCurrency,
      startAt: _parseDateTime(json['startAt'] ?? json['start_at']),
      endAt: _parseDateTime(json['endAt'] ?? json['end_at']),
      remainingPlayerCapacity:
          (json['remainingPlayerCapacity'] as num?)?.toInt() ??
          (json['remaining_player_capacity'] as num?)?.toInt() ??
          0,
      remainingCaddieCapacity:
          (json['remainingCaddieCapacity'] as num?)?.toInt() ??
          (json['remaining_caddie_capacity'] as num?)?.toInt() ??
          0,
      remainingGolfCartCapacity:
          (json['remainingGolfCartCapacity'] as num?)?.toInt() ??
          (json['remaining_golf_cart_capacity'] as num?)?.toInt() ??
          0,
      isAvailable: json['isAvailable'] as bool? ?? json['is_available'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'slotId': slotId,
      'time': time,
      'price': price,
      'noOfHoles': noOfHoles,
      'currency': currency,
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
}
