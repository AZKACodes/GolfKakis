import 'package:golf_kakis/features/foundation/model/booking/golf_club_model.dart';

import 'golf_club_detail_repository.dart';

class GolfClubDetailRepositoryImpl implements GolfClubDetailRepository {
  @override
  Future<GolfClubDetailResult> onFetchGolfClubDetail({
    required GolfClubModel club,
  }) async {
    return GolfClubDetailResult(
      detail: _buildFallbackDetail(club),
      isFallback: true,
    );
  }

  GolfClubDetailData _buildFallbackDetail(GolfClubModel club) {
    switch (club.slug) {
      case 'kinrara-golf-club':
        return GolfClubDetailData(
          club: club,
          distanceLabel: '9 km away',
          openSlotsLabel: '14 morning slots',
          greenFeeLabel: 'From MYR 39',
          peakLabel: 'Peak 7:20 AM',
          description:
              'A reliable early-morning option with steady pace of play, approachable greens, and good value for repeat weekday bookings.',
          bestForLabel: 'Best for quick morning rounds',
          facilityLabels: const [
            'Driving Range',
            'Locker Room',
            'Caddie Support',
            'Restaurant',
          ],
        );
      case 'saujana-golf-country-club':
        return GolfClubDetailData(
          club: club,
          distanceLabel: '15 km away',
          openSlotsLabel: '11 morning slots',
          greenFeeLabel: 'From MYR 52',
          peakLabel: 'Peak 8:00 AM',
          description:
              'A premium club experience with fuller facilities, strong weekend demand, and polished hospitality for hosted rounds.',
          bestForLabel: 'Best for hosted or premium rounds',
          facilityLabels: const [
            '36 Holes',
            'Practice Green',
            'Valet Access',
            'Club Lounge',
          ],
        );
      case 'mines-resort-golf-club':
        return GolfClubDetailData(
          club: club,
          distanceLabel: '21 km away',
          openSlotsLabel: '9 morning slots',
          greenFeeLabel: 'From MYR 47',
          peakLabel: 'Peak 7:40 AM',
          description:
              'A scenic championship-style round with strong demand in the first wave and a nice balance of challenge and accessibility.',
          bestForLabel: 'Best for scenic championship play',
          facilityLabels: const [
            'Championship Layout',
            'Buggy Service',
            'Pro Shop',
            'Lakefront Views',
          ],
        );
      default:
        return GolfClubDetailData(
          club: club,
          distanceLabel: '18 km away',
          openSlotsLabel: '10 open slots',
          greenFeeLabel: 'From MYR 45',
          peakLabel: 'Peak 7:45 AM',
          description:
              'A flexible option with balanced availability and a comfortable setup for both casual and focused rounds.',
          bestForLabel: 'Best for balanced value and access',
          facilityLabels: const [
            'Practice Area',
            'Cafe',
            'Changing Room',
            'Golf Shop',
          ],
        );
    }
  }
}
