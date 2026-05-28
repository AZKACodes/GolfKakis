import '../data/deals_repository.dart';
import '../data/deals_repository_impl.dart';
import 'deals_use_case.dart';

class DealsUseCaseImpl implements DealsUseCase {
  DealsUseCaseImpl._(this._repository);

  factory DealsUseCaseImpl.create() {
    return DealsUseCaseImpl._(DealsRepositoryImpl());
  }

  final DealsRepository _repository;

  @override
  Future<DealsResult> onFetchDealsList() async {
    final deals = await _repository.onFetchDealsList();
    return DealsResult(deals: deals);
  }
}
