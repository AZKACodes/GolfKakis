abstract class HomeViewContract {
  String? get message;
  bool get isLoading;
  String? get error;

  Future<void> loadData();
}
