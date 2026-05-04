import 'package:golf_kakis/features/foundation/model/home/home_user_details_item.dart';

import '../data/home_repository.dart';
import '../data/home_repository_impl.dart';
import 'home_overview_use_case.dart';

class HomeOverviewUseCaseImpl implements HomeOverviewUseCase {
  HomeOverviewUseCaseImpl._(this._repository);

  factory HomeOverviewUseCaseImpl.create() {
    return HomeOverviewUseCaseImpl._(HomeRepositoryImpl());
  }

  final HomeRepository _repository;

  @override
  Future<HomeOverviewResult> onHomeOverviewInit({
    required bool isLoggedIn,
    String? accessToken,
  }) async {
    final userDetailsFuture =
        isLoggedIn && accessToken != null && accessToken.trim().isNotEmpty
        ? _repository.onFetchUserDetails(accessToken: accessToken)
        : Future<HomeUserDetailsItem?>.value(null);
    final advertisementsFuture = _repository.onFetchAdvertisementList();
    final dealsFuture = _repository.onFetchDealsList();

    final userDetails = await userDetailsFuture;
    final advertisements = await advertisementsFuture;
    final deals = await dealsFuture;

    return HomeOverviewResult(
      userDetails: userDetails,
      advertisements: advertisements,
      deals: deals,
    );
  }
}
