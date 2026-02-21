abstract class HomeViewContract {
  HomeViewState get viewState;
  Stream<HomeNavEffect> get navEffects;
  void onUserIntent(HomeUserIntent intent);
}

class HomeViewState {
  const HomeViewState({this.message, this.isLoading = false, this.error});

  final String? message;
  final bool isLoading;
  final String? error;

  HomeViewState copyWith({
    String? message,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return HomeViewState(
      message: message ?? this.message,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  static const initial = HomeViewState();
}

sealed class HomeUserIntent {
  const HomeUserIntent();
}

class LoadHomeDataIntent extends HomeUserIntent {
  const LoadHomeDataIntent();
}

sealed class NavEffect {
  const NavEffect();
}

sealed class HomeNavEffect extends NavEffect {
  const HomeNavEffect();
}
