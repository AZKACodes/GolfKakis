import 'package:golf_kakis/features/home/course/details/data/course_details_repository.dart';
import 'package:golf_kakis/features/foundation/model/booking/golf_club_model.dart';

abstract class CourseDetailsUseCase {
  Future<CourseDetailsResult> fetchCourseDetails({
    required String slug,
    GolfClubModel? initialClub,
  });
}
