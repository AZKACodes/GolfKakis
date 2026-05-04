import 'package:golf_kakis/features/foundation/model/home/home_hot_deal_item.dart';
import 'package:golf_kakis/features/foundation/model/home/home_quick_book_item.dart';

class HomeOverviewResult {
  const HomeOverviewResult({
    required this.message,
    required this.hotDeals,
    required this.quickBookItems,
  });

  final String message;
  final List<HomeHotDealItem> hotDeals;
  final List<HomeQuickBookItem> quickBookItems;
}

abstract class HomeOverviewUseCase {
  Future<HomeOverviewResult> onFetchHomeOverviewDetails();
}
