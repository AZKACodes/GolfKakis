import 'package:golf_kakis/features/foundation/model/home_hot_deal_item.dart';

abstract class DealsRepository {
  Future<List<HomeHotDealItem>> onFetchDealsList();
}
