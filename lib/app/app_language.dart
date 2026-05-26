import 'dart:ui';

enum AppLanguage {
  english('en', 'English'),
  bahasaMelayu('ms', 'Bahasa Melayu'),
  chinese('zh', 'Chinese'),
  ;

  const AppLanguage(this.languageCode, this.label);

  final String languageCode;
  final String label;

  Locale get locale => Locale(languageCode);

  static AppLanguage fromLanguageCode(String? languageCode) {
    return AppLanguage.values.firstWhere(
      (language) => language.languageCode == languageCode,
      orElse: () => AppLanguage.english,
    );
  }
}
