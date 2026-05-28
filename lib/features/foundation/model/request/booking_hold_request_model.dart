class BookingHoldRequestModel {
  const BookingHoldRequestModel({
    required this.slotId,
    required this.accessToken,
    required this.hostName,
    required this.hostPhoneNumber,
    required this.source,
    this.idempotencyKey,
  });

  final String slotId;
  final String accessToken;
  final String? idempotencyKey;
  final String hostName;
  final String hostPhoneNumber;
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
