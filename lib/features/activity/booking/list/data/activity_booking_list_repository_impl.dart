import 'package:flutter/material.dart';
import 'package:xxx_demo_app/features/activity/booking/list/data/activity_booking_list_repository.dart';
import 'package:xxx_demo_app/features/booking/api/booking_api_service.dart';
import 'package:xxx_demo_app/features/foundation/model/booking/booking_model.dart';
import 'package:xxx_demo_app/features/foundation/model/booking/booking_submission_player_model.dart';
import 'package:xxx_demo_app/features/foundation/network/network.dart';

class ActivityBookingListRepositoryImpl
    implements ActivityBookingListRepository {
  ActivityBookingListRepositoryImpl({
    ApiClient? apiClient,
    BookingApiService? apiService,
  }) : _apiService =
           apiService ?? BookingApiService(apiClient: apiClient ?? ApiClient());

  final BookingApiService _apiService;

  @override
  Future<ActivityBookingTabData> onFetchUpcomingBookingList() async {
    try {
      final response = await _apiService.onFetchBookingUpcomingList();
      final bookings = _parseBookingList(response);
      if (bookings.isNotEmpty) {
        return ActivityBookingTabData(bookings: bookings, isFallback: false);
      }
    } catch (_) {
      // Temporary fallback until the upcoming booking endpoint is ready.
    }

    return const ActivityBookingTabData(
      bookings: _fallbackUpcomingBookings,
      isFallback: true,
    );
  }

  @override
  Future<ActivityBookingTabData> onFetchPastBookingList() async {
    try {
      final response = await _apiService.onFetchBookingPastList();
      final bookings = _parseBookingList(response);
      if (bookings.isNotEmpty) {
        return ActivityBookingTabData(bookings: bookings, isFallback: false);
      }
    } catch (_) {
      // Temporary fallback until the past booking endpoint is ready.
    }

    return const ActivityBookingTabData(
      bookings: _fallbackPastBookings,
      isFallback: true,
    );
  }

  List<BookingModel> _parseBookingList(dynamic response) {
    final rawList = response is List
        ? response
        : response is Map<String, dynamic>
        ? response['data'] is List
              ? response['data'] as List<dynamic>
              : response['bookings'] is List
              ? response['bookings'] as List<dynamic>
              : response['items'] is List
              ? response['items'] as List<dynamic>
              : const <dynamic>[]
        : const <dynamic>[];

    return rawList
        .whereType<Map<dynamic, dynamic>>()
        .map(
          (item) => _parseBooking(
            Map<String, dynamic>.from(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ),
          ),
        )
        .toList();
  }

  BookingModel _parseBooking(Map<String, dynamic> item) {
    final bookingDate = _readString(item, <String>[
      'bookingDate',
      'date',
      'teeDate',
      'playDate',
    ]);
    final teeTimeSlot = _readString(item, <String>[
      'teeTimeSlot',
      'tee_time_slot',
      'time',
      'teeTime',
    ]);
    final statusLabel = _readString(item, <String>[
      'statusLabel',
      'status',
      'bookingStatus',
    ], fallback: 'Confirmed');
    final price = _readNum(item, <String>[
      'pricePerPerson',
      'price',
      'amount',
      'fee',
    ]);
    final currency = _readString(item, <String>[
      'currency',
      'currencyCode',
    ], fallback: 'MYR');
    final playerCount = _readInt(item, <String>[
      'playerCount',
      'players',
    ], fallback: 1);
    final caddieCount = _readInt(item, <String>[
      'caddieCount',
      'caddies',
    ], fallback: 0);
    final golfCartCount = _readInt(item, <String>[
      'golfCartCount',
      'cartCount',
      'buggyCount',
    ], fallback: 0);
    final playerDetails = _parsePlayers(
      item['playerDetails'] ?? item['players'],
    );
    final primaryPlayer = playerDetails.isNotEmpty ? playerDetails.first : null;
    final hostName = _readString(item, <String>[
      'hostName',
      'bookedByName',
      'contactName',
    ], fallback: primaryPlayer?.name ?? 'Guest Host');
    final hostPhone = _readString(item, <String>[
      'hostPhoneNumber',
      'contactPhone',
      'bookedByPhone',
    ], fallback: primaryPlayer?.phoneNumber ?? '');

    return BookingModel(
      bookingId: _readString(item, <String>[
        'bookingId',
        'id',
        'bookingCode',
        'referenceNo',
      ], fallback: 'BOOKING-${DateTime.now().millisecondsSinceEpoch}'),
      courseName: _readString(item, <String>[
        'courseName',
        'golfClubName',
        'clubName',
        'name',
      ], fallback: 'Golf Club'),
      dateLabel: _formatDateLabel(bookingDate),
      timeLabel: _formatTimeLabel(teeTimeSlot),
      teeTimeSlot: teeTimeSlot.isEmpty ? '-' : teeTimeSlot,
      feeLabel: price == null
          ? '$currency --'
          : '$currency ${price.toStringAsFixed(0)}',
      statusLabel: statusLabel,
      statusColor: _statusColor(statusLabel),
      guestId: _readNullableString(item, <String>['guestId', 'guestCode']),
      hostName: hostName,
      hostPhoneNumber: hostPhone,
      playerCount: playerCount,
      caddieCount: caddieCount,
      golfCartCount: golfCartCount,
      playerDetails: playerDetails.isEmpty
          ? <BookingSubmissionPlayerModel>[
              BookingSubmissionPlayerModel(
                name: hostName,
                phoneNumber: hostPhone,
              ),
            ]
          : playerDetails,
    );
  }

  List<BookingSubmissionPlayerModel> _parsePlayers(dynamic response) {
    if (response is! List) {
      return const <BookingSubmissionPlayerModel>[];
    }

    return response
        .whereType<Map<dynamic, dynamic>>()
        .map(
          (item) => BookingSubmissionPlayerModel(
            name: _readString(
              Map<String, dynamic>.from(
                item.map((key, value) => MapEntry(key.toString(), value)),
              ),
              <String>['name', 'playerName'],
            ),
            phoneNumber: _readString(
              Map<String, dynamic>.from(
                item.map((key, value) => MapEntry(key.toString(), value)),
              ),
              <String>['phoneNumber', 'phone', 'playerPhone'],
            ),
          ),
        )
        .toList();
  }

  String _readString(
    Map<String, dynamic> item,
    List<String> keys, {
    String fallback = '',
  }) {
    for (final key in keys) {
      final value = item[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return fallback;
  }

  String? _readNullableString(Map<String, dynamic> item, List<String> keys) {
    final value = _readString(item, keys);
    return value.isEmpty ? null : value;
  }

  int _readInt(
    Map<String, dynamic> item,
    List<String> keys, {
    int fallback = 0,
  }) {
    final value = _readNum(item, keys);
    return value?.toInt() ?? fallback;
  }

  num? _readNum(Map<String, dynamic> item, List<String> keys) {
    for (final key in keys) {
      final value = item[key];
      if (value is num) {
        return value;
      }
      if (value is String) {
        final parsed = num.tryParse(value);
        if (parsed != null) {
          return parsed;
        }
      }
    }
    return null;
  }

  String _formatDateLabel(String rawDate) {
    if (rawDate.isEmpty) {
      return '-';
    }

    final parsed = DateTime.tryParse(rawDate);
    if (parsed == null) {
      return rawDate;
    }

    const weekdays = <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${weekdays[parsed.weekday - 1]}, ${months[parsed.month - 1]} ${parsed.day}';
  }

  String _formatTimeLabel(String rawTime) {
    if (rawTime.isEmpty) {
      return '-';
    }

    final twentyFourMatch = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(rawTime);
    if (twentyFourMatch != null) {
      final hour = int.tryParse(twentyFourMatch.group(1)!);
      final minute = twentyFourMatch.group(2);
      if (hour != null && hour >= 0 && hour < 24) {
        final normalizedHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
        final suffix = hour >= 12 ? 'PM' : 'AM';
        return '${normalizedHour.toString().padLeft(2, '0')}:$minute $suffix';
      }
    }

    final normalized = rawTime.trim().toUpperCase();
    if (RegExp(r'^\d{1,2}:\d{2}\s?(AM|PM)$').hasMatch(normalized)) {
      final compact = normalized.replaceAll(RegExp(r'\s+'), ' ');
      final parts = compact.split(' ');
      if (parts.length == 2) {
        final timeParts = parts.first.split(':');
        final hour = int.tryParse(timeParts.first);
        final minute = timeParts.last;
        if (hour != null) {
          return '${hour.toString().padLeft(2, '0')}:$minute ${parts.last}';
        }
      }
    }

    return rawTime;
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF345C8A);
      case 'cancelled':
      case 'canceled':
        return const Color(0xFF8A3D3D);
      case 'pending payment':
      case 'pending':
        return const Color(0xFF9A6A00);
      default:
        return const Color(0xFF1E7D66);
    }
  }

  static const List<BookingModel> _fallbackUpcomingBookings = <BookingModel>[
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

  static const List<BookingModel> _fallbackPastBookings = <BookingModel>[
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
}
