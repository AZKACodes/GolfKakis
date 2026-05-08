import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_language.dart';

class AppLanguageController extends ChangeNotifier {
  static const String _languageCodeKey = 'app_language_code';

  AppLanguageController({SharedPreferences? preferences})
    : _preferences = preferences;

  SharedPreferences? _preferences;
  AppLanguage _currentLanguage = AppLanguage.english;

  AppLanguage get currentLanguage => _currentLanguage;
  Locale get locale => _currentLanguage.locale;

  Future<void> initialize() async {
    _preferences ??= await SharedPreferences.getInstance();
    final savedLanguageCode = _preferences?.getString(_languageCodeKey);
    _currentLanguage = AppLanguage.fromLanguageCode(savedLanguageCode);
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (_currentLanguage == language) {
      return;
    }

    _currentLanguage = language;
    notifyListeners();
    await _preferences?.setString(_languageCodeKey, language.languageCode);
  }
}
