import 'package:golf_kakis/features/foundation/model/profile_friend_model.dart';
import 'package:golf_kakis/features/foundation/model/snackbar_message_model.dart';
import 'package:golf_kakis/features/foundation/session/session_state.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_contract.dart';

abstract class ProfileFriendsViewContract {
  ProfileFriendsViewState get viewState;
  Stream<ProfileFriendsNavEffect> get navEffects;
  void onUserIntent(ProfileFriendsUserIntent intent);
}

class ProfileFriendsViewState extends ViewState {
  const ProfileFriendsViewState({
    required this.isLoading,
    required this.hasPermission,
    required this.friends,
    this.savingContactKey,
    this.errorSnackbarMessageModel = SnackbarMessageModel.emptyValue,
  }) : super();

  static const initial = ProfileFriendsViewState(
    isLoading: false,
    hasPermission: true,
    friends: <ProfileFriendModel>[],
  );

  final bool isLoading;
  final bool hasPermission;
  final List<ProfileFriendModel> friends;
  final String? savingContactKey;
  final SnackbarMessageModel errorSnackbarMessageModel;

  bool get hasFriends => friends.isNotEmpty;

  String? get errorMessage => errorSnackbarMessageModel.hasMessage
      ? errorSnackbarMessageModel.message
      : null;

  ProfileFriendsViewState copyWith({
    bool? isLoading,
    bool? hasPermission,
    List<ProfileFriendModel>? friends,
    String? savingContactKey,
    SnackbarMessageModel? errorSnackbarMessageModel,
    bool clearSavingContactKey = false,
    bool clearErrorMessage = false,
  }) {
    return ProfileFriendsViewState(
      isLoading: isLoading ?? this.isLoading,
      hasPermission: hasPermission ?? this.hasPermission,
      friends: friends ?? this.friends,
      savingContactKey: clearSavingContactKey
          ? null
          : (savingContactKey ?? this.savingContactKey),
      errorSnackbarMessageModel: clearErrorMessage
          ? SnackbarMessageModel.emptyValue
          : errorSnackbarMessageModel ?? this.errorSnackbarMessageModel,
    );
  }
}

sealed class ProfileFriendsUserIntent extends UserIntent {
  const ProfileFriendsUserIntent();
}

class OnInitFriends extends ProfileFriendsUserIntent {
  const OnInitFriends(this.session);

  final SessionState session;
}

class OnRefreshFriends extends ProfileFriendsUserIntent {
  const OnRefreshFriends(this.session);

  final SessionState session;
}

class OnOpenAddressBook extends ProfileFriendsUserIntent {
  const OnOpenAddressBook(this.session);

  final SessionState session;
}

class OnSaveFriendNickname extends ProfileFriendsUserIntent {
  const OnSaveFriendNickname({
    required this.session,
    required this.contactKey,
    required this.nickname,
  });

  final SessionState session;
  final String contactKey;
  final String nickname;
}

class OnAddFriendToGolfKakis extends ProfileFriendsUserIntent {
  const OnAddFriendToGolfKakis({required this.session, required this.friend});

  final SessionState session;
  final ProfileFriendModel friend;
}

class OnRemoveFriendFromGolfKakis extends ProfileFriendsUserIntent {
  const OnRemoveFriendFromGolfKakis({
    required this.session,
    required this.contactKey,
  });

  final SessionState session;
  final String contactKey;
}

sealed class ProfileFriendsNavEffect extends NavEffect {
  const ProfileFriendsNavEffect();
}

class ShowFriendsFeedback extends ProfileFriendsNavEffect {
  const ShowFriendsFeedback(this.message);

  final String message;
}
