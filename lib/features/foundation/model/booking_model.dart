import 'package:flutter/material.dart';

import 'booking_submission_player_model.dart';

class BookingModel {
  const BookingModel({
    required this.bookingId,
    this.bookingRef,
    this.bookingSlug,
    required this.courseName,
    this.courseSlug,
    required this.dateLabel,
    this.bookingDate,
    required this.timeLabel,
    required this.teeTimeSlot,
    required this.feeLabel,
    required this.statusLabel,
    required this.statusColor,
    required this.hostName,
    required this.hostPhoneNumber,
    required this.playerCount,
    this.normalPlayerCount = 0,
    this.seniorPlayerCount = 0,
    required this.caddieCount,
    required this.golfCartCount,
    required this.playerDetails,
    this.guestId,
    this.playType,
    this.selectedNine,
    this.caddieArrangement,
    this.buggyType,
    this.buggySharingPreference,
    this.paymentMethod,
    this.currency,
    this.grandTotal,
    this.pendingCounterConfirmation = const <String>[],
    this.isPhoneVerified,
    this.createdAt,
    this.updatedAt,
    this.holdExpiresAt,
  });

  final String bookingId;
  final String? bookingRef;
  final String? bookingSlug;
  final String courseName;
  final String? courseSlug;
  final String dateLabel;
  final String? bookingDate;
  final String timeLabel;
  final String teeTimeSlot;
  final String feeLabel;
  final String statusLabel;
  final Color statusColor;
  final String? guestId;
  final String hostName;
  final String hostPhoneNumber;
  final int playerCount;
  final int normalPlayerCount;
  final int seniorPlayerCount;
  final int caddieCount;
  final int golfCartCount;
  final List<BookingSubmissionPlayerModel> playerDetails;
  final String? playType;
  final String? selectedNine;
  final String? caddieArrangement;
  final String? buggyType;
  final String? buggySharingPreference;
  final String? paymentMethod;
  final String? currency;
  final double? grandTotal;
  final List<String> pendingCounterConfirmation;
  final bool? isPhoneVerified;
  final String? createdAt;
  final String? updatedAt;
  final String? holdExpiresAt;

  String get bookingReference =>
      bookingRef?.trim().isNotEmpty == true ? bookingRef! : bookingId;

  String get playersLabel => '$playerCount Players';

  bool get isCompleted => statusLabel.toLowerCase() == 'completed';

  BookingModel copyWith({
    String? bookingId,
    String? bookingRef,
    String? bookingSlug,
    String? courseName,
    String? courseSlug,
    String? dateLabel,
    String? bookingDate,
    String? timeLabel,
    String? teeTimeSlot,
    String? feeLabel,
    String? statusLabel,
    Color? statusColor,
    String? guestId,
    String? hostName,
    String? hostPhoneNumber,
    int? playerCount,
    int? normalPlayerCount,
    int? seniorPlayerCount,
    int? caddieCount,
    int? golfCartCount,
    List<BookingSubmissionPlayerModel>? playerDetails,
    String? playType,
    String? selectedNine,
    String? caddieArrangement,
    String? buggyType,
    String? buggySharingPreference,
    String? paymentMethod,
    String? currency,
    double? grandTotal,
    List<String>? pendingCounterConfirmation,
    bool? isPhoneVerified,
    String? createdAt,
    String? updatedAt,
    String? holdExpiresAt,
  }) {
    return BookingModel(
      bookingId: bookingId ?? this.bookingId,
      bookingRef: bookingRef ?? this.bookingRef,
      bookingSlug: bookingSlug ?? this.bookingSlug,
      courseName: courseName ?? this.courseName,
      courseSlug: courseSlug ?? this.courseSlug,
      dateLabel: dateLabel ?? this.dateLabel,
      bookingDate: bookingDate ?? this.bookingDate,
      timeLabel: timeLabel ?? this.timeLabel,
      teeTimeSlot: teeTimeSlot ?? this.teeTimeSlot,
      feeLabel: feeLabel ?? this.feeLabel,
      statusLabel: statusLabel ?? this.statusLabel,
      statusColor: statusColor ?? this.statusColor,
      guestId: guestId ?? this.guestId,
      hostName: hostName ?? this.hostName,
      hostPhoneNumber: hostPhoneNumber ?? this.hostPhoneNumber,
      playerCount: playerCount ?? this.playerCount,
      normalPlayerCount: normalPlayerCount ?? this.normalPlayerCount,
      seniorPlayerCount: seniorPlayerCount ?? this.seniorPlayerCount,
      caddieCount: caddieCount ?? this.caddieCount,
      golfCartCount: golfCartCount ?? this.golfCartCount,
      playerDetails: playerDetails ?? this.playerDetails,
      playType: playType ?? this.playType,
      selectedNine: selectedNine ?? this.selectedNine,
      caddieArrangement: caddieArrangement ?? this.caddieArrangement,
      buggyType: buggyType ?? this.buggyType,
      buggySharingPreference:
          buggySharingPreference ?? this.buggySharingPreference,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      currency: currency ?? this.currency,
      grandTotal: grandTotal ?? this.grandTotal,
      pendingCounterConfirmation:
          pendingCounterConfirmation ?? this.pendingCounterConfirmation,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      holdExpiresAt: holdExpiresAt ?? this.holdExpiresAt,
    );
  }
}
