import 'package:golf_kakis/features/foundation/model/booking/golf_club_model.dart';

class CoursesListResult {
  const CoursesListResult({required this.clubs});

  final List<GolfClubModel> clubs;
}

abstract class CoursesListUseCase {
  Future<CoursesListResult> onFetchCourseList();
}
