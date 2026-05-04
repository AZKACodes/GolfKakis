import 'package:golf_kakis/features/booking/submission/slot/data/booking_submission_slot_repository.dart';
import 'package:golf_kakis/features/booking/submission/slot/data/booking_submission_slot_repository_impl.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_hold_request_model.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_submission_request_model.dart';
import 'package:golf_kakis/features/booking/submission/slot/domain/booking_submission_slot_use_case.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_slot_model.dart';
import 'package:golf_kakis/features/foundation/model/booking/golf_club_model.dart';
import 'package:golf_kakis/features/foundation/model/data_status_model.dart';
import 'package:golf_kakis/features/foundation/network/api_exception.dart';
import 'package:golf_kakis/features/foundation/util/default_constant_util.dart';

class BookingSubmissionSlotUseCaseImpl implements BookingSubmissionSlotUseCase {
  factory BookingSubmissionSlotUseCaseImpl.create() {
    return BookingSubmissionSlotUseCaseImpl(
      BookingSubmissionSlotRepositoryImpl(),
    );
  }

  BookingSubmissionSlotUseCaseImpl(this._repository);

  // ignore: unused_field
  final BookingSubmissionSlotRepository _repository;
  Map<String, dynamic>? _lastMockHeldBooking;
  Map<String, dynamic>? _lastMockSubmittedBooking;

  @override
  Stream<DataStatusModel<List<GolfClubModel>>> onFetchGolfClubList() async* {
    try {
      // final clubs = await _repository.onFetchGolfClubList();
      final clubs = _mockGolfClubList();

      yield DataStatusModel<List<GolfClubModel>>(
        data: clubs,
        status: DataStatus.success,
      );
    } on ApiException catch (error) {
      yield DataStatusModel<List<GolfClubModel>>(
        data: const <GolfClubModel>[],
        status: DataStatus.error,
        apiMessage: error.message,
        rawResponseCode: error.statusCode ?? 0,
      );
    } catch (error) {
      yield DataStatusModel<List<GolfClubModel>>(
        data: const <GolfClubModel>[],
        status: DataStatus.error,
        apiMessage: _messageFromError(error),
      );
    }
  }

  @override
  Stream<DataStatusModel<List<BookingSlotModel>>> onFetchAvailableSlots({
    required String clubSlug,
    required String date,
    required String playType,
    String? selectedNine,
  }) async* {
    try {
      // final slotModels = await _repository.onFetchAvailableSlots(
      //   clubSlug: clubSlug,
      //   date: date,
      //   playType: playType,
      //   selectedNine: selectedNine,
      // );
      final slotModels = _mockAvailableSlots(
        clubSlug: clubSlug,
        date: date,
        playType: playType,
      );

      yield DataStatusModel<List<BookingSlotModel>>(
        data: slotModels,
        status: DataStatus.success,
      );
    } on ApiException catch (error) {
      yield DataStatusModel<List<BookingSlotModel>>(
        data: const <BookingSlotModel>[],
        status: DataStatus.error,
        apiMessage: error.message,
        rawResponseCode: error.statusCode ?? 0,
      );
    } catch (error) {
      yield DataStatusModel<List<BookingSlotModel>>(
        data: const <BookingSlotModel>[],
        status: DataStatus.error,
        apiMessage: _messageFromError(error),
      );
    }
  }

  @override
  Stream<DataStatusModel<dynamic>> onCreateBookingHold({
    required BookingHoldRequestModel request,
  }) async* {
    try {
      // final response = await _repository.onCreateBookingHold(request: request);
      final response = _mockBookingHoldResponse(request);

      yield DataStatusModel<dynamic>(
        data: response,
        status: DataStatus.success,
      );
    } on ApiException catch (error) {
      yield DataStatusModel<dynamic>(
        data: const EmptyType(),
        status: DataStatus.error,
        apiMessage: error.message,
        rawResponseCode: error.statusCode ?? 0,
      );
    } catch (error) {
      yield DataStatusModel<dynamic>(
        data: const EmptyType(),
        status: DataStatus.error,
        apiMessage: _messageFromError(error),
      );
    }
  }

  @override
  Stream<DataStatusModel<dynamic>> onCreateBookingSubmission({
    required BookingSubmissionRequestModel request,
  }) async* {
    try {
      // final response = await _repository.onCreateBookingSubmission(
      //   request: request,
      // );
      final response = _mockBookingSubmissionResponse(request);

      yield DataStatusModel<dynamic>(
        data: response,
        status: DataStatus.success,
      );
    } on ApiException catch (error) {
      yield DataStatusModel<dynamic>(
        data: const EmptyType(),
        status: DataStatus.error,
        apiMessage: error.message,
        rawResponseCode: error.statusCode ?? 0,
      );
    } catch (error) {
      yield DataStatusModel<dynamic>(
        data: const EmptyType(),
        status: DataStatus.error,
        apiMessage: _messageFromError(error),
      );
    }
  }

