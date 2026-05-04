import 'package:golf_kakis/features/foundation/model/booking/golf_club_model.dart';

import '../data/home_golf_club_list_repository.dart';
import '../data/home_golf_club_list_repository_impl.dart';
import 'home_golf_club_list_use_case.dart';

class HomeGolfClubListUseCaseImpl implements HomeGolfClubListUseCase {
  HomeGolfClubListUseCaseImpl._(this._repository);

  factory HomeGolfClubListUseCaseImpl.create() {
    return HomeGolfClubListUseCaseImpl._(HomeGolfClubListRepositoryImpl());
  }

  final HomeGolfClubListRepository _repository;

  @override
  Future<List<GolfClubModel>> onFetchGolfClubList() {
    return _repository.onFetchGolfClubList();
  }
}
