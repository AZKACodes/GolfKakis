import '../data/stay_play_repository.dart';
import '../data/stay_play_repository_impl.dart';
import 'stay_play_use_case.dart';

class StayPlayUseCaseImpl implements StayPlayUseCase {
  StayPlayUseCaseImpl._(this._repository);

  factory StayPlayUseCaseImpl.create() {
    return StayPlayUseCaseImpl._(StayPlayRepositoryImpl());
  }

  final StayPlayRepository _repository;

  @override
  Future<StayPlayResult> onFetchStayPlay() async {
    final items = await _repository.onFetchStayPlay();
    return StayPlayResult(items: items);
  }
}
