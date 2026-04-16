import 'package:flutter/material.dart';
import 'package:golf_kakis/features/booking/api/booking_api_service.dart';
import 'package:golf_kakis/features/booking/detail/data/booking_detail_repository.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_model.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_submission_player_model.dart';
import 'package:golf_kakis/features/foundation/network/network.dart';

class BookingDetailRepositoryImpl implements BookingDetailRepository {
  BookingDetailRepositoryImpl({
    required String accessToken,
    ApiClient? apiClient,
    BookingApiService? apiService,
  }) : _accessToken = accessToken,
       _apiService =
           apiService ?? BookingApiService(apiClient: apiClient ?? ApiClient());

  final String _accessToken;
  final BookingApiService _apiService;

  @override
  Future<BookingDetailResult> onFetchBookingDetail({
    required BookingModel booking,
  }) async {
    final bookingRef = booking.bookingReference.trim();
    if (bookingRef.isEmpty) {
      throw StateError('Missing booking reference for booking detail request.');
    }

    final response = await _apiService.onFetchBookingDetails(
      bookingRef: bookingRef,
      accessToken: _accessToken,
    );
    final parsed = _parseBooking(response);
    if (parsed == null) {
      throw StateError('Unable to parse booking detail response.');
    }

    return BookingDetailResult(booking: parsed);
  }

