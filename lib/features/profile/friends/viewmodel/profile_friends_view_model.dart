import 'package:golf_kakis/features/foundation/model/profile_friend_model.dart';
import 'package:golf_kakis/features/foundation/model/snackbar_message_model.dart';
import 'package:golf_kakis/features/foundation/network/network.dart';
import 'package:golf_kakis/features/foundation/session/session_state.dart';
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
        await _loadFriends(intent.session);
      case OnRefreshFriends():
        await _loadFriends(intent.session);
      case OnOpenAddressBook():
        await _openAddressBook(intent.session);
      case OnAddFriendToGolfKakis():
        await _addFriend(session: intent.session, friend: intent.friend);
      case OnRemoveFriendFromGolfKakis():
        await _removeFriend(
          session: intent.session,
          contactKey: intent.contactKey,
        );
      case OnSaveFriendNickname():
        await _saveNickname(
          session: intent.session,
          contactKey: intent.contactKey,
          nickname: intent.nickname,
        );
    }
  }

  Future<void> _openAddressBook(SessionState session) async {
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
            errorSnackbarMessageModel: const SnackbarMessageModel(
              message: 'Enable contacts permission to add a Golf Kaki.',
            ),
          ),
        );
        sendNavEffect(
          () => const ShowFriendsFeedback(
            'Contacts permission is needed to add a Golf Kaki.',
          ),
        );
        return;
      }

      emitViewState(
        (state) => state.copyWith(hasPermission: true, isLoading: false),
      );

      final pickedFriend = await _useCase.onPickDeviceContact();
      if (pickedFriend == null) {
        sendNavEffect(
          () => const ShowFriendsFeedback(
            'No contact with a phone number was selected.',
          ),
        );
        return;
      }

      await _addFriend(session: session, friend: pickedFriend);
    } catch (_) {
      emitViewState(
        (state) => state.copyWith(
          isLoading: false,
          errorSnackbarMessageModel: const SnackbarMessageModel(
            message: 'Unable to open your contacts right now.',
          ),
        ),
      );
    }
  }

  Future<void> _loadFriends(SessionState session) async {
    emitViewState(
      (state) => state.copyWith(isLoading: true, clearErrorMessage: true),
    );

    try {
      final result = await _useCase.onFetchFriendList(session: session);
      emitViewState(
        (state) => state.copyWith(
          isLoading: false,
          hasPermission: result.hasPermission,
          friends: result.friends,
          clearSavingContactKey: true,
          clearErrorMessage: true,
        ),
      );
    } on ApiException catch (error) {
      emitViewState(
        (state) => state.copyWith(
          isLoading: false,
          errorSnackbarMessageModel: SnackbarMessageModel(
            message: error.message,
          ),
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
    required SessionState session,
    required ProfileFriendModel friend,
  }) async {
    emitViewState(
      (state) => state.copyWith(
        savingContactKey: friend.contactKey,
        clearErrorMessage: true,
      ),
    );

    try {
      final savedFriend = await _useCase.onAddFriend(
        session: session,
        friend: friend,
      );

      final nextFriends = [...currentState.friends];
      final alreadyExists = nextFriends.any(
        (friend) => friend.contactKey == savedFriend.contactKey,
      );
      if (!alreadyExists) {
        nextFriends.add(savedFriend);
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
          '${savedFriend.displayName} added to My Golf Kakis.',
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
    required SessionState session,
    required String contactKey,
    required String nickname,
  }) async {
    emitViewState(
      (state) =>
          state.copyWith(savingContactKey: contactKey, clearErrorMessage: true),
    );

    try {
      final updatedFriend = await _useCase.onUpdateFriendDetails(
        session: session,
        contactKey: contactKey,
        nickname: nickname,
      );

      emitViewState(
        (state) => state.copyWith(
          friends: state.friends
              .map(
                (friend) => friend.contactKey == contactKey
                    ? friend.copyWith(nickname: updatedFriend.nickname)
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
    required SessionState session,
    required String contactKey,
  }) async {
    emitViewState(
      (state) =>
          state.copyWith(savingContactKey: contactKey, clearErrorMessage: true),
    );

    try {
      await _useCase.onDeleteFriend(session: session, contactKey: contactKey);

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
