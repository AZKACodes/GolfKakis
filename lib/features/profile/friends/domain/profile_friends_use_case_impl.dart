import 'package:golf_kakis/features/foundation/model/profile/profile_friend_model.dart';

import '../data/profile_friends_repository.dart';
import '../data/profile_friends_repository_impl.dart';
import 'profile_friends_use_case.dart';

class ProfileFriendsUseCaseImpl implements ProfileFriendsUseCase {
  ProfileFriendsUseCaseImpl._(this._repository);

  factory ProfileFriendsUseCaseImpl.create() {
    return ProfileFriendsUseCaseImpl._(ProfileFriendsRepositoryImpl());
  }

  final ProfileFriendsRepository _repository;

  @override
  Future<ProfileFriendsResult> fetchFriends({required String ownerId}) {
    return _repository.fetchFriends(ownerId: ownerId);
  }

  @override
  Future<bool> requestContactsPermission() {
    return _repository.requestContactsPermission();
  }

  @override
  Future<void> addFriend({
    required String ownerId,
    required ProfileFriendModel friend,
  }) {
    return _repository.addFriend(ownerId: ownerId, friend: friend);
  }

  @override
  Future<void> removeFriend({
    required String ownerId,
    required String contactKey,
  }) {
    return _repository.removeFriend(ownerId: ownerId, contactKey: contactKey);
  }

  @override
  Future<void> saveNickname({
    required String ownerId,
    required String contactKey,
    required String nickname,
  }) {
    return _repository.saveNickname(
      ownerId: ownerId,
      contactKey: contactKey,
      nickname: nickname,
    );
  }
}
