import 'package:golf_kakis/features/foundation/model/profile_friend_model.dart';
import 'package:golf_kakis/features/foundation/session/session_state.dart';

abstract class ProfileFriendsUseCase {
  Future<ProfileFriendsResult> onFetchFriendList({
    required SessionState session,
  });

  Future<bool> requestContactsPermission();

  Future<ProfileFriendModel> onAddFriend({
    required SessionState session,
    required ProfileFriendModel friend,
  });

  Future<void> onDeleteFriend({
    required SessionState session,
    required String contactKey,
  });

  Future<ProfileFriendModel> onUpdateFriendDetails({
    required SessionState session,
    required String contactKey,
    required String nickname,
  });
}

class ProfileFriendsResult {
  const ProfileFriendsResult({
    required this.hasPermission,
    required this.friends,
    required this.availableContacts,
  });

  final bool hasPermission;
  final List<ProfileFriendModel> friends;
  final List<ProfileFriendModel> availableContacts;
}
