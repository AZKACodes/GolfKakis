import 'package:flutter/material.dart';

import 'booking_submission_player_model.dart';

class BookingModel {
  const BookingModel({
    required this.bookingId,
    required this.courseName,
    required this.dateLabel,
    required this.timeLabel,
    required this.teeTimeSlot,
    required this.feeLabel,
    required this.statusLabel,
    required this.statusColor,
    required this.hostName,
    required this.hostPhoneNumber,
    required this.playerCount,
    required this.caddieCount,
    required this.golfCartCount,
    required this.playerDetails,
    this.guestId,
  });

  final String bookingId;
  final String courseName;
  final String dateLabel;
  final String timeLabel;
  final String teeTimeSlot;
  final String feeLabel;
  final String statusLabel;
  final Color statusColor;
  final String? guestId;
  final String hostName;
  final String hostPhoneNumber;
  final int playerCount;
  final int caddieCount;
  final int golfCartCount;
  final List<BookingSubmissionPlayerModel> playerDetails;

  String get playersLabel => '$playerCount Players';

  bool get isCompleted => statusLabel.toLowerCase() == 'completed';

  BookingModel copyWith({
    String? bookingId,
    String? courseName,
    String? dateLabel,
    String? timeLabel,
    String? teeTimeSlot,
    String? feeLabel,
    String? statusLabel,
    Color? statusColor,
    String? guestId,
    String? hostName,
    String? hostPhoneNumber,
    int? playerCount,
    int? caddieCount,
    int? golfCartCount,
    List<BookingSubmissionPlayerModel>? playerDetails,
  }) {
    return BookingModel(
      bookingId: bookingId ?? this.bookingId,
      courseName: courseName ?? this.courseName,
      dateLabel: dateLabel ?? this.dateLabel,
      timeLabel: timeLabel ?? this.timeLabel,
      teeTimeSlot: teeTimeSlot ?? this.teeTimeSlot,
      feeLabel: feeLabel ?? this.feeLabel,
      statusLabel: statusLabel ?? this.statusLabel,
      statusColor: statusColor ?? this.statusColor,
      guestId: guestId ?? this.guestId,
      hostName: hostName ?? this.hostName,
      hostPhoneNumber: hostPhoneNumber ?? this.hostPhoneNumber,
      playerCount: playerCount ?? this.playerCount,
      caddieCount: caddieCount ?? this.caddieCount,
      golfCartCount: golfCartCount ?? this.golfCartCount,
      playerDetails: playerDetails ?? this.playerDetails,
    );
  }
}
