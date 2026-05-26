import 'package:flutter/material.dart';
import 'package:golf_kakis/features/booking/api/booking_api_service.dart';
import 'package:golf_kakis/features/foundation/model/booking_model.dart';
import 'package:golf_kakis/features/foundation/model/booking_submission_player_model.dart';
import 'package:golf_kakis/features/foundation/network/network.dart';

import 'booking_overview_repository.dart';

class BookingOverviewRepositoryImpl implements BookingOverviewRepository {
  BookingOverviewRepositoryImpl({
    ApiClient? apiClient,
    BookingApiService? apiService,
  }) : _apiService =
           apiService ?? BookingApiService(apiClient: apiClient ?? ApiClient());

  final BookingApiService _apiService;

  @override
  Future<BookingOverviewTabData> onFetchUpcomingBookingList({
    required String accessToken,
  }) async {
    final response = await _apiService.onFetchBookingUpcomingList(
      accessToken: accessToken,
    );
    return BookingOverviewTabData(
      bookings: _parseBookingList(response, fallbackStatus: 'Confirmed'),
    );
  }

  @override
  Future<BookingOverviewTabData> onFetchPastBookingList({
    required String accessToken,
  }) async {
    final response = await _apiService.onFetchBookingPastList(
      accessToken: accessToken,
    );
    return BookingOverviewTabData(
      bookings: _parseBookingList(response, fallbackStatus: 'Completed'),
    );
  }

  List<BookingModel> _parseBookingList(
    dynamic response, {
    required String fallbackStatus,
  }) {
    final rawList = response is List
        ? response
        : response is Map<String, dynamic>
        ? response['items'] is List
              ? response['items'] as List<dynamic>
              : response['data'] is List
              ? response['data'] as List<dynamic>
              : response['bookings'] is List
              ? response['bookings'] as List<dynamic>
              : const <dynamic>[]
        : const <dynamic>[];

    return rawList
        .whereType<Map<dynamic, dynamic>>()
        .map(
          (item) => _parseBooking(
            Map<String, dynamic>.from(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ),
            fallbackStatus: fallbackStatus,
          ),
        )
        .toList();
  }

