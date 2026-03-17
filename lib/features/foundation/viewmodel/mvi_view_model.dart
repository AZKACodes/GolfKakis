import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_contract.dart';

abstract class MviViewModel<
  Intent extends UserIntent,
  State extends ViewState,
  Effect extends NavEffect
>
    extends ChangeNotifier {
  MviViewModel() {
    _intentSubscription = _intentController.stream.listen(handleIntent);
  }

  late final State _initialState = createInitialState();
  late State _viewState = _initialState;

  final StreamController<Intent> _intentController =
      StreamController<Intent>.broadcast();
  final StreamController<Effect> _navEffectController =
      StreamController<Effect>.broadcast();

  StreamSubscription<Intent>? _intentSubscription;
  Timer? _debounceTimer;
  Duration? _debounceDuration;

  State createInitialState();

  FutureOr<void> handleIntent(Intent intent);

  State get currentState => _viewState;

  State get viewState => _viewState;

  Stream<Effect> get navEffects => _navEffectController.stream;

  void onUserIntent(Intent intent) {
    performAction(intent);
  }

  void performAction(Intent intent) {
    if (_intentController.isClosed) {
      return;
    }

    _intentController.add(intent);
  }

  @protected
  void emitViewState(State Function(State state) reduce) {
    _viewState = reduce(currentState);
    notifyListeners();
  }

  @protected
  void sendNavEffect(Effect Function() builder) {
    if (_navEffectController.isClosed) {
      return;
    }

    _navEffectController.add(builder());
  }

  void subscribeToDebounceIntent(Duration debounceDuration) {
    _debounceDuration = debounceDuration;
  }

  void performDebounceAction(Intent intent) {
    final debounceDuration = _debounceDuration;
    if (debounceDuration == null) {
      performAction(intent);
      return;
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounceDuration, () {
      performAction(intent);
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _intentSubscription?.cancel();
    _intentController.close();
    _navEffectController.close();
    super.dispose();
  }
}
