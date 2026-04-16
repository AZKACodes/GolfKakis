import 'package:golf_kakis/features/foundation/model/booking/booking_submission_player_model.dart';

class BookingSubmissionRequestModel {
  const BookingSubmissionRequestModel({
    required this.bookingRef,
    required this.caddieArrangement,
    required this.buggyType,
    required this.buggySharingPreference,
    required this.playerDetails,
    this.accessToken,
    this.acknowledgedTerms = true,
  });

  final String bookingRef;
  final String caddieArrangement;
  final String buggyType;
  final String buggySharingPreference;
  final List<BookingSubmissionPlayerModel> playerDetails;
  final String? accessToken;
  final bool acknowledgedTerms;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'bookingRef': bookingRef,
      'caddieArrangement': caddieArrangement,
      'buggyType': buggyType,
      'buggySharingPreference': buggySharingPreference,
      'playerDetails': playerDetails.map((player) => player.toJson()).toList(),
      'acknowledgedTerms': acknowledgedTerms,
    };
  }
}
