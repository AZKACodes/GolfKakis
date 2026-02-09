import 'package:flutter/material.dart';

import '../features/root/root_screen.dart';
import 'theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bottom Nav Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppTheme.colors.primary,
        ),
        scaffoldBackgroundColor: AppTheme.colors.surfaceBase,
        useMaterial3: true,
      ),
      home: const RootScreen(),
    );
  }
}
