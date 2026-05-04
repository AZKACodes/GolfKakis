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
  Future<HomeOverviewResult> onFetchHomeOverviewDetails() async {
    final message = await _repository.onFetchWelcomeMessage();
    final hotDeals = await _repository.onFetchHotDeals();
    final quickBookItems = await _repository.onFetchQuickBookItems();

    return HomeOverviewResult(
      message: message,
      hotDeals: hotDeals,
      quickBookItems: quickBookItems,
    );
  }
}
