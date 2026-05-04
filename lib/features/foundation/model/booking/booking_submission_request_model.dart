import 'package:golf_kakis/features/foundation/model/booking/booking_submission_player_model.dart';

class BookingSubmissionRequestModel {
  const BookingSubmissionRequestModel({
    required this.bookingRef,
    required this.caddieCount,
    required this.golfCartCount,
    required this.playerDetails,
    this.accessToken,
    this.acknowledgedTerms = true,
  });

  final String bookingRef;
  final int caddieCount;
  final int golfCartCount;
  final List<BookingSubmissionPlayerModel> playerDetails;
  final String? accessToken;
  final bool acknowledgedTerms;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'bookingRef': bookingRef,
      'caddieCount': caddieCount,
      'golfCartCount': golfCartCount,
      'playerDetails': playerDetails.map((player) => player.toJson()).toList(),
      'acknowledgedTerms': acknowledgedTerms,
    };
  }
}
