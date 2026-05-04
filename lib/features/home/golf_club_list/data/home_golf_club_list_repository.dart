import 'package:golf_kakis/features/foundation/model/booking/golf_club_model.dart';

abstract class HomeGolfClubListRepository {
  Future<List<GolfClubModel>> onFetchGolfClubList();
}
