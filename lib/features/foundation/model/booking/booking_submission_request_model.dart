import 'package:golf_kakis/features/foundation/model/booking/booking_submission_player_model.dart';

class BookingSubmissionRequestModel {
  const BookingSubmissionRequestModel({
    required this.golfClubName,
    required this.golfClubSlug,
    required this.bookingDate,
    required this.teeTimeSlot,
    required this.pricePerPerson,
    required this.currency,
    this.guestId,
    required this.hostName,
    required this.hostPhoneNumber,
    required this.playerCount,
    required this.caddieCount,
    required this.golfCartCount,
    required this.playerDetails,
  });

  final String golfClubName;
  final String golfClubSlug;
  final String bookingDate;
  final String teeTimeSlot;
  final double pricePerPerson;
  final String currency;
  final String? guestId;
  final String hostName;
  final String hostPhoneNumber;
  final int playerCount;
  final int caddieCount;
  final int golfCartCount;
  final List<BookingSubmissionPlayerModel> playerDetails;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'golfClubName': golfClubName,
      'golfClubSlug': golfClubSlug,
      'bookingDate': bookingDate,
      'teeTimeSlot': teeTimeSlot,
      'pricePerPerson': pricePerPerson,
      'currency': currency,
      'guestId': guestId,
      'hostName': hostName,
      'hostPhoneNumber': hostPhoneNumber,
      'playerCount': playerCount,
      'caddieCount': caddieCount,
      'golfCartCount': golfCartCount,
      'playerDetails': playerDetails.map((player) => player.toJson()).toList(),
    };
  }
}
