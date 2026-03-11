import 'dart:async';

import 'package:flutter/material.dart';
import 'package:xxx_demo_app/features/foundation/model/booking/booking_model.dart';
import 'package:xxx_demo_app/features/foundation/model/booking/booking_submission_player_model.dart';

import 'activity_booking_list_view_contract.dart';

class ActivityBookingListViewModel extends ChangeNotifier
    implements ActivityBookingListViewContract {
  ActivityBookingListViewModel()
    : _viewState = const ActivityBookingListViewState(
        upcomingBookings: _upcomingBookings,
        pastBookings: _pastBookings,
      );

  static const List<BookingModel> _upcomingBookings = [
    BookingModel(
      bookingId: 'BK-10431',
      courseName: 'Kinrara Golf Club',
      dateLabel: 'Fri, Mar 6',
      timeLabel: '07:30 AM',
      teeTimeSlot: '07:30 AM',
      feeLabel: 'MYR 39',
      statusLabel: 'Confirmed',
      statusColor: Color(0xFF1E7D66),
      guestId: null,
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
    ),
    BookingModel(
      bookingId: 'BK-10439',
      courseName: 'Saujana Golf & Country Club',
      dateLabel: 'Sun, Mar 8',
      timeLabel: '08:10 AM',
      teeTimeSlot: '08:10 AM',
      feeLabel: 'MYR 52',
      statusLabel: 'Pending Payment',
      statusColor: Color(0xFF9A6A00),
      guestId: 'GST-8821',
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
          name: 'Kumar Raj',
          phoneNumber: '+60 17-450 1009',
        ),
        BookingSubmissionPlayerModel(
          name: 'Aina Syafiqah',
          phoneNumber: '+60 13-786 5522',
        ),
        BookingSubmissionPlayerModel(
          name: 'Daniel Lim',
          phoneNumber: '+60 11-2323 1010',
        ),
      ],
    ),
    BookingModel(
      bookingId: 'BK-10452',
      courseName: 'Mines Resort & Golf Club',
      dateLabel: 'Wed, Mar 11',
      timeLabel: '07:50 AM',
      teeTimeSlot: '07:50 AM',
      feeLabel: 'MYR 47',
      statusLabel: 'Confirmed',
      statusColor: Color(0xFF1E7D66),
      guestId: null,
      hostName: 'Zack Green',
      hostPhoneNumber: '+60 12-310 4472',
      playerCount: 3,
      caddieCount: 0,
      golfCartCount: 2,
      playerDetails: <BookingSubmissionPlayerModel>[
        BookingSubmissionPlayerModel(
          name: 'Zack Green',
          phoneNumber: '+60 12-310 4472',
        ),
        BookingSubmissionPlayerModel(
          name: 'Farah Noor',
          phoneNumber: '+60 10-442 1900',
        ),
        BookingSubmissionPlayerModel(
          name: 'Jon Tan',
          phoneNumber: '+60 16-908 7766',
        ),
      ],
    ),
  ];

  static const List<BookingModel> _pastBookings = [
    BookingModel(
      bookingId: 'BK-10321',
      courseName: 'Kota Permai Golf & Country Club',
      dateLabel: 'Sat, Mar 1',
      timeLabel: '07:20 AM',
      teeTimeSlot: '07:20 AM',
      feeLabel: 'MYR 50',
      statusLabel: 'Completed',
      statusColor: Color(0xFF345C8A),
      guestId: null,
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
    ),
    BookingModel(
      bookingId: 'BK-10307',
      courseName: 'Tropicana Golf & Country Resort',
      dateLabel: 'Tue, Feb 25',
      timeLabel: '08:00 AM',
      teeTimeSlot: '08:00 AM',
      feeLabel: 'MYR 44',
      statusLabel: 'Completed',
      statusColor: Color(0xFF345C8A),
      guestId: 'GST-7710',
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
    ),
    BookingModel(
      bookingId: 'BK-10288',
      courseName: 'Seri Selangor Golf Club',
      dateLabel: 'Fri, Feb 21',
      timeLabel: '07:40 AM',
      teeTimeSlot: '07:40 AM',
      feeLabel: 'MYR 34',
      statusLabel: 'Cancelled',
      statusColor: Color(0xFF8A3D3D),
      guestId: null,
      hostName: 'Zack Green',
      hostPhoneNumber: '+60 12-310 4472',
      playerCount: 2,
      caddieCount: 0,
      golfCartCount: 0,
      playerDetails: <BookingSubmissionPlayerModel>[
        BookingSubmissionPlayerModel(
          name: 'Zack Green',
          phoneNumber: '+60 12-310 4472',
        ),
        BookingSubmissionPlayerModel(
          name: 'Aisyah Omar',
          phoneNumber: '+60 17-222 4000',
        ),
      ],
    ),
  ];

  final StreamController<ActivityBookingListNavEffect> _navEffectsController =
      StreamController<ActivityBookingListNavEffect>.broadcast();

  final ActivityBookingListViewState _viewState;

  @override
  ActivityBookingListViewState get viewState => _viewState;

  @override
  Stream<ActivityBookingListNavEffect> get navEffects =>
      _navEffectsController.stream;

  @override
  void onUserIntent(ActivityBookingListUserIntent intent) {
    switch (intent) {
      case OnViewBookingDetailClick():
        _navEffectsController.add(NavigateToActivityBookingDetail(intent.booking));
    }
  }

  @override
  void dispose() {
    _navEffectsController.close();
    super.dispose();
  }
}
