import 'package:flutter/material.dart';

import '../features/foundation/root/root_screen.dart';
import '../features/foundation/session/session_manager.dart';
import '../features/foundation/session/session_scope.dart';
import 'theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({required this.sessionManager, super.key});

  final SessionManager sessionManager;

  @override
  Widget build(BuildContext context) {
    return SessionScope(
      sessionManager: sessionManager,
      child: MaterialApp(
        title: 'Bottom Nav Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppTheme.colors.primary),
          scaffoldBackgroundColor: AppTheme.colors.surfaceBase,
          useMaterial3: true,
        ),
        home: const RootScreen(),
      ),
    );
  }
}
