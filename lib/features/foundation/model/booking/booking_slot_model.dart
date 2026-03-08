import 'package:xxx_demo_app/features/foundation/util/default_constant_util.dart';

class BookingSlotModel {
  const BookingSlotModel({
    required this.time,
    required this.price,
    required this.noOfHoles,
    this.currency = DefaultConstantUtil.defaultCurrency,
  });

  final String time;
  final double price;
  final int noOfHoles;
  final String currency;

  factory BookingSlotModel.fromJson(Map<String, dynamic> json) {
    return BookingSlotModel(
      time:
          json['time']?.toString() ??
          json['slotTime']?.toString() ??
          json['teeTime']?.toString() ??
          json['slot']?.toString() ??
          '',
      price:
          (json['price'] as num?)?.toDouble() ??
          (json['pricePerPerson'] as num?)?.toDouble() ??
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
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'time': time,
      'price': price,
      'noOfHoles': noOfHoles,
      'currency': currency,
    };
  }
}
