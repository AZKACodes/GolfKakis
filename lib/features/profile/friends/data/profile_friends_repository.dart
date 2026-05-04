import 'package:golf_kakis/features/foundation/model/profile/profile_friend_model.dart';

abstract class ProfileFriendsRepository {
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
