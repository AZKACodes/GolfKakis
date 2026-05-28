import 'package:golf_kakis/features/foundation/model/booking_submission_player_model.dart';

class BookingSubmissionRequestModel {
  const BookingSubmissionRequestModel({
    required this.bookingRef,
    required this.caddieArrangement,
    required this.buggyQuantity,
    required this.playerDetails,
    this.accessToken,
    this.voucherCode,
    this.acknowledgedTerms = true,
  });

  final String bookingRef;
  final String caddieArrangement;
  final int buggyQuantity;
  final List<BookingSubmissionPlayerModel> playerDetails;
  final String? accessToken;
  final String? voucherCode;
  final bool acknowledgedTerms;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'bookingRef': bookingRef,
      'caddieArrangement': caddieArrangement,
      'buggyQuantity': buggyQuantity,
      'playerDetails': playerDetails.map((player) => player.toJson()).toList(),
      if (voucherCode != null && voucherCode!.trim().isNotEmpty)
        'voucherCode': voucherCode!.trim(),
      'acknowledgedTerms': acknowledgedTerms,
    };
  }
}
