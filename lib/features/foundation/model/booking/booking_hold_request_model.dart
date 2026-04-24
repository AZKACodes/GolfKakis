class BookingHoldRequestModel {
  const BookingHoldRequestModel({
    required this.slotId,
    required this.accessToken,
    required this.hostName,
    required this.hostPhoneNumber,
    required this.source,
    this.playType,
    this.idempotencyKey,
    this.selectedNine,
    this.golfClubName,
    this.golfClubSlug,
    this.bookingDate,
    this.teeTimeSlot,
    this.playerCount,
    this.normalPlayerCount,
    this.seniorPlayerCount = 0,
    this.caddieArrangement = 'none',
    this.buggyType = 'normal',
    this.buggySharingPreference = 'shared',
    this.paymentMethod = 'pay_counter',
  });

  final String slotId;
  final String accessToken;
  final String? playType;
  final String? idempotencyKey;
  final String? selectedNine;
  final String? golfClubName;
  final String? golfClubSlug;
  final String? bookingDate;
  final String? teeTimeSlot;
  final String hostName;
  final String hostPhoneNumber;
  final int? playerCount;
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
      'hostName': hostName,
      'hostPhoneNumber': hostPhoneNumber,
      'source': source,
    };
  }
}
