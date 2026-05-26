import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../features/foundation/root/root_screen.dart';
import '../features/foundation/session/session_manager.dart';
import '../features/foundation/session/session_scope.dart';
import 'app_language_controller.dart';
import 'app_language_scope.dart';
import 'theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({
    required this.sessionManager,
    required this.languageController,
    super.key,
  });

  final SessionManager sessionManager;
  final AppLanguageController languageController;

  @override
  Widget build(BuildContext context) {
    return SessionScope(
      sessionManager: sessionManager,
      child: AppLanguageScope(
        controller: languageController,
        child: ListenableBuilder(
          listenable: languageController,
          builder: (context, _) => MaterialApp(
            title: 'GolfKakis',
            debugShowCheckedModeBanner: false,
            locale: languageController.locale,
            supportedLocales: AppLanguageControllerSupportedLocales.values,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppTheme.colors.primary,
              ),
              scaffoldBackgroundColor: AppTheme.colors.surfaceBase,
              useMaterial3: true,
            ),
            home: const RootScreen(),
          ),
        ),
      ),
    );
  }
}

abstract final class AppLanguageControllerSupportedLocales {
  static const values = [Locale('en'), Locale('ms'), Locale('zh')];
}
