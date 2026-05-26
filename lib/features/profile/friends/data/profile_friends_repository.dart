import 'package:golf_kakis/features/foundation/model/profile_friend_model.dart';
import 'package:golf_kakis/features/foundation/session/session_state.dart';

abstract class ProfileFriendsRepository {
  Future<List<ProfileFriendModel>> onFetchFriendList({
    required SessionState session,
  });

  Future<bool> hasContactsPermission();

  Future<List<ProfileFriendModel>> onFetchAvailableContacts({
    required List<ProfileFriendModel> savedFriends,
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
