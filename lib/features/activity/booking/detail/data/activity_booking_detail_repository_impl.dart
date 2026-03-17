import 'package:flutter/material.dart';
import 'package:golf_kakis/features/activity/booking/detail/data/activity_booking_detail_repository.dart';
import 'package:golf_kakis/features/booking/api/booking_api_service.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_model.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_submission_player_model.dart';
import 'package:golf_kakis/features/foundation/network/network.dart';

class ActivityBookingDetailRepositoryImpl
    implements ActivityBookingDetailRepository {
  static const bool _preferImmediateFallback = true;

  ActivityBookingDetailRepositoryImpl({
    ApiClient? apiClient,
    BookingApiService? apiService,
  }) : _apiService =
           apiService ?? BookingApiService(apiClient: apiClient ?? ApiClient());

  final BookingApiService _apiService;

  @override
  Future<ActivityBookingDetailResult> onFetchBookingDetail({
    required BookingModel booking,
  }) async {
    if (_preferImmediateFallback) {
      return ActivityBookingDetailResult(booking: booking, isFallback: true);
    }

    try {
      final response = await _apiService.onFetchBookingDetails(
        bookingSlug: booking.bookingId,
      );
      final parsed = _parseBooking(response);
      if (parsed != null) {
        return ActivityBookingDetailResult(booking: parsed, isFallback: false);
      }
    } catch (_) {
      // Temporary fallback until the booking detail endpoint is ready.
    }

    return ActivityBookingDetailResult(booking: booking, isFallback: true);
  }

  @override
  Future<ActivityBookingDeleteResult> onDeleteBooking({
    required BookingModel booking,
  }) async {
    if (_preferImmediateFallback) {
      return const ActivityBookingDeleteResult(isFallback: true);
    }

    try {
      await _apiService.onDeleteBookingDetails(bookingId: booking.bookingId);
      return const ActivityBookingDeleteResult(isFallback: false);
    } catch (_) {
      return const ActivityBookingDeleteResult(isFallback: true);
    }
  }

  BookingModel? _parseBooking(dynamic response) {
    final payload = response is Map<String, dynamic>
        ? response['data'] is Map<String, dynamic>
              ? response['data'] as Map<String, dynamic>
              : response['booking'] is Map<String, dynamic>
              ? response['booking'] as Map<String, dynamic>
              : response
        : null;

    if (payload == null) {
      return null;
    }

    final bookingDate = _readString(payload, <String>[
      'bookingDate',
      'date',
      'teeDate',
      'playDate',
    ]);
    final teeTimeSlot = _readString(payload, <String>[
      'teeTimeSlot',
      'tee_time_slot',
      'time',
      'teeTime',
    ]);
    final statusLabel = _readString(payload, <String>[
      'statusLabel',
      'status',
      'bookingStatus',
    ], fallback: 'Confirmed');
    final price = _readNum(payload, <String>[
      'pricePerPerson',
      'price',
      'amount',
      'fee',
    ]);
    final currency = _readString(payload, <String>[
      'currency',
      'currencyCode',
    ], fallback: 'MYR');
    final playerCount = _readInt(payload, <String>[
      'playerCount',
      'players',
    ], fallback: 1);
    final caddieCount = _readInt(payload, <String>[
      'caddieCount',
      'caddies',
    ], fallback: 0);
    final golfCartCount = _readInt(payload, <String>[
      'golfCartCount',
      'cartCount',
      'buggyCount',
    ], fallback: 0);
    final playerDetails = _parsePlayers(
      payload['playerDetails'] ?? payload['players'],
    );
    final primaryPlayer = playerDetails.isNotEmpty ? playerDetails.first : null;
    final hostName = _readString(payload, <String>[
      'hostName',
      'bookedByName',
      'contactName',
    ], fallback: primaryPlayer?.name ?? 'Guest Host');
    final hostPhone = _readString(payload, <String>[
      'hostPhoneNumber',
      'contactPhone',
      'bookedByPhone',
    ], fallback: primaryPlayer?.phoneNumber ?? '');

    return BookingModel(
      bookingId: _readString(payload, <String>[
        'bookingId',
        'id',
        'bookingCode',
        'referenceNo',
      ]),
      courseName: _readString(payload, <String>[
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
      guestId: _readNullableString(payload, <String>['guestId', 'guestCode']),
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
}
