import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_model.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_submission_player_model.dart';

import 'activity_overview_view_contract.dart';

class ActivityOverviewViewModel extends ChangeNotifier
    implements ActivityOverviewViewContract {
  static const BookingModel _upcomingBooking = BookingModel(
    bookingId: 'BK-10431',
    courseName: 'Kinrara Golf Club',
    dateLabel: 'Fri, Mar 6',
    timeLabel: '07:30 AM',
    teeTimeSlot: '07:30 AM',
    feeLabel: 'MYR 39',
    statusLabel: 'Confirmed',
    statusColor: Color(0xFF1E7D66),
    hostName: 'Zack Green',
    hostPhoneNumber: '+60 12-310 4472',
    playerCount: 2,
    caddieCount: 1,
    golfCartCount: 1,
    playerDetails: <BookingSubmissionPlayerModel>[
      BookingSubmissionPlayerModel(
        name: 'Zack Green',
        phoneNumber: '+60 12-310 4472',
      ),
      BookingSubmissionPlayerModel(
        name: 'Ahmad Firdaus',
        phoneNumber: '+60 19-880 3001',
      ),
    ],
  );

  static const BookingModel _recentRoundOne = BookingModel(
    bookingId: 'BK-10307',
    courseName: 'Saujana G&CC',
    dateLabel: 'Tue, Feb 25',
    timeLabel: '08:00 AM',
    teeTimeSlot: '08:00 AM',
    feeLabel: 'MYR 44',
    statusLabel: 'Completed',
    statusColor: Color(0xFF345C8A),
    hostName: 'Zack Green',
    hostPhoneNumber: '+60 12-310 4472',
    playerCount: 3,
    caddieCount: 1,
    golfCartCount: 1,
    playerDetails: <BookingSubmissionPlayerModel>[
      BookingSubmissionPlayerModel(
        name: 'Zack Green',
        phoneNumber: '+60 12-310 4472',
      ),
      BookingSubmissionPlayerModel(
        name: 'Nadia Rahim',
        phoneNumber: '+60 19-332 9012',
      ),
      BookingSubmissionPlayerModel(
        name: 'Aaron Low',
        phoneNumber: '+60 12-988 3331',
      ),
    ],
  );

  static const BookingModel _recentRoundTwo = BookingModel(
    bookingId: 'BK-10321',
    courseName: 'Kota Permai',
    dateLabel: 'Sat, Mar 1',
    timeLabel: '07:20 AM',
    teeTimeSlot: '07:20 AM',
    feeLabel: 'MYR 50',
    statusLabel: 'Completed',
    statusColor: Color(0xFF345C8A),
    hostName: 'Zack Green',
    hostPhoneNumber: '+60 12-310 4472',
    playerCount: 4,
    caddieCount: 2,
    golfCartCount: 2,
    playerDetails: <BookingSubmissionPlayerModel>[
      BookingSubmissionPlayerModel(
        name: 'Zack Green',
        phoneNumber: '+60 12-310 4472',
      ),
      BookingSubmissionPlayerModel(
        name: 'Imran Khalid',
        phoneNumber: '+60 18-445 7720',
      ),
      BookingSubmissionPlayerModel(
        name: 'Jason Lee',
        phoneNumber: '+60 14-880 1414',
      ),
      BookingSubmissionPlayerModel(
        name: 'Akmal Rashid',
        phoneNumber: '+60 12-777 1221',
      ),
    ],
  );

  final StreamController<ActivityOverviewNavEffect> _navEffectsController =
      StreamController<ActivityOverviewNavEffect>.broadcast();

  final ActivityOverviewViewState _viewState = ActivityOverviewViewState.initial;

  @override
  ActivityOverviewViewState get viewState => _viewState;

  @override
  Stream<ActivityOverviewNavEffect> get navEffects =>
      _navEffectsController.stream;

  @override
  void onUserIntent(ActivityOverviewUserIntent intent) {
    switch (intent) {
      case OnBookingListClick():
        _navEffectsController.add(const NavigateToActivityBookingList());
      case OnUpcomingBookingDetailClick():
        _navEffectsController.add(
          const NavigateToBookingDetails(_upcomingBooking),
        );
      case OnRecentRoundOneDetailClick():
        _navEffectsController.add(
          const NavigateToBookingDetails(_recentRoundOne),
        );
      case OnRecentRoundTwoDetailClick():
        _navEffectsController.add(
          const NavigateToBookingDetails(_recentRoundTwo),
        );
    }
  }

  @override
  void dispose() {
    _navEffectsController.close();
    super.dispose();
  }
}
