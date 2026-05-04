import 'package:golf_kakis/features/booking/club/detail/data/golf_club_detail_repository.dart';
import 'package:golf_kakis/features/booking/club/detail/data/golf_club_detail_repository_impl.dart';
import 'package:golf_kakis/features/foundation/model/booking/golf_club_model.dart';

import 'golf_club_detail_use_case.dart';

class GolfClubDetailUseCaseImpl implements GolfClubDetailUseCase {
  const GolfClubDetailUseCaseImpl();

  @override
  Future<GolfClubDetailResult> fetchGolfClubDetail({
    required String slug,
    GolfClubModel? initialClub,
  }) {
    return GolfClubDetailRepositoryImpl().onFetchGolfClubDetail(
      slug: slug,
      initialClub: initialClub,
    );
  }
}
