import 'package:golf_kakis/features/booking/submission/slot/data/booking_submission_slot_repository.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_hold_request_model.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_submission_request_model.dart';
import 'package:golf_kakis/features/booking/submission/slot/domain/booking_submission_slot_use_case.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_slot_model.dart';
import 'package:golf_kakis/features/foundation/model/booking/golf_club_model.dart';
import 'package:golf_kakis/features/foundation/model/data_status_model.dart';
import 'package:golf_kakis/features/foundation/network/api_exception.dart';

class BookingSubmissionSlotUseCaseImpl implements BookingSubmissionSlotUseCase {
  BookingSubmissionSlotUseCaseImpl(this._repository);

  final BookingSubmissionSlotRepository _repository;

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
    String? selectedNine,
  }) async* {
    try {
      final slotModels = await _repository.onFetchAvailableSlots(
        clubSlug: clubSlug,
        date: date,
        playType: playType,
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
    required String bookingSlug,
  }) async* {
    try {
      final response = await _repository.onFetchBookingDetails(
        bookingSlug: bookingSlug,
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

  String _messageFromError(Object error) {
    if (error is ApiException) {
      return error.message;
    }

    final raw = error.toString();
    final exceptionPrefix = RegExp(r'^[A-Za-z]+Exception:\s*');
    final cleaned = raw.replaceFirst(exceptionPrefix, '').trim();
    return cleaned.isEmpty ? 'Request failed.' : cleaned;
  }
}
