import 'package:golf_kakis/features/foundation/model/home_hot_deal_item.dart';

class DealsResult {
  const DealsResult({required this.deals});

  final List<HomeHotDealItem> deals;
}

abstract class DealsUseCase {
  Future<DealsResult> onFetchDealsList();
}
