import 'package:golf_kakis/features/foundation/model/golf_club_model.dart';
import 'package:golf_kakis/features/home/course/details/data/course_details_repository.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_view_model.dart';

import '../domain/course_details_use_case.dart';
import 'course_details_view_contract.dart';

class CourseDetailsViewModel
    extends
        MviViewModel<
          CourseDetailsUserIntent,
          CourseDetailsViewState,
          CourseDetailsNavEffect
        >
    implements CourseDetailsViewContract {
  CourseDetailsViewModel({
    required String clubSlug,
    GolfClubModel? initialClub,
    required CourseDetailsUseCase useCase,
  }) : _clubSlug = clubSlug,
       _initialClub =
           initialClub ??
           GolfClubModel(
             id: '',
             slug: clubSlug,
             name: 'Golf Club',
             address: '',
             noOfHoles: 18,
           ),
       _useCase = useCase;

  final String _clubSlug;
  final GolfClubModel _initialClub;
  final CourseDetailsUseCase _useCase;

  @override
  CourseDetailsViewState createInitialState() {
    return CourseDetailsViewState.initial(_initialClub);
  }

  @override
  Future<void> handleIntent(CourseDetailsUserIntent intent) async {
    switch (intent) {
      case OnInit():
      case OnRefresh():
        await _loadDetailAndWeather();
      case OnBackClick():
        sendNavEffect(() => const NavigateBack());
      case OnBookNowClick():
      case OnQuickBookClick():
        sendNavEffect(() => const NavigateToBookingSubmission());
    }
  }

  Future<void> _loadDetailAndWeather() async {
    await _loadDetail();
    await _loadGolfCourseWeather();
  }

  Future<void> _loadDetail() async {
    emitViewState(
      (state) => state.copyWith(isLoading: true, clearErrorMessage: true),
    );

    try {
      final result = await _useCase.onInitCourseDetailInit(
        slug: _clubSlug,
        initialClub: _initialClub,
      );
      emitViewState(
        (state) => state.copyWith(
          detail: result.detail,
          isLoading: false,
          isUsingFallback: result.isFallback,
          clearErrorMessage: true,
        ),
      );
    } catch (_) {
      emitViewState(
        (state) => state.copyWith(
          isLoading: false,
          isUsingFallback: false,
          clearErrorMessage: true,
        ),
      );
    }
  }

  Future<void> _loadGolfCourseWeather() async {
    final currentDetail = getCurrentDetail();
    try {
      final weatherDetails = await _useCase.onFetchGolfCourseWeather(
        club: currentDetail.club,
      );
      emitViewState(
        (state) => state.copyWith(
          detail: _copyDetailWithWeather(
            detail: getCurrentDetail(),
            weatherDetails: weatherDetails,
          ),
          clearErrorMessage: true,
        ),
      );
    } catch (_) {
      // Keep the detail screen usable if weather cannot be loaded.
    }
  }

  CourseDetailsData getCurrentDetail() {
    final state = currentState;
    return switch (state) {
      CourseDetailsViewState() => state.detail,
    };
  }

  CourseDetailsData _copyDetailWithWeather({
    required CourseDetailsData detail,
    required CourseWeatherDetailsData weatherDetails,
  }) {
    return CourseDetailsData(
      club: detail.club,
      distanceLabel: detail.distanceLabel,
      openSlotsLabel: detail.openSlotsLabel,
      greenFeeLabel: detail.greenFeeLabel,
      peakLabel: detail.peakLabel,
      description: detail.description,
      bestForLabel: detail.bestForLabel,
      facilityLabels: detail.facilityLabels,
      photoUrls: detail.photoUrls,
      weather: weatherDetails.weather,
      weeklyForecast: weatherDetails.weeklyForecast,
      nextSlotLabel: detail.nextSlotLabel,
      bookingDateLabel: detail.bookingDateLabel,
    );
  }
}
