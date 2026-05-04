import 'package:golf_kakis/features/foundation/model/home/home_advertisement_item.dart';
import 'package:golf_kakis/features/foundation/model/home/home_hot_deal_item.dart';
import 'package:golf_kakis/features/foundation/model/home/home_user_details_item.dart';

class HomeOverviewResult {
  const HomeOverviewResult({
    required this.userDetails,
    required this.advertisements,
    required this.deals,
  });

  final HomeUserDetailsItem? userDetails;
  final List<HomeAdvertisementItem> advertisements;
  final List<HomeHotDealItem> deals;
}

abstract class HomeOverviewUseCase {
  Future<HomeOverviewResult> onHomeOverviewInit({
    required bool isLoggedIn,
    String? accessToken,
  });
}
