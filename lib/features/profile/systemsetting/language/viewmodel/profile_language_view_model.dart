import 'package:golf_kakis/app/app_language_controller.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_view_model.dart';
import 'profile_language_view_contract.dart';

class ProfileLanguageViewModel
    extends
        MviViewModel<
          ProfileLanguageUserIntent,
          ProfileLanguageViewState,
          ProfileLanguageNavEffect
        >
    implements ProfileLanguageViewContract {
  ProfileLanguageViewModel({required AppLanguageController languageController})
    : _languageController = languageController;

  final AppLanguageController _languageController;

  @override
  ProfileLanguageViewState createInitialState() {
    return ProfileLanguageViewState(
      selectedLanguage: _languageController.currentLanguage,
    );
  }

  @override
  Future<void> handleIntent(ProfileLanguageUserIntent intent) async {
    switch (intent) {
      case OnProfileLanguageSelected():
        await _languageController.setLanguage(intent.language);
        emitViewState(
          (state) => state.copyWith(selectedLanguage: intent.language),
        );
      case OnProfileLanguageBackClick():
        sendNavEffect(() => const ProfileLanguageNavigateBack());
    }
  }
}
