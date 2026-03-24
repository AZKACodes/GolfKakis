class BookingHoldRequestModel {
  const BookingHoldRequestModel({
    required this.slotId,
    required this.hostName,
    required this.hostPhoneNumber,
    required this.playerCount,
    required this.caddieCount,
    required this.golfCartCount,
    this.source = 'web',
  });

  final String slotId;
  final String hostName;
  final String hostPhoneNumber;
  final int playerCount;
  final int caddieCount;
  final int golfCartCount;
  final String source;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'slotId': slotId,
      'hostName': hostName,
      'hostPhoneNumber': hostPhoneNumber,
      'playerCount': playerCount,
      'caddieCount': caddieCount,
      'golfCartCount': golfCartCount,
      'source': source,
    };
  }
}
