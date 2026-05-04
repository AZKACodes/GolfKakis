import 'package:golf_kakis/features/foundation/model/profile/profile_friend_model.dart';
import 'package:golf_kakis/features/foundation/model/snackbar_message_model.dart';
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
    required this.availableContacts,
    this.savingContactKey,
    this.errorSnackbarMessageModel = SnackbarMessageModel.emptyValue,
  }) : super();

  static const initial = ProfileFriendsViewState(
    isLoading: false,
    hasPermission: true,
    friends: <ProfileFriendModel>[],
    availableContacts: <ProfileFriendModel>[],
  );

  final bool isLoading;
  final bool hasPermission;
  final List<ProfileFriendModel> friends;
  final List<ProfileFriendModel> availableContacts;
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
    List<ProfileFriendModel>? availableContacts,
    String? savingContactKey,
    SnackbarMessageModel? errorSnackbarMessageModel,
    bool clearSavingContactKey = false,
    bool clearErrorMessage = false,
  }) {
    return ProfileFriendsViewState(
      isLoading: isLoading ?? this.isLoading,
      hasPermission: hasPermission ?? this.hasPermission,
      friends: friends ?? this.friends,
      availableContacts: availableContacts ?? this.availableContacts,
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
  const OnInitFriends(this.ownerId);

  final String ownerId;
}

class OnRefreshFriends extends ProfileFriendsUserIntent {
  const OnRefreshFriends(this.ownerId);

  final String ownerId;
}

class OnRetryContactsPermission extends ProfileFriendsUserIntent {
  const OnRetryContactsPermission(this.ownerId);

  final String ownerId;
}

class OnGrantContactsPermission extends ProfileFriendsUserIntent {
  const OnGrantContactsPermission(this.ownerId);

  final String ownerId;
}

class OnSaveFriendNickname extends ProfileFriendsUserIntent {
  const OnSaveFriendNickname({
    required this.ownerId,
    required this.contactKey,
    required this.nickname,
  });

  final String ownerId;
  final String contactKey;
  final String nickname;
}

class OnAddFriendToGolfKakis extends ProfileFriendsUserIntent {
  const OnAddFriendToGolfKakis({required this.ownerId, required this.friend});

  final String ownerId;
  final ProfileFriendModel friend;
}

class OnRemoveFriendFromGolfKakis extends ProfileFriendsUserIntent {
  const OnRemoveFriendFromGolfKakis({
    required this.ownerId,
    required this.contactKey,
  });

  final String ownerId;
  final String contactKey;
}

sealed class ProfileFriendsNavEffect extends NavEffect {
  const ProfileFriendsNavEffect();
}

class ShowFriendsFeedback extends ProfileFriendsNavEffect {
  const ShowFriendsFeedback(this.message);

  final String message;
}
