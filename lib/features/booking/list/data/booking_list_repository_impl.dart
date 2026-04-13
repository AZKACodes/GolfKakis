import 'package:flutter/material.dart';
import 'package:golf_kakis/features/booking/list/data/booking_list_repository.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_model.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_submission_player_model.dart';
import 'package:golf_kakis/features/booking/api/booking_api_service.dart';
import 'package:golf_kakis/features/foundation/network/network.dart';

class BookingListRepositoryImpl implements BookingListRepository {
  BookingListRepositoryImpl({
    required String accessToken,
    ApiClient? apiClient,
    BookingApiService? apiService,
  }) : _accessToken = accessToken,
       _apiService =
           apiService ?? BookingApiService(apiClient: apiClient ?? ApiClient());

  final String _accessToken;
  final BookingApiService _apiService;

  @override
  Future<BookingTabData> onFetchUpcomingBookingList() async {
    final response = await _apiService.onFetchBookingUpcomingList(
      accessToken: _accessToken,
    );
    final bookings = _parseBookingList(response, fallbackStatus: 'Confirmed');
    return BookingTabData(bookings: bookings);
  }

  @override
  Future<BookingTabData> onFetchPastBookingList() async {
    final response = await _apiService.onFetchBookingPastList(
      accessToken: _accessToken,
    );
    final bookings = _parseBookingList(response, fallbackStatus: 'Completed');
    return BookingTabData(bookings: bookings);
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
    final bookingDate = _readString(data, <String>[
      'bookingDate',
      'date',
      'teeDate',
      'playDate',
    ]);
    final teeTimeSlot = _readString(data, <String>[
      'teeTimeSlot',
      'tee_time_slot',
      'time',
      'teeTime',
    ]);
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
      bookingSlug: _readNullableString(data, <String>[
        'bookingSlug',
        'booking_slug',
        'slug',
      ]),
      courseName: _readString(data, <String>[
        'golfClubName',
        'courseName',
        'clubName',
        'name',
      ], fallback: 'Golf Club'),
      dateLabel: _formatDateLabel(bookingDate),
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
      ], fallback: 1),
      caddieCount: _readInt(data, <String>['caddieCount', 'caddies']),
      golfCartCount: _readInt(data, <String>[
        'golfCartCount',
        'cartCount',
        'buggyCount',
      ]),
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

  String _formatStatusLabel(String status) {
    final normalized = status.trim();
    if (normalized.isEmpty) {
      return status;
    }

    return normalized
        .split(RegExp(r'[_\s]+'))
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}
