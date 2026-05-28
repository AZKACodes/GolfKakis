import 'package:golf_kakis/app/app_language.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_contract.dart';

abstract class ProfileLanguageViewContract {
  ProfileLanguageViewState get viewState;
  Stream<ProfileLanguageNavEffect> get navEffects;
  void onUserIntent(ProfileLanguageUserIntent intent);
}

class ProfileLanguageViewState extends ViewState {
  const ProfileLanguageViewState({required this.selectedLanguage}) : super();

  final AppLanguage selectedLanguage;

  ProfileLanguageViewState copyWith({AppLanguage? selectedLanguage}) {
    return ProfileLanguageViewState(
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
    );
  }
}

sealed class ProfileLanguageUserIntent extends UserIntent {
  const ProfileLanguageUserIntent() : super();
}

class OnProfileLanguageSelected extends ProfileLanguageUserIntent {
  const OnProfileLanguageSelected(this.language);

  final AppLanguage language;
}

class OnProfileLanguageBackClick extends ProfileLanguageUserIntent {
  const OnProfileLanguageBackClick();
}

sealed class ProfileLanguageNavEffect extends NavEffect {
  const ProfileLanguageNavEffect() : super();
}

class ProfileLanguageNavigateBack extends ProfileLanguageNavEffect {
  const ProfileLanguageNavigateBack();
}
