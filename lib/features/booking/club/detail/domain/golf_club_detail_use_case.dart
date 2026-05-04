import 'package:golf_kakis/features/booking/club/detail/data/golf_club_detail_repository.dart';
import 'package:golf_kakis/features/foundation/model/booking/golf_club_model.dart';

abstract class GolfClubDetailUseCase {
  Future<GolfClubDetailResult> fetchGolfClubDetail({
    required String slug,
    GolfClubModel? initialClub,
  });
}
