class BookingHoldRequestModel {
  const BookingHoldRequestModel({
    required this.slotId,
    required this.playType,
    required this.hostName,
    required this.hostPhoneNumber,
    required this.playerCount,
    this.idempotencyKey,
    this.selectedNine,
    this.normalPlayerCount,
    this.seniorPlayerCount = 0,
    this.caddieArrangement = 'none',
    this.buggyType = 'normal',
    this.buggySharingPreference = 'shared',
    this.paymentMethod = 'pay_counter',
    this.source = 'android',
  });

  final String slotId;
  final String playType;
  final String? idempotencyKey;
  final String? selectedNine;
  final String hostName;
  final String hostPhoneNumber;
  final int playerCount;
  final int? normalPlayerCount;
  final int seniorPlayerCount;
  final String caddieArrangement;
  final String buggyType;
  final String buggySharingPreference;
  final String paymentMethod;
  final String source;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'slotId': slotId,
      'playType': playType,
      if (selectedNine != null && selectedNine!.trim().isNotEmpty)
        'selectedNine': selectedNine,
      'hostName': hostName,
      'hostPhoneNumber': hostPhoneNumber,
      'playerCount': playerCount,
      'normalPlayerCount': normalPlayerCount ?? playerCount,
      'seniorPlayerCount': seniorPlayerCount,
      'caddieArrangement': caddieArrangement,
      'buggyType': buggyType,
      'buggySharingPreference': buggySharingPreference,
      'paymentMethod': paymentMethod,
      'source': source,
    };
  }
}
