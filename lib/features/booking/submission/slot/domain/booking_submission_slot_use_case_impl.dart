import 'package:golf_kakis/features/booking/submission/slot/data/booking_submission_slot_repository.dart';
import 'package:golf_kakis/features/booking/submission/slot/data/booking_submission_slot_repository_impl.dart';
import 'package:golf_kakis/features/foundation/default_values.dart';
import 'package:golf_kakis/features/foundation/model/request/booking_hold_request_model.dart';
import 'package:golf_kakis/features/foundation/model/request/booking_submission_request_model.dart';
import 'package:golf_kakis/features/booking/submission/slot/domain/booking_submission_slot_use_case.dart';
import 'package:golf_kakis/features/foundation/model/booking_slot_model.dart';
import 'package:golf_kakis/features/foundation/model/booking_slot_details_model.dart';
import 'package:golf_kakis/features/foundation/model/golf_club_model.dart';
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

  final BookingSubmissionSlotRepository _repository;
  Map<String, dynamic>? _lastMockHeldBooking;
  Map<String, dynamic>? _lastMockSubmittedBooking;

  @override
  Stream<DataStatusModel<List<GolfClubModel>>> onFetchGolfClubList() async* {
    try {
      final clubs = await _repository.onFetchGolfClubList();

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
    required int playerCount,
    String? selectedNine,
  }) async* {
    try {
      final slotModels = await _repository.onFetchAvailableSlots(
        clubSlug: clubSlug,
        date: date,
        playType: playType,
        playerCount: playerCount,
        selectedNine: selectedNine,
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
  Stream<DataStatusModel<BookingSlotDetailsModel>> onFetchSlotDetails({
    required String slotId,
    required String clubSlug,
    required String date,
    required String playType,
    required int playerCount,
    String? selectedNine,
  }) async* {
    try {
      final response = await _repository.onFetchSlotDetails(
        slotId: slotId,
        clubSlug: clubSlug,
        date: date,
        playType: playType,
        playerCount: playerCount,
        selectedNine: selectedNine,
      );

      yield DataStatusModel<BookingSlotDetailsModel>(
        data: response,
        status: DataStatus.success,
      );
    } on ApiException catch (error) {
      yield DataStatusModel<BookingSlotDetailsModel>(
        data: _emptySlotDetails(),
        status: DataStatus.error,
        apiMessage: error.message,
        rawResponseCode: error.statusCode ?? 0,
      );
    } catch (error) {
      yield DataStatusModel<BookingSlotDetailsModel>(
        data: _emptySlotDetails(),
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
      final response = await _repository.onCreateBookingHold(request: request);

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
  Stream<DataStatusModel<dynamic>> onExtendBookingHold({
    required String bookingRef,
    required String accessToken,
  }) async* {
    try {
      final response = await _repository.onExtendBookingHold(
        bookingRef: bookingRef,
        accessToken: accessToken,
      );

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
  Stream<DataStatusModel<dynamic>> onPreviewBooking({
    required String accessToken,
    required Map<String, dynamic> request,
  }) async* {
    try {
      final response = await _repository.onPreviewBooking(
        accessToken: accessToken,
        request: request,
      );

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
      final response = await _repository.onCreateBookingSubmission(
        request: request,
      );

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

  BookingSlotDetailsModel _emptySlotDetails() {
    return BookingSlotDetailsModel(
      quoteId: emptyString,
      slotId: emptyString,
      golfClubSlug: emptyString,
      golfClubName: emptyString,
      bookingDate: DateTime.now(),
      teeTimeSlot: emptyString,
      noOfHoles: 0,
      playerCount: 0,
      playType: emptyString,
      currency: DefaultConstantUtil.defaultCurrency,
      pricePerPerson: 0,
      totalEstimate: 0,
    );
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
}
