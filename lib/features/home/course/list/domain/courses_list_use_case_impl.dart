import '../data/courses_list_repository.dart';
import '../data/courses_list_repository_impl.dart';
import 'courses_list_use_case.dart';

class CoursesListUseCaseImpl implements CoursesListUseCase {
  CoursesListUseCaseImpl._(this._repository);

  factory CoursesListUseCaseImpl.create() {
    return CoursesListUseCaseImpl._(CoursesListRepositoryImpl());
  }

  final CoursesListRepository _repository;

  @override
  Future<CoursesListResult> onFetchCourseList() async {
    final clubs = await _repository.onFetchCoursesList();
    return CoursesListResult(clubs: clubs);
  }
}
