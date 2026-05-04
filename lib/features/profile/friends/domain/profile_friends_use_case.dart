import 'package:golf_kakis/features/foundation/model/profile/profile_friend_model.dart';

import '../data/profile_friends_repository.dart';

abstract class ProfileFriendsUseCase {
  Future<ProfileFriendsResult> fetchFriends({required String ownerId});

  Future<bool> requestContactsPermission();

  Future<void> addFriend({
    required String ownerId,
    required ProfileFriendModel friend,
  });

  Future<void> removeFriend({
    required String ownerId,
    required String contactKey,
  });

  Future<void> saveNickname({
    required String ownerId,
    required String contactKey,
    required String nickname,
  });
}
