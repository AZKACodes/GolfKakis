import 'package:golf_kakis/features/home/course/details/data/course_details_repository.dart';
import 'package:golf_kakis/features/home/course/details/data/course_details_repository_impl.dart';
import 'package:golf_kakis/features/foundation/model/booking/golf_club_model.dart';

import 'course_details_use_case.dart';

class CourseDetailsUseCaseImpl implements CourseDetailsUseCase {
  const CourseDetailsUseCaseImpl();

  @override
  Future<CourseDetailsResult> fetchCourseDetails({
    required String slug,
    GolfClubModel? initialClub,
  }) {
    return CourseDetailsRepositoryImpl().onFetchCourseDetails(
      slug: slug,
      initialClub: initialClub,
    );
  }
}
