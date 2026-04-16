import 'package:golf_kakis/features/foundation/network/network.dart';
import 'package:golf_kakis/features/foundation/model/booking/golf_club_model.dart';

import 'golf_club_detail_repository.dart';

class GolfClubDetailRepositoryImpl implements GolfClubDetailRepository {
  @override
  Future<GolfClubDetailResult> onFetchGolfClubDetail({
    required GolfClubModel club,
  }) async {
    throw ApiException(
      message: 'Golf club detail endpoint is not configured yet.',
    );
  }
}
