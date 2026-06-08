import 'dart:async';

import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:golf_kakis/features/booking/submission/slot/domain/booking_submission_slot_use_case.dart';
import 'package:golf_kakis/features/booking/submission/slot/viewmodel/booking_submission_slot_view_contract.dart'
    show isGolfClubEnabledForCurrentRelease;
import 'package:golf_kakis/features/foundation/model/data_status_model.dart';
import 'package:golf_kakis/features/foundation/model/golf_club_model.dart';
import 'package:golf_kakis/features/foundation/model/snackbar_message_model.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_view_model.dart';

import 'booking_submission_start_view_contract.dart';

class BookingSubmissionStartViewModel
    extends
        MviViewModel<
          BookingSubmissionStartUserIntent,
          BookingSubmissionStartViewState,
          BookingSubmissionStartNavEffect
        >
    implements BookingSubmissionStartViewContract {
  BookingSubmissionStartViewModel({
    required BookingSubmissionSlotUseCase useCase,
  }) : _useCase = useCase;

  final BookingSubmissionSlotUseCase _useCase;
  StreamSubscription<DataStatusModel<List<GolfClubModel>>>?
  _golfClubSubscription;
  Position? _currentPosition;

  @override
  BookingSubmissionStartViewState createInitialState() {
    return BookingSubmissionStartDataLoaded.initial;
  }

  @override
  FutureOr<void> handleIntent(BookingSubmissionStartUserIntent intent) {
    switch (intent) {
      case OnInitBookingSubmissionStart():
        return null;
      case OnFetchGolfClubList():
        return onFetchGolfClubList();
      case OnSelectStartGolfClub():
        emitViewState(
          (_) => _currentDataState.copyWith(
            selectedGolfClub: intent.club,
            clearErrorMessage: true,
          ),
        );
      case OnStartPlayerCountChanged():
        emitViewState(
          (_) => _currentDataState.copyWith(
            playerCount: intent.value.clamp(2, 6),
            clearErrorMessage: true,
          ),
        );
      case OnSortStartGolfClubsByNearbyClick():
        return _sortGolfClubsByNearby();
      case OnSearchBookingSlotsClick():
        final club = _currentDataState.selectedGolfClub;
        if (club == null) {
          const message = 'Please select a golf club before searching.';
          sendNavEffect(() => const ShowBookingSubmissionStartError(message));
          return null;
        }
        sendNavEffect(
          () => NavigateToBookingSubmissionSlotSelection(
            club: club,
            playerCount: _currentDataState.playerCount,
          ),
        );
      case OnBackClick():
        sendNavEffect(() => const NavigateBack());
    }
  }

  BookingSubmissionStartDataLoaded get currentDataState {
    return switch (currentState) {
      BookingSubmissionStartDataLoaded() =>
        currentState as BookingSubmissionStartDataLoaded,
    };
  }

  BookingSubmissionStartDataLoaded get _currentDataState => currentDataState;

  Future<void> onFetchGolfClubList() async {
    emitViewState(
      (_) => _currentDataState.copyWith(
        isLoadingGolfClubs: true,
        clearErrorMessage: true,
      ),
    );

    await _golfClubSubscription?.cancel();
    final completer = Completer<void>();
    _golfClubSubscription = _useCase.onFetchGolfClubList().listen((result) {
      switch (result.status) {
        case DataStatus.success:
          final clubs = _applyCurrentReleaseGolfClubAvailability(result.data);
          emitViewState(
            (_) => _currentDataState.copyWith(
              golfClubList: clubs,
              isLoadingGolfClubs: false,
              clearErrorMessage: true,
            ),
          );
          if (!completer.isCompleted) {
            completer.complete();
          }
        case DataStatus.error:
          final message = result.apiMessage.isEmpty
              ? 'Failed to fetch golf club list'
              : result.apiMessage;
          emitViewState(
            (_) => _currentDataState.copyWith(
              golfClubList: const <GolfClubModel>[],
              clearSelectedGolfClub: true,
              isLoadingGolfClubs: false,
              errorSnackbarMessageModel: SnackbarMessageModel(message: message),
            ),
          );
          sendNavEffect(() => ShowBookingSubmissionStartError(message));
          if (!completer.isCompleted) {
            completer.complete();
          }
        default:
          break;
      }
    });
    return completer.future;
  }

  Future<void> _sortGolfClubsByNearby() async {
    if (_currentDataState.isNearbySortActive) {
      final sorted = List<GolfClubModel>.of(_currentDataState.golfClubList)
        ..sort((left, right) => left.name.compareTo(right.name));
      emitViewState(
        (_) => _currentDataState.copyWith(
          golfClubList: sorted,
          isNearbySortActive: false,
          clearErrorMessage: true,
        ),
      );
      return;
    }

    final position = await _resolveCurrentPosition();
    if (position == null) {
      const message = 'Unable to get your current location.';
      sendNavEffect(() => const ShowBookingSubmissionStartError(message));
      return;
    }

    _currentPosition = position;
    final sorted = List<GolfClubModel>.of(_currentDataState.golfClubList)
      ..sort((left, right) {
        final leftDistance = _distanceFromCurrentPosition(left);
        final rightDistance = _distanceFromCurrentPosition(right);
        if (leftDistance == null && rightDistance == null) {
          return left.name.compareTo(right.name);
        }
        if (leftDistance == null) {
          return 1;
        }
        if (rightDistance == null) {
          return -1;
        }
        return leftDistance.compareTo(rightDistance);
      });

    emitViewState(
      (_) => _currentDataState.copyWith(
        golfClubList: sorted,
        isNearbySortActive: true,
        clearErrorMessage: true,
      ),
    );
  }

  Future<Position?> _resolveCurrentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      return Geolocator.getCurrentPosition();
    } on MissingPluginException {
      return null;
    } catch (_) {
      return null;
    }
  }

  double? _distanceFromCurrentPosition(GolfClubModel club) {
    final position = _currentPosition;
    if (position == null || club.latitude == null || club.longitude == null) {
      return null;
    }

    return Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      club.latitude!,
      club.longitude!,
    );
  }

  List<GolfClubModel> _applyCurrentReleaseGolfClubAvailability(
    List<GolfClubModel> clubs,
  ) {
    return clubs.map((club) {
      final isEnabled = isGolfClubEnabledForCurrentRelease(club);
      return club.copyWith(
        isEnabled: isEnabled,
        isBookable: isEnabled,
        availabilityLabel: isEnabled ? 'Booking available' : 'Coming soon',
      );
    }).toList();
  }

  @override
  void dispose() {
    _golfClubSubscription?.cancel();
    super.dispose();
  }
}
