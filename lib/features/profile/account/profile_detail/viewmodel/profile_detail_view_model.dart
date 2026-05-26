import 'package:golf_kakis/features/foundation/default_values.dart';
import 'package:golf_kakis/features/foundation/model/user_profile_model.dart';
import 'package:golf_kakis/features/foundation/model/snackbar_message_model.dart';
import 'package:golf_kakis/features/foundation/session/session_state.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_view_model.dart';
import 'package:golf_kakis/features/profile/account/profile_detail/domain/profile_detail_use_case.dart';

import 'profile_detail_view_contract.dart';

class ProfileDetailViewModel
    extends
        MviViewModel<
          ProfileDetailUserIntent,
          ProfileDetailViewState,
          ProfileDetailNavEffect
        >
    implements ProfileDetailViewContract {
  ProfileDetailViewModel({
    required UserProfileModel profile,
    required ProfileDetailUseCase useCase,
  }) : _profile = profile,
       _useCase = useCase;

  final ProfileDetailUseCase _useCase;
  UserProfileModel _profile;
  SessionState? _session;

  @override
  ProfileDetailViewState createInitialState() {
    return ProfileDetailDataLoaded.fromProfile(
      _profile,
      dateOfBirth: _dateOfBirthFromProfile(_profile),
    );
  }

  @override
  Future<void> handleIntent(ProfileDetailUserIntent intent) async {
    switch (intent) {
      case OnInitProfileDetails():
        await _initProfileDetails(intent.session);
      case OnProfileDetailUsernameChanged():
        emitViewState(
          (_) => _currentDataState.copyWith(
            username: intent.value,
            clearMessage: true,
            clearErrorMessage: true,
          ),
        );
      case OnProfileDetailGenderChanged():
        emitViewState(
          (_) => _currentDataState.copyWith(
            gender: intent.value,
            clearMessage: true,
            clearErrorMessage: true,
          ),
        );
      case OnProfileDetailDateOfBirthChanged():
        emitViewState(
          (_) => _currentDataState.copyWith(
            dateOfBirth: intent.value,
            clearMessage: true,
            clearErrorMessage: true,
          ),
        );
      case OnProfileDetailEmailChanged():
        emitViewState(
          (_) => _currentDataState.copyWith(
            email: intent.value,
            clearMessage: true,
            clearErrorMessage: true,
          ),
        );
      case OnProfileDetailPhoneChanged():
        emitViewState(
          (_) => _currentDataState.copyWith(
            phoneNumber: intent.value,
            clearMessage: true,
            clearErrorMessage: true,
          ),
        );
      case OnProfileDetailAvatarChanged():
        emitViewState(
          (_) => _currentDataState.copyWith(
            avatarIndex: intent.value,
            clearMessage: true,
            clearErrorMessage: true,
          ),
        );
      case OnProfileDetailAvatarImageChanged():
        emitViewState(
          (_) => _currentDataState.copyWith(
            avatarImagePath: intent.value,
            clearMessage: true,
            clearErrorMessage: true,
          ),
        );
      case OnProfileDetailSaveClick():
        await _save();
      case OnProfileDetailDeactivateAccountConfirmed():
        await _deactivateAccount(intent.phoneNumber);
      case OnProfileDetailBackClick():
        sendNavEffect(() => const ProfileDetailNavigateBack());
    }
  }

  ProfileDetailDataLoaded get _currentDataState {
    return switch (currentState) {
      ProfileDetailDataLoaded() => currentState as ProfileDetailDataLoaded,
    };
  }

  Future<void> _initProfileDetails(SessionState session) async {
    _session = session;
    if (!session.isLoggedIn) {
      return;
    }

    try {
      final profile = await _useCase.onFetchUserDetails(
        session: session,
        fallbackProfile: _profile,
      );
      _profile = profile;
      emitViewState(
        (state) => ProfileDetailDataLoaded.fromProfile(
          profile,
          dateOfBirth: _dateOfBirthFromProfile(profile),
        ),
      );
    } catch (error) {
      emitViewState(
        (_) => _currentDataState.copyWith(
          errorSnackbarMessageModel: SnackbarMessageModel(
            message: 'Unable to refresh profile details: $error',
          ),
          clearMessage: true,
        ),
      );
    }
  }

  Future<void> _save() async {
    if (!_currentDataState.canSave) {
      emitViewState(
        (_) => _currentDataState.copyWith(
          errorSnackbarMessageModel: const SnackbarMessageModel(
            message: 'Enter a username and email to save.',
          ),
          clearMessage: true,
        ),
      );
      return;
    }

    emitViewState(
      (_) => _currentDataState.copyWith(
        isSaving: true,
        clearMessage: true,
        clearErrorMessage: true,
      ),
    );

    final session = _session ?? SessionState.initial;
    final pendingProfile = _buildProfileFromState(_currentDataState);
    try {
      var updatedProfile = pendingProfile;
      if (pendingProfile.avatarImagePath != _profile.avatarImagePath) {
        updatedProfile = await _useCase.onUpdateProfilePicture(
          session: session,
          profile: updatedProfile,
        );
      }

      updatedProfile = await _useCase.onUpdateProfile(
        session: session,
        profile: updatedProfile,
      );
      _profile = updatedProfile;
      emitViewState(
        (_) => ProfileDetailDataLoaded.fromProfile(
          updatedProfile,
          dateOfBirth: _dateOfBirthFromProfile(updatedProfile),
        ).copyWith(
          isSaving: false,
          snackbarMessageModel: const SnackbarMessageModel(
            message: 'Profile updated for this demo session.',
          ),
        ),
      );
      sendNavEffect(() => const ProfileDetailSaved());
    } catch (error) {
      emitViewState(
        (_) => _currentDataState.copyWith(
          isSaving: false,
          errorSnackbarMessageModel: SnackbarMessageModel(
            message: 'Unable to update profile: $error',
          ),
          clearMessage: true,
        ),
      );
    }
  }

  Future<void> _deactivateAccount(String confirmationPhoneNumber) async {
    final normalizedInput = _normalizePhone(confirmationPhoneNumber);
    final normalizedAccountPhone = _normalizePhone(_currentDataState.phoneNumber);
    final accountPhoneParts = _normalizedPhoneParts(_currentDataState.phoneNumber);

    if (normalizedInput.isEmpty ||
        (normalizedInput != normalizedAccountPhone &&
            normalizedInput != accountPhoneParts)) {
      emitViewState(
        (_) => _currentDataState.copyWith(
          errorSnackbarMessageModel: const SnackbarMessageModel(
            message: 'The phone number does not match this account.',
          ),
          clearMessage: true,
        ),
      );
      return;
    }

    emitViewState(
      (_) => _currentDataState.copyWith(
        isSaving: true,
        clearMessage: true,
        clearErrorMessage: true,
      ),
    );

    final session = _session ?? SessionState.initial;
    try {
      final message = await _useCase.onDeactivateAccount(
        session: session,
        phoneNumber: _currentDataState.phoneNumber.trim(),
      );
      emitViewState(
        (_) => _currentDataState.copyWith(
          isSaving: false,
          snackbarMessageModel: SnackbarMessageModel(message: message),
          clearErrorMessage: true,
        ),
      );
      sendNavEffect(() => const ProfileDetailDeactivated());
    } catch (error) {
      emitViewState(
        (_) => _currentDataState.copyWith(
          isSaving: false,
          errorSnackbarMessageModel: SnackbarMessageModel(
            message: 'Unable to deactivate account: $error',
          ),
          clearMessage: true,
        ),
      );
    }
  }

  UserProfileModel _buildProfileFromState(ProfileDetailDataLoaded state) {
    return _profile.copyWith(
      displayName: state.realName.trim(),
      userSlug: state.dateOfBirth.trim().isEmpty
          ? _profile.userSlug
          : 'dob:${state.dateOfBirth.trim()}',
      nickname: state.username.trim(),
      occupation: state.gender.trim().isEmpty ? '-' : state.gender.trim(),
      email: state.email.trim(),
      phoneNumber: state.phoneNumber.trim(),
      avatarIndex: state.avatarIndex,
      avatarImagePath: state.avatarImagePath,
    );
  }

  String _normalizePhone(String value) {
    return value.replaceAll(RegExp(r'[^0-9]'), '');
  }

  String _normalizedPhoneParts(String value) {
    final normalized = _normalizePhone(value);
    if (normalized.startsWith('60')) {
      return normalized.substring(2);
    }
    if (normalized.startsWith('65') ||
        normalized.startsWith('62') ||
        normalized.startsWith('66') ||
        normalized.startsWith('84')) {
      return normalized.substring(2);
    }
    return normalized;
  }

  String _dateOfBirthFromProfile(UserProfileModel profile) {
    return profile.userSlug.startsWith('dob:')
        ? profile.userSlug.substring(4)
        : emptyString;
  }
}
