abstract class RootViewContract {
  RootViewState get viewState;
  Stream<RootNavEffect> get navEffects;
  void onUserIntent(RootUserIntent intent);
}

class RootViewState {
  const RootViewState({required this.currentIndex});

  final int currentIndex;

  RootViewState copyWith({int? currentIndex}) {
    return RootViewState(currentIndex: currentIndex ?? this.currentIndex);
  }

  static const initial = RootViewState(currentIndex: 0);
}

sealed class RootUserIntent {
  const RootUserIntent();
}

class RootTabSelectedIntent extends RootUserIntent {
  const RootTabSelectedIntent(this.index);

  final int index;
}

sealed class NavEffect {
  const NavEffect();
}

sealed class RootNavEffect extends NavEffect {
  const RootNavEffect();
}

class RootTabChangedNavEffect extends RootNavEffect {
  const RootTabChangedNavEffect(this.index);

  final int index;
}
