import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:golf_kakis/features/foundation/model/profile_friend_model.dart';
import 'package:golf_kakis/features/foundation/network/network.dart';
import 'package:golf_kakis/features/foundation/session/session_state.dart';
import 'package:golf_kakis/features/profile/api/profile_api_service.dart';
import 'package:permission_handler/permission_handler.dart';

import 'profile_friends_repository.dart';

class ProfileFriendsRepositoryImpl implements ProfileFriendsRepository {
  ProfileFriendsRepositoryImpl({
    ApiClient? apiClient,
    ProfileApiService? apiService,
  }) : _apiService = apiService ?? ProfileApiService(apiClient: apiClient);

  final ProfileApiService _apiService;

  @override
  Future<List<ProfileFriendModel>> onFetchFriendList({
    required SessionState session,
  }) {
    return _apiService.onFetchFriendList(
      accessToken: _accessTokenFromSession(session),
    );
  }

  @override
  Future<bool> hasContactsPermission() {
    return _hasContactsPermission();
  }

  @override
  Future<List<ProfileFriendModel>> onFetchAvailableContacts({
    required List<ProfileFriendModel> savedFriends,
  }) {
    return _loadAvailableContacts(savedFriends);
  }

  @override
  Future<bool> requestContactsPermission() async {
    final status = await Permission.contacts.request();
    if (!status.isGranted && !status.isLimited) {
      return false;
    }

    return FlutterContacts.requestPermission(readonly: true);
  }

  @override
  Future<ProfileFriendModel> onAddFriend({
    required SessionState session,
    required ProfileFriendModel friend,
  }) {
    return _apiService.onAddFriend(
      accessToken: _accessTokenFromSession(session),
      friend: friend,
    );
  }

  @override
  Future<void> onDeleteFriend({
    required SessionState session,
    required String contactKey,
  }) {
    return _apiService.onDeleteFriend(
      accessToken: _accessTokenFromSession(session),
      contactKey: contactKey,
    );
  }

  @override
  Future<ProfileFriendModel> onUpdateFriendDetails({
    required SessionState session,
    required String contactKey,
    required String nickname,
  }) {
    return _apiService.onUpdateFriendDetails(
      accessToken: _accessTokenFromSession(session),
      contactKey: contactKey,
      nickname: nickname,
    );
  }

  String _accessTokenFromSession(SessionState session) {
    final accessToken = session.accessToken?.trim();
    if (accessToken == null || accessToken.isEmpty) {
      throw ApiException(message: 'Missing access token for friend list.');
    }

    return accessToken;
  }

  Future<List<ProfileFriendModel>> _loadAvailableContacts(
    List<ProfileFriendModel> friends,
  ) async {
    if (!await _hasContactsPermission()) {
      return friends;
    }

    try {
      final rawContacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: false,
      );

      return _mergeAndSortFriends(
        primary: rawContacts
            .map(_toFriendModel)
            .whereType<ProfileFriendModel>()
            .toList(),
        secondary: friends,
      );
    } catch (_) {
      return friends;
    }
  }

  ProfileFriendModel? _toFriendModel(Contact contact) {
    final phoneNumber = contact.phones
        .map((phone) => phone.number.trim())
        .firstWhere((value) => value.isNotEmpty, orElse: () => '');

    if (phoneNumber.isEmpty) {
      return null;
    }

    final displayName = contact.displayName.trim();
    return ProfileFriendModel(
      contactKey: _contactKey(phoneNumber),
      displayName: displayName.isEmpty ? 'Golf Kaki' : displayName,
      phoneNumber: phoneNumber,
    );
  }

  String _contactKey(String phoneNumber) {
    final normalized = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    return normalized.isEmpty ? phoneNumber : normalized;
  }

  Future<bool> _hasContactsPermission() async {
    final status = await Permission.contacts.status;
    return status.isGranted || status.isLimited;
  }

  List<ProfileFriendModel> _mergeAndSortFriends({
    required List<ProfileFriendModel> primary,
    required List<ProfileFriendModel> secondary,
  }) {
    final byKey = <String, ProfileFriendModel>{};
    for (final friend in primary) {
      byKey[friend.contactKey] = friend;
    }
    for (final friend in secondary) {
      byKey.putIfAbsent(friend.contactKey, () => friend);
    }

    final merged = byKey.values.toList()
      ..sort(
        (left, right) => left.effectiveDisplayName.toLowerCase().compareTo(
          right.effectiveDisplayName.toLowerCase(),
        ),
      );
    return merged;
  }
}
