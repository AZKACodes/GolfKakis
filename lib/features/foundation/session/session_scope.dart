import 'package:flutter/widgets.dart';

import 'session_manager.dart';

class SessionScope extends InheritedNotifier<SessionManager> {
  const SessionScope({
    required SessionManager sessionManager,
    required super.child,
    super.key,
  }) : super(notifier: sessionManager);

  static SessionManager of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SessionScope>();
    assert(scope != null, 'SessionScope is missing in the widget tree');
    return scope!.notifier!;
  }
}