  BookingModel _parseBooking(
    Map<String, dynamic> data, {
    required String fallbackStatus,
  }) {
    final bookingSummary = data['bookingSummary'] is Map<String, dynamic>
        ? data['bookingSummary'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final bookingDate = _readString(
      data,
      <String>['bookingDate', 'date', 'teeDate', 'playDate'],
      fallback: _readString(bookingSummary, <String>[
        'bookingDate',
        'date',
        'teeDate',
        'playDate',
      ]),
    );
    final teeTimeSlot = _readString(
      data,
      <String>['teeTimeSlot', 'tee_time_slot', 'time', 'teeTime'],
      fallback: _readString(bookingSummary, <String>[
        'teeTimeSlot',
        'tee_time_slot',
        'time',
        'teeTime',
      ]),
    );
    final statusLabel = _readString(data, <String>[
      'status',
      'statusLabel',
      'bookingStatus',
    ], fallback: fallbackStatus);
    final normalizedStatusLabel = _formatStatusLabel(
      statusLabel.isEmpty ? fallbackStatus : statusLabel,
    );
    final total = _readNum(data, <String>[
      'grandTotal',
      'total',
      'amount',
      'fee',
      'pricePerPerson',
      'price',
    ]);
    final currency = _readString(data, <String>[
      'currency',
      'currencyCode',
    ], fallback: 'MYR');
    final playerDetails = _parsePlayers(
      data['playerDetails'] ?? data['players'] ?? data['player_details'],
    );
    final primaryPlayer = playerDetails.isNotEmpty ? playerDetails.first : null;
    final hostName = _readString(data, <String>[
      'hostName',
      'bookedByName',
      'contactName',
    ], fallback: primaryPlayer?.name ?? 'Guest Host');
    final hostPhoneNumber = _readString(data, <String>[
      'hostPhoneNumber',
      'contactPhone',
      'bookedByPhone',
    ], fallback: primaryPlayer?.phoneNumber ?? '');

    return BookingModel(
      bookingId: _readString(data, <String>[
        'bookingRef',
        'bookingId',
        'id',
        'bookingCode',
        'referenceNo',
      ], fallback: 'BOOKING-${DateTime.now().millisecondsSinceEpoch}'),
      bookingRef: _readNullableString(data, <String>[
        'bookingRef',
        'bookingReference',
      ]),
      bookingSlug: _readNullableString(data, <String>[
        'bookingSlug',
        'booking_slug',
        'slug',
      ]),
      courseName: _readString(
        data,
        <String>['golfClubName', 'courseName', 'clubName'],
        fallback: _readString(bookingSummary, <String>[
          'golfClubName',
          'courseName',
          'clubName',
        ], fallback: 'Golf Club'),
      ),
      courseSlug:
          _readNullableString(data, <String>[
            'golfClubSlug',
            'golf_club_slug',
            'courseSlug',
            'clubSlug',
          ]) ??
          _readNullableString(bookingSummary, <String>[
            'golfClubSlug',
            'golf_club_slug',
            'courseSlug',
            'clubSlug',
          ]),
      dateLabel: _formatDateLabel(bookingDate),
      bookingDate: bookingDate.isEmpty ? null : bookingDate,
      timeLabel: _formatTimeLabel(teeTimeSlot),
      teeTimeSlot: teeTimeSlot.isEmpty ? '-' : teeTimeSlot,
      feeLabel: total == null
          ? '$currency --'
          : '$currency ${total.toStringAsFixed(0)}',
      statusLabel: normalizedStatusLabel,
      statusColor: _statusColor(normalizedStatusLabel),
      guestId: _readNullableString(data, <String>['guestId', 'guestCode']),
      hostName: hostName,
      hostPhoneNumber: hostPhoneNumber,
      playerCount: _readInt(data, <String>[
        'playerCount',
        'players',
      ], fallback: 1)!,
      normalPlayerCount: _readInt(data, <String>[
        'normalPlayerCount',
        'normal_player_count',
      ], fallback: 0)!,
      seniorPlayerCount: _readInt(data, <String>[
        'seniorPlayerCount',
        'senior_player_count',
      ], fallback: 0)!,
      caddieCount: _readInt(data, <String>[
        'caddieCount',
        'caddies',
      ], fallback: 0)!,
      golfCartCount: _readInt(data, <String>[
        'golfCartCount',
        'cartCount',
        'buggyCount',
      ], fallback: 0)!,
      playType: _readNullableString(data, <String>['playType', 'play_type']),
      selectedNine:
          _readNullableString(data, <String>[
            'selectedNine',
            'selected_nine',
          ]) ??
          _readNullableString(bookingSummary, <String>[
            'selectedNine',
            'selected_nine',
          ]),
      caddieArrangement: _readNullableString(data, <String>[
        'caddieArrangement',
        'caddie_arrangement',
      ]),
      buggyType: _readNullableString(data, <String>['buggyType', 'buggy_type']),
      buggySharingPreference: _readNullableString(data, <String>[
        'buggySharingPreference',
        'buggy_sharing_preference',
      ]),
      paymentMethod: _readNullableString(data, <String>[
        'paymentMethod',
        'payment_method',
      ]),
      currency: currency,
      grandTotal: total?.toDouble(),
      playerDetails: playerDetails.isEmpty
          ? <BookingSubmissionPlayerModel>[
              BookingSubmissionPlayerModel(
                name: hostName,
                phoneNumber: hostPhoneNumber,
              ),
            ]
          : playerDetails,
    );
  }

  List<BookingSubmissionPlayerModel> _parsePlayers(dynamic response) {
    if (response is! List) {
      return const <BookingSubmissionPlayerModel>[];
    }

    return response.whereType<Map<dynamic, dynamic>>().map((item) {
      final data = Map<String, dynamic>.from(
        item.map((key, value) => MapEntry(key.toString(), value)),
      );
      return BookingSubmissionPlayerModel(
        name: _readString(data, <String>['name', 'playerName']),
        phoneNumber: _readString(data, <String>[
          'phoneNumber',
          'phone_number',
          'phone',
          'playerPhone',
        ]),
      );
    }).toList();
  }

  String _readString(
    Map<String, dynamic> item,
    List<String> keys, {
    String fallback = '',
  }) {
    for (final key in keys) {
      final value = item[key];
      if (value == null) {
        continue;
      }
      final text = value.toString().trim();
      if (text.isNotEmpty) {
        return text;
      }
    }
    return fallback;
  }

  String? _readNullableString(Map<String, dynamic> item, List<String> keys) {
    final value = _readString(item, keys);
    return value.isEmpty ? null : value;
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

  int? _readInt(Map<String, dynamic> item, List<String> keys, {int? fallback}) {
    final number = _readNum(item, keys);
    return number?.toInt() ?? fallback;
  }

  String _formatDateLabel(String date) {
    if (date.trim().isEmpty) {
      return 'Date TBD';
    }

    final parsed = DateTime.tryParse(date);
    if (parsed == null) {
      return date;
    }

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

    return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year}';
  }

  String _formatTimeLabel(String time) {
    return time.trim().isEmpty ? '--' : time;
  }

  String _formatStatusLabel(String status) {
    if (status.trim().isEmpty) {
      return 'Unknown';
    }

    return status
        .split(RegExp(r'[_\s]+'))
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'completed':
        return const Color(0xFF1C8C4D);
      case 'pending':
        return const Color(0xFFE0A100);
      case 'cancelled':
      case 'canceled':
        return const Color(0xFFD64545);
      default:
        return const Color(0xFF5A6473);
    }
  }
}
