class BookingHoldRequestModel {
  const BookingHoldRequestModel({
    required this.slotId,
    required this.accessToken,
    required this.hostName,
    required this.hostPhoneNumber,
    required this.source,
    this.quoteId,
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
    this.caddieCount = 0,
    this.golfCartCount = 0,
    this.paymentMethod = 'pay_counter',
  });

  final String slotId;
  final String accessToken;
  final String? quoteId;
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
  final int caddieCount;
  final int golfCartCount;
  final String paymentMethod;
  final String source;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'slotId': slotId,
      if (quoteId != null && quoteId!.isNotEmpty) 'quoteId': quoteId,
      'hostName': hostName,
      'hostPhoneNumber': hostPhoneNumber,
      'source': source,
      if (playType != null && playType!.isNotEmpty) 'playType': playType,
      if (selectedNine != null && selectedNine!.isNotEmpty)
        'selectedNine': selectedNine,
      if (golfClubName != null && golfClubName!.isNotEmpty)
        'golfClubName': golfClubName,
      if (golfClubSlug != null && golfClubSlug!.isNotEmpty)
        'golfClubSlug': golfClubSlug,
      if (bookingDate != null && bookingDate!.isNotEmpty)
        'bookingDate': bookingDate,
      if (teeTimeSlot != null && teeTimeSlot!.isNotEmpty)
        'teeTimeSlot': teeTimeSlot,
      if (playerCount != null) 'playerCount': playerCount,
      if (normalPlayerCount != null) 'normalPlayerCount': normalPlayerCount,
      'seniorPlayerCount': seniorPlayerCount,
      'caddieCount': caddieCount,
      'golfCartCount': golfCartCount,
      'paymentMethod': paymentMethod,
    };
  }
}
