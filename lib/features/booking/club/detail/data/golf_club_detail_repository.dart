import 'package:golf_kakis/features/foundation/model/booking/golf_club_model.dart';

class GolfClubDetailData {
  const GolfClubDetailData({
    required this.club,
    required this.distanceLabel,
    required this.openSlotsLabel,
    required this.greenFeeLabel,
    required this.peakLabel,
    required this.description,
    required this.bestForLabel,
    required this.facilityLabels,
  });

  final GolfClubModel club;
  final String distanceLabel;
  final String openSlotsLabel;
  final String greenFeeLabel;
  final String peakLabel;
  final String description;
  final String bestForLabel;
  final List<String> facilityLabels;
}

class GolfClubDetailResult {
  const GolfClubDetailResult({required this.detail, required this.isFallback});

  final GolfClubDetailData detail;
  final bool isFallback;
}

abstract class GolfClubDetailRepository {
  Future<GolfClubDetailResult> onFetchGolfClubDetail({
    required GolfClubModel club,
  });
}
