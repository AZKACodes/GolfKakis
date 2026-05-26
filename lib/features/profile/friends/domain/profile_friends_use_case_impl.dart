import 'package:golf_kakis/features/foundation/model/profile_friend_model.dart';
import 'package:golf_kakis/features/foundation/session/session_state.dart';

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
  Future<ProfileFriendsResult> onFetchFriendList({
    required SessionState session,
  }) async {
    final friends = await _repository.onFetchFriendList(session: session);
    final availableContacts = await _repository.onFetchAvailableContacts(
      savedFriends: friends,
    );

    return ProfileFriendsResult(
      hasPermission: await _repository.hasContactsPermission(),
      friends: friends,
      availableContacts: availableContacts,
    );
  }

  @override
  Future<bool> requestContactsPermission() {
    return _repository.requestContactsPermission();
  }

  @override
  Future<ProfileFriendModel> onAddFriend({
    required SessionState session,
    required ProfileFriendModel friend,
  }) {
    return _repository.onAddFriend(session: session, friend: friend);
  }

  @override
  Future<void> onDeleteFriend({
    required SessionState session,
    required String contactKey,
  }) {
    return _repository.onDeleteFriend(session: session, contactKey: contactKey);
  }

  @override
  Future<ProfileFriendModel> onUpdateFriendDetails({
    required SessionState session,
    required String contactKey,
    required String nickname,
  }) {
    return _repository.onUpdateFriendDetails(
      session: session,
      contactKey: contactKey,
      nickname: nickname,
    );
  }
}
