import 'package:golf_kakis/features/foundation/model/profile/profile_friend_model.dart';
import 'package:golf_kakis/features/foundation/model/snackbar_message_model.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_view_model.dart';

import '../domain/profile_friends_use_case.dart';
import 'profile_friends_view_contract.dart';

class ProfileFriendsViewModel
    extends
        MviViewModel<
          ProfileFriendsUserIntent,
          ProfileFriendsViewState,
          ProfileFriendsNavEffect
        >
    implements ProfileFriendsViewContract {
  ProfileFriendsViewModel({required ProfileFriendsUseCase useCase})
    : _useCase = useCase;

  final ProfileFriendsUseCase _useCase;

  @override
  ProfileFriendsViewState createInitialState() =>
      ProfileFriendsViewState.initial;

  @override
  Future<void> handleIntent(ProfileFriendsUserIntent intent) async {
    switch (intent) {
      case OnInitFriends():
        await _loadFriends(intent.ownerId);
      case OnRefreshFriends():
        await _loadFriends(intent.ownerId);
      case OnRetryContactsPermission():
        await _grantPermissionAndLoad(intent.ownerId);
      case OnGrantContactsPermission():
        await _grantPermissionAndLoad(intent.ownerId);
      case OnAddFriendToGolfKakis():
        await _addFriend(ownerId: intent.ownerId, friend: intent.friend);
      case OnRemoveFriendFromGolfKakis():
        await _removeFriend(
          ownerId: intent.ownerId,
          contactKey: intent.contactKey,
        );
      case OnSaveFriendNickname():
        await _saveNickname(
          ownerId: intent.ownerId,
          contactKey: intent.contactKey,
          nickname: intent.nickname,
        );
    }
  }

  Future<void> _grantPermissionAndLoad(String ownerId) async {
    emitViewState(
      (state) => state.copyWith(isLoading: true, clearErrorMessage: true),
    );

    try {
      final hasPermission = await _useCase.requestContactsPermission();
      if (!hasPermission) {
        emitViewState(
          (state) => state.copyWith(
            isLoading: false,
            hasPermission: false,
            friends: const <ProfileFriendModel>[],
            availableContacts: const <ProfileFriendModel>[],
            clearSavingContactKey: true,
            errorSnackbarMessageModel: const SnackbarMessageModel(
              message: 'Contacts access was not granted.',
            ),
          ),
        );
        return;
      }

      await _loadFriends(ownerId);
    } catch (_) {
      emitViewState(
        (state) => state.copyWith(
          isLoading: false,
          hasPermission: false,
          clearSavingContactKey: true,
          errorSnackbarMessageModel: const SnackbarMessageModel(
            message: 'Unable to request contacts access right now.',
          ),
        ),
      );
    }
  }

  Future<void> _loadFriends(String ownerId) async {
    emitViewState(
      (state) => state.copyWith(isLoading: true, clearErrorMessage: true),
    );

    try {
      final result = await _useCase.fetchFriends(ownerId: ownerId);
      emitViewState(
        (state) => state.copyWith(
          isLoading: false,
          hasPermission: result.hasPermission,
          friends: result.friends,
          availableContacts: result.availableContacts,
          clearSavingContactKey: true,
          clearErrorMessage: true,
        ),
      );
    } catch (_) {
      emitViewState(
        (state) => state.copyWith(
          isLoading: false,
          errorSnackbarMessageModel: const SnackbarMessageModel(
            message: 'Unable to load your Golf Kakis right now.',
          ),
        ),
      );
    }
  }

  Future<void> _addFriend({
    required String ownerId,
    required ProfileFriendModel friend,
  }) async {
    emitViewState(
      (state) => state.copyWith(
        savingContactKey: friend.contactKey,
        clearErrorMessage: true,
      ),
    );

    try {
      await _useCase.addFriend(ownerId: ownerId, friend: friend);

      final nextFriends = [...currentState.friends];
      final alreadyExists = nextFriends.any(
        (savedFriend) => savedFriend.contactKey == friend.contactKey,
      );
      if (!alreadyExists) {
        nextFriends.add(friend);
        nextFriends.sort(
          (left, right) => left.effectiveDisplayName.toLowerCase().compareTo(
            right.effectiveDisplayName.toLowerCase(),
          ),
        );
      }

      emitViewState(
        (state) => state.copyWith(
          friends: nextFriends,
          clearSavingContactKey: true,
          clearErrorMessage: true,
        ),
      );

      sendNavEffect(
        () => ShowFriendsFeedback(
          '${friend.displayName} added to My Golf Kakis.',
        ),
      );
    } catch (_) {
      emitViewState(
        (state) => state.copyWith(
          clearSavingContactKey: true,
          errorSnackbarMessageModel: const SnackbarMessageModel(
            message: 'Unable to add that contact right now.',
          ),
        ),
      );
    }
  }

  Future<void> _saveNickname({
    required String ownerId,
    required String contactKey,
    required String nickname,
  }) async {
    emitViewState(
      (state) =>
          state.copyWith(savingContactKey: contactKey, clearErrorMessage: true),
    );

    try {
      await _useCase.saveNickname(
        ownerId: ownerId,
        contactKey: contactKey,
        nickname: nickname,
      );

      emitViewState(
        (state) => state.copyWith(
          friends: state.friends
              .map(
                (friend) => friend.contactKey == contactKey
                    ? friend.copyWith(nickname: nickname.trim())
                    : friend,
              )
              .toList(),
          clearSavingContactKey: true,
          clearErrorMessage: true,
        ),
      );

      sendNavEffect(
        () => ShowFriendsFeedback(
          nickname.trim().isEmpty
              ? 'Nickname removed from My Golf Kakis.'
              : 'Nickname saved in My Golf Kakis.',
        ),
      );
    } catch (_) {
      emitViewState(
        (state) => state.copyWith(
          clearSavingContactKey: true,
          errorSnackbarMessageModel: const SnackbarMessageModel(
            message: 'Unable to save that nickname right now.',
          ),
        ),
      );
    }
  }

  Future<void> _removeFriend({
    required String ownerId,
    required String contactKey,
  }) async {
    emitViewState(
      (state) =>
          state.copyWith(savingContactKey: contactKey, clearErrorMessage: true),
    );

    try {
      await _useCase.removeFriend(ownerId: ownerId, contactKey: contactKey);

      emitViewState(
        (state) => state.copyWith(
          friends: state.friends
              .where((friend) => friend.contactKey != contactKey)
              .toList(),
          clearSavingContactKey: true,
          clearErrorMessage: true,
        ),
      );

      sendNavEffect(
        () => const ShowFriendsFeedback('Removed from My Golf Kakis.'),
      );
    } catch (_) {
      emitViewState(
        (state) => state.copyWith(
          clearSavingContactKey: true,
          errorSnackbarMessageModel: const SnackbarMessageModel(
            message: 'Unable to remove that golfer right now.',
          ),
        ),
      );
    }
  }
}