  @override
  Stream<DataStatusModel<dynamic>> onFetchBookingDetails({
    required String bookingRef,
  }) async* {
    try {
      // final response = await _repository.onFetchBookingDetails(
      //   bookingRef: bookingRef,
      // );
      final response = _mockBookingDetailsResponse(bookingRef);

      yield DataStatusModel<dynamic>(
        data: response,
        status: DataStatus.success,
      );
    } on ApiException catch (error) {
      yield DataStatusModel<dynamic>(
        data: const EmptyType(),
        status: DataStatus.error,
        apiMessage: error.message,
        rawResponseCode: error.statusCode ?? 0,
      );
    } catch (error) {
      yield DataStatusModel<dynamic>(
        data: const EmptyType(),
        status: DataStatus.error,
        apiMessage: _messageFromError(error),
      );
    }
  }

  String _messageFromError(Object error) {
    if (error is ApiException) {
      return error.message;
    }

    final raw = error.toString();
    final exceptionPrefix = RegExp(r'^[A-Za-z]+Exception:\s*');
    final cleaned = raw.replaceFirst(exceptionPrefix, '').trim();
    return cleaned.isEmpty ? 'Request failed.' : cleaned;
  }

  List<GolfClubModel> _mockGolfClubList() {
    return const <GolfClubModel>[
      GolfClubModel(
        id: 'mock-club-kinrara',
        slug: 'kinrara-golf-club',
        name: 'Kinrara Golf Club',
        address: 'Puchong, Selangor',
        noOfHoles: 18,
      ),
    ];
  }

  List<BookingSlotModel> _mockAvailableSlots({
    required String clubSlug,
    required String date,
    required String playType,
  }) {
    final baseDate = DateTime.tryParse(date) ?? DateTime.now();
    const rawSlots =
        <
          ({
            String id,
            String time,
            double price,
            int holes,
            int capacity,
            bool isAvailable,
          })
        >[
          (
            id: 'slot-0730',
            time: '07:30 AM',
            price: 180,
            holes: 18,
            capacity: 4,
            isAvailable: true,
          ),
          (
            id: 'slot-0815',
            time: '08:15 AM',
            price: 168,
            holes: 18,
            capacity: 4,
            isAvailable: true,
          ),
          (
            id: 'slot-0930',
            time: '09:30 AM',
            price: 155,
            holes: 18,
            capacity: 2,
            isAvailable: true,
          ),
          (
            id: 'slot-1200',
            time: '12:00 PM',
            price: 149,
            holes: 18,
            capacity: 4,
            isAvailable: false,
          ),
          (
            id: 'slot-1315',
            time: '01:15 PM',
            price: 142,
            holes: 18,
            capacity: 4,
            isAvailable: true,
          ),
          (
            id: 'slot-1400',
            time: '02:00 PM',
            price: 135,
            holes: 18,
            capacity: 6,
            isAvailable: true,
          ),
          (
            id: 'slot-1430',
            time: '02:30 PM',
            price: 130,
            holes: 18,
            capacity: 6,
            isAvailable: true,
          ),
        ];

    return rawSlots.map((slot) {
      final startAt = _dateTimeForSlot(baseDate, slot.time);
      return BookingSlotModel(
        slotId: '${clubSlug}_${slot.id}',
        time: slot.time,
        price: slot.price,
        noOfHoles: slot.holes,
        currency: DefaultConstantUtil.defaultCurrency,
        startAt: startAt,
        endAt: startAt?.add(const Duration(minutes: 15)),
        remainingPlayerCapacity: slot.capacity,
        remainingCaddieCapacity: slot.capacity,
        remainingGolfCartCapacity: slot.capacity <= 2 ? 1 : 2,
        isAvailable: slot.isAvailable,
      );
    }).toList();
  }

