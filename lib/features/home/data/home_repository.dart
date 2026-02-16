abstract class HomeRepository {
  Future<String> fetchWelcomeMessage();
}

class HomeRepositoryImpl implements HomeRepository {
  @override
  Future<String> fetchWelcomeMessage() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return 'Welcome to Home';
  }
}
