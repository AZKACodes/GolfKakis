import 'package:golf_kakis/features/foundation/model/booking/golf_club_model.dart';

abstract class CoursesListRepository {
  Future<List<GolfClubModel>> onFetchCoursesList();
}