  Map<String, dynamic> _mockBookingHoldResponse(
    BookingHoldRequestModel request,
  ) {
    final bookingRef =
        'BK-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final bookingId = 'mock-booking-${DateTime.now().millisecondsSinceEpoch}';
    final holdExpiresAt = DateTime.now().add(const Duration(minutes: 5));
    final response = <String, dynamic>{
      'bookingId': bookingId,
      'bookingRef': bookingRef,
      'holdDurationSeconds': 300,
      'holdExpiresAt': holdExpiresAt.toIso8601String(),
      'status': 'held',
      'bookingSummary': <String, dynamic>{
        'bookingId': bookingId,
        'bookingRef': bookingRef,
        'bookingDate': request.bookingDate,
        'golfClubName': request.golfClubName,
        'golfClubSlug': request.golfClubSlug,
        'teeTimeSlot': request.teeTimeSlot,
        'playType': request.playType ?? '18_holes',
        'playerCount': request.playerCount ?? 2,
        'normalPlayerCount':
            request.normalPlayerCount ?? request.playerCount ?? 2,
        'seniorPlayerCount': request.seniorPlayerCount,
        'selectedNine': request.selectedNine,
        'caddieCount': request.caddieCount,
        'golfCartCount': request.golfCartCount,
        'pricing': <String, dynamic>{
          'currency': DefaultConstantUtil.defaultCurrency,
        },
      },
      'hostUser': <String, dynamic>{
        'name': request.hostName,
        'phoneNumber': request.hostPhoneNumber,
      },
    };
    _lastMockHeldBooking = response;
    return response;
  }

  Map<String, dynamic> _mockBookingSubmissionResponse(
    BookingSubmissionRequestModel request,
  ) {
    final held = _lastMockHeldBooking;
    final bookingId =
        held?['bookingId']?.toString() ??
        'mock-booking-${DateTime.now().millisecondsSinceEpoch}';
    final response = <String, dynamic>{
      'bookingId': bookingId,
      'bookingRef': request.bookingRef,
      'status': 'confirmed',
      'data': <String, dynamic>{
        'bookingId': bookingId,
        'bookingRef': request.bookingRef,
        'playerDetails': request.playerDetails
            .map((player) => player.toJson())
            .toList(),
      },
    };
    _lastMockSubmittedBooking = response;
    return response;
  }

  Map<String, dynamic> _mockBookingDetailsResponse(String bookingRef) {
    final held = _lastMockHeldBooking;
    final submitted = _lastMockSubmittedBooking;
    final bookingSummary =
        held?['bookingSummary'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final hostUser =
        held?['hostUser'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final submittedData =
        submitted?['data'] as Map<String, dynamic>? ?? <String, dynamic>{};

    return <String, dynamic>{
      'data': <String, dynamic>{
        'bookingId':
            held?['bookingId']?.toString() ??
            'mock-booking-${DateTime.now().millisecondsSinceEpoch}',
        'bookingRef': bookingRef,
        'bookingDate':
            bookingSummary['bookingDate']?.toString() ??
            DateTime.now().toIso8601String().split('T').first,
        'golfClubName':
            bookingSummary['golfClubName']?.toString() ?? 'Mock Golf Club',
        'golfClubSlug':
            bookingSummary['golfClubSlug']?.toString() ?? 'mock-golf-club',
        'teeTimeSlot': bookingSummary['teeTimeSlot']?.toString() ?? '07:30 AM',
        'playType': bookingSummary['playType']?.toString() ?? '18_holes',
        'pricePerPerson': 180,
        'currency': DefaultConstantUtil.defaultCurrency,
        'hostName': hostUser['name']?.toString() ?? 'Mock Host',
        'hostPhoneNumber':
            hostUser['phoneNumber']?.toString() ?? '+60123456789',
        'playerCount':
            bookingSummary['playerCount'] as int? ??
            submittedData['playerDetails']?.length ??
            2,
        'caddieCount': bookingSummary['caddieCount'] as int? ?? 0,
        'golfCartCount': bookingSummary['golfCartCount'] as int? ?? 1,
        'playerDetails':
            submittedData['playerDetails'] as List<dynamic>? ??
            <Map<String, dynamic>>[
              <String, dynamic>{
                'name': hostUser['name']?.toString() ?? 'Mock Host',
                'phoneNumber':
                    hostUser['phoneNumber']?.toString() ?? '+60123456789',
                'category': 'normal',
              },
            ],
      },
    };
  }

  DateTime? _dateTimeForSlot(DateTime date, String timeLabel) {
    final parts = timeLabel.split(' ');
    if (parts.length != 2) {
      return null;
    }
    final timeParts = parts.first.split(':');
    if (timeParts.length != 2) {
      return null;
    }

    final hour = int.tryParse(timeParts.first);
    final minute = int.tryParse(timeParts.last);
    if (hour == null || minute == null) {
      return null;
    }

    var hour24 = hour % 12;
    if (parts.last.toUpperCase() == 'PM') {
      hour24 += 12;
    }

    return DateTime(date.year, date.month, date.day, hour24, minute);
  }
}
