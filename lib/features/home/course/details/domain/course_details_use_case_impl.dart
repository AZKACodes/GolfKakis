import 'package:golf_kakis/features/home/course/details/data/course_details_repository.dart';
import 'package:golf_kakis/features/home/course/details/data/course_details_repository_impl.dart';
import 'package:golf_kakis/features/foundation/model/booking/golf_club_model.dart';

import 'course_details_use_case.dart';

class CourseDetailsUseCaseImpl implements CourseDetailsUseCase {
  const CourseDetailsUseCaseImpl({
    CourseDetailsRepository? repository,
  }) : _repository = repository;

  final CourseDetailsRepository? _repository;

  CourseDetailsRepository get _resolvedRepository =>
      _repository ?? CourseDetailsRepositoryImpl();

  @override
  Future<CourseDetailsResult> onInitCourseDetailInit({
    required String slug,
    GolfClubModel? initialClub,
  }) async {
    final headerDetails = await _resolvedRepository.onFetchCourseDetails(
      slug: slug,
      initialClub: initialClub,
    );

    final results = await Future.wait<Object>([
      _resolvedRepository.onFetchCourseExtraDetails(
        slug: slug,
        club: headerDetails.club,
      ),
      _resolvedRepository.onFetchCourseWeather(club: headerDetails.club),
    ]);

    final extraDetails = results[0] as CourseExtraDetailsData;
    final weatherDetails = results[1] as CourseWeatherDetailsData;

    return CourseDetailsResult(
      detail: CourseDetailsData(
        club: headerDetails.club,
        distanceLabel: headerDetails.distanceLabel,
        openSlotsLabel: headerDetails.openSlotsLabel,
        greenFeeLabel: headerDetails.greenFeeLabel,
        peakLabel: headerDetails.peakLabel,
        description: extraDetails.description,
        bestForLabel: headerDetails.bestForLabel,
        facilityLabels: extraDetails.facilityLabels,
        photoUrls: extraDetails.photoUrls,
        weather: weatherDetails.weather,
        weeklyForecast: weatherDetails.weeklyForecast,
        nextSlotLabel: headerDetails.nextSlotLabel,
        bookingDateLabel: headerDetails.bookingDateLabel,
      ),
      isFallback: false,
    );
  }
}