  @override
  Future<BookingDeleteResult> onDeleteBooking({
    required BookingModel booking,
  }) async {
    await _apiService.onDeleteBookingDetails(bookingId: booking.bookingId);
    return const BookingDeleteResult();
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

    final bookingSummary = payload['bookingSummary'] is Map<String, dynamic>
        ? payload['bookingSummary'] as Map<String, dynamic>
        : const <String, dynamic>{};

    final bookingRef = _readString(payload, const <String>[
      'bookingRef',
      'bookingReference',
    ], fallback: '')!;
    final bookingDate = _readString(payload, const <String>[
      'bookingDate',
      'date',
      'teeDate',
      'playDate',
    ], fallback: '')!;
    final teeTimeSlot = _readString(payload, const <String>[
      'teeTimeSlot',
      'tee_time_slot',
      'time',
      'teeTime',
    ], fallback: '')!;
    final statusLabel = _formatStatusLabel(
      _readString(payload, const <String>[
        'statusLabel',
        'status',
        'bookingStatus',
      ], fallback: 'Confirmed')!,
    );
    final pricing = payload['pricing'] is Map<String, dynamic>
        ? payload['pricing'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final currency =
        _readString(payload, const <String>['currency', 'currencyCode']) ??
        _readString(pricing, const <String>['currency', 'currencyCode']) ??
        'MYR';
    final grandTotal = _readNum(pricing, const <String>[
      'grandTotal',
      'grand_total',
      'total',
    ]);
    final playerDetails = _parsePlayers(
      payload['playerDetails'] ?? payload['players'],
    );
    final primaryPlayer = playerDetails.isNotEmpty ? playerDetails.first : null;
    final hostName =
        _readString(payload, const <String>[
          'hostName',
          'bookedByName',
          'contactName',
        ]) ??
        primaryPlayer?.name ??
        'Guest Host';
    final hostPhone =
        _readString(payload, const <String>[
          'hostPhoneNumber',
          'contactPhone',
          'bookedByPhone',
        ]) ??
        primaryPlayer?.phoneNumber ??
        '';
    final pendingCounterConfirmation =
        pricing['pendingCounterConfirmation'] is List
        ? (pricing['pendingCounterConfirmation'] as List)
              .map((item) => item?.toString() ?? '')
              .where((item) => item.isNotEmpty)
              .toList()
        : const <String>[];

    return BookingModel(
      bookingId:
          _readString(payload, const <String>['bookingId', 'id']) ?? bookingRef,
      bookingRef: bookingRef.isEmpty ? null : bookingRef,
      bookingSlug: null,
      courseName:
          _readString(payload, const <String>[
            'golfClubName',
            'courseName',
            'clubName',
          ]) ??
          _readString(bookingSummary, const <String>[
            'golfClubName',
            'courseName',
            'clubName',
          ]) ??
          'Golf Club',
      courseSlug:
          _readNullableString(payload, const <String>[
            'golfClubSlug',
            'golf_club_slug',
            'courseSlug',
            'clubSlug',
          ]) ??
          _readNullableString(bookingSummary, const <String>[
            'golfClubSlug',
            'golf_club_slug',
            'courseSlug',
            'clubSlug',
          ]),
      dateLabel: _formatDateLabel(bookingDate),
      bookingDate: bookingDate.isEmpty ? null : bookingDate,
      timeLabel: _formatTimeLabel(teeTimeSlot),
      teeTimeSlot: teeTimeSlot.isEmpty ? '-' : teeTimeSlot,
      feeLabel: grandTotal == null
          ? '$currency --'
          : '$currency ${grandTotal.toStringAsFixed(0)}',
      statusLabel: statusLabel,
      statusColor: _statusColor(statusLabel),
      guestId: _readNullableString(payload, const <String>[
        'guestId',
        'guestCode',
      ]),
      hostName: hostName,
      hostPhoneNumber: hostPhone,
      playerCount:
          _readInt(payload, const <String>['playerCount', 'players']) ?? 1,
      normalPlayerCount:
          _readInt(payload, const <String>['normalPlayerCount']) ?? 0,
      seniorPlayerCount:
          _readInt(payload, const <String>['seniorPlayerCount']) ?? 0,
      caddieCount:
          _readInt(payload, const <String>['caddieCount', 'caddies']) ?? 0,
      golfCartCount:
          _readInt(payload, const <String>[
            'golfCartCount',
            'cartCount',
            'buggyCount',
          ]) ??
          0,
      playerDetails: playerDetails.isEmpty
          ? <BookingSubmissionPlayerModel>[
              BookingSubmissionPlayerModel(
                name: hostName,
                phoneNumber: hostPhone,
                isHost: true,
              ),
            ]
          : playerDetails,
      playType: _readNullableString(payload, const <String>[
        'playType',
        'play_type',
      ]),
      selectedNine: _readNullableString(payload, const <String>[
        'selectedNine',
        'selected_nine',
      ]),
      caddieArrangement: _readNullableString(payload, const <String>[
        'caddieArrangement',
        'caddie_arrangement',
      ]),
      buggyType: _readNullableString(payload, const <String>[
        'buggyType',
        'buggy_type',
      ]),
      buggySharingPreference: _readNullableString(payload, const <String>[
        'buggySharingPreference',
        'buggy_sharing_preference',
      ]),
      paymentMethod: _readNullableString(payload, const <String>[
        'paymentMethod',
        'payment_method',
      ]),
      currency: currency,
      grandTotal: grandTotal?.toDouble(),
      pendingCounterConfirmation: pendingCounterConfirmation,
      isPhoneVerified: payload['isPhoneVerified'] as bool?,
      createdAt: _readNullableString(payload, const <String>['createdAt']),
      updatedAt: _readNullableString(payload, const <String>['updatedAt']),
      holdExpiresAt: _readNullableString(payload, const <String>[
        'holdExpiresAt',
      ]),
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
        name: _readString(data, const <String>['name', 'playerName']) ?? '',
        phoneNumber:
            _readString(data, const <String>[
              'phoneNumber',
              'phone',
              'playerPhone',
            ]) ??
            '',
        category: _readString(data, const <String>[
          'category',
        ], fallback: 'normal')!,
        isHost: data['isHost'] as bool? ?? false,
      );
    }).toList();
  }

  String? _readString(
    Map<String, dynamic> item,
    List<String> keys, {
    String? fallback,
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
    return (value == null || value.isEmpty) ? null : value;
  }

  int? _readInt(Map<String, dynamic> item, List<String> keys) {
    final value = _readNum(item, keys);
    return value?.toInt();
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
    if (twentyFourMatch == null) {
      return rawTime;
    }

    final hour = int.parse(twentyFourMatch.group(1)!);
    final minute = twentyFourMatch.group(2)!;
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final normalizedHour = hour % 12 == 0 ? 12 : hour % 12;
    return '${normalizedHour.toString().padLeft(2, '0')}:$minute $suffix';
  }

  String _formatStatusLabel(String rawStatus) {
    if (rawStatus.trim().isEmpty) {
      return 'Confirmed';
    }

    final normalized = rawStatus.trim().toLowerCase();
    return normalized
        .split(RegExp(r'[_\s]+'))
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  Color _statusColor(String statusLabel) {
    switch (statusLabel.toLowerCase()) {
      case 'confirmed':
        return const Color(0xFF0D7A3A);
      case 'completed':
        return const Color(0xFF2A4EA0);
      case 'cancelled':
        return const Color(0xFFC62828);
      default:
        return const Color(0xFF6B7280);
    }
  }
}
