import '../data/home_repository.dart';

class GetHomeMessageUseCase {
  GetHomeMessageUseCase(this._repository);

  final HomeRepository _repository;

  Future<String> call() {
    return _repository.fetchWelcomeMessage();
  }
}
