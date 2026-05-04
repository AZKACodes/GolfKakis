import 'dart:convert';

import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:golf_kakis/features/foundation/model/profile/profile_friend_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'profile_friends_repository.dart';

class ProfileFriendsRepositoryImpl implements ProfileFriendsRepository {
  ProfileFriendsRepositoryImpl({Future<SharedPreferences>? sharedPreferences})
    : _sharedPreferencesFuture =
          sharedPreferences ?? SharedPreferences.getInstance();

  static const String _nicknameStoragePrefix = 'profile_friend_nicknames_';
  static const String _friendListStoragePrefix = 'profile_friend_list_';
  static const String _customFriendListStoragePrefix =
      'profile_custom_friend_list_';

  final Future<SharedPreferences> _sharedPreferencesFuture;

  @override
  Future<ProfileFriendsResult> fetchFriends({required String ownerId}) async {
    final nicknameMap = await _readNicknameMap(ownerId);
    final selectedKeys = await _readSelectedFriendKeys(ownerId);
    final customFriends = await _readCustomFriends(ownerId, nicknameMap);

    try {
      final rawContacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: false,
      );

      final availableContacts = _mergeAndSortFriends(
        primary: rawContacts
            .map((contact) => _toFriendModel(contact, nicknameMap))
            .whereType<ProfileFriendModel>()
            .toList(),
        secondary: customFriends,
      );

      final friends = availableContacts
          .where((friend) => selectedKeys.contains(friend.contactKey))
          .toList();

      return ProfileFriendsResult(
        hasPermission: true,
        friends: friends,
        availableContacts: availableContacts,
      );
    } catch (_) {
      final availableContacts = _mergeAndSortFriends(
        primary: customFriends,
        secondary: const <ProfileFriendModel>[],
      );
      final friends = availableContacts
          .where((friend) => selectedKeys.contains(friend.contactKey))
          .toList();

      return ProfileFriendsResult(
        hasPermission: availableContacts.isNotEmpty,
        friends: friends,
        availableContacts: availableContacts,
      );
    }
  }

  @override
  Future<bool> requestContactsPermission() {
    return FlutterContacts.requestPermission();
  }

  @override
  Future<void> addFriend({
    required String ownerId,
    required ProfileFriendModel friend,
  }) async {
    final sharedPreferences = await _sharedPreferencesFuture;
    final selectedKeys = await _readSelectedFriendKeys(ownerId);
    if (!selectedKeys.contains(friend.contactKey)) {
      selectedKeys.add(friend.contactKey);
    }

    await sharedPreferences.setString(
      _friendListStorageKey(ownerId),
      jsonEncode(selectedKeys),
    );

    final customFriends = await _readCustomFriends(
      ownerId,
      const <String, String>{},
    );
    final existingIndex = customFriends.indexWhere(
      (savedFriend) => savedFriend.contactKey == friend.contactKey,
    );
    final normalizedFriend = ProfileFriendModel(
      contactKey: friend.contactKey,
      displayName: friend.displayName,
      phoneNumber: friend.phoneNumber,
      nickname: friend.nickname,
    );
    if (existingIndex == -1) {
      customFriends.add(normalizedFriend);
    } else {
      customFriends[existingIndex] = normalizedFriend;
    }

    await sharedPreferences.setString(
      _customFriendListStorageKey(ownerId),
      jsonEncode(
        customFriends
            .map(
              (item) => <String, dynamic>{
                'contactKey': item.contactKey,
                'displayName': item.displayName,
                'phoneNumber': item.phoneNumber,
              },
            )
            .toList(),
      ),
    );
  }

  @override
  Future<void> removeFriend({
    required String ownerId,
    required String contactKey,
  }) async {
    final sharedPreferences = await _sharedPreferencesFuture;

    final selectedKeys = await _readSelectedFriendKeys(ownerId);
    selectedKeys.removeWhere((key) => key == contactKey);
    await sharedPreferences.setString(
      _friendListStorageKey(ownerId),
      jsonEncode(selectedKeys),
    );

    final nicknameMap = await _readNicknameMap(ownerId);
    if (nicknameMap.remove(contactKey) != null) {
      await sharedPreferences.setString(
        _nicknameStorageKey(ownerId),
        jsonEncode(nicknameMap),
      );
    }

    final customFriends = await _readCustomFriends(
      ownerId,
      const <String, String>{},
    );
    customFriends.removeWhere((friend) => friend.contactKey == contactKey);
    await sharedPreferences.setString(
      _customFriendListStorageKey(ownerId),
      jsonEncode(
        customFriends
            .map(
              (item) => <String, dynamic>{
                'contactKey': item.contactKey,
                'displayName': item.displayName,
                'phoneNumber': item.phoneNumber,
              },
            )
            .toList(),
      ),
    );
  }

  @override
  Future<void> saveNickname({
    required String ownerId,
    required String contactKey,
    required String nickname,
  }) async {
    final sharedPreferences = await _sharedPreferencesFuture;
    final nicknameMap = await _readNicknameMap(ownerId);
    final normalizedNickname = nickname.trim();

    if (normalizedNickname.isEmpty) {
      nicknameMap.remove(contactKey);
    } else {
      nicknameMap[contactKey] = normalizedNickname;
    }

    await sharedPreferences.setString(
      _nicknameStorageKey(ownerId),
      jsonEncode(nicknameMap),
    );
  }

  Future<Map<String, String>> _readNicknameMap(String ownerId) async {
    final sharedPreferences = await _sharedPreferencesFuture;
    final rawValue = sharedPreferences.getString(_nicknameStorageKey(ownerId));
    if (rawValue == null || rawValue.trim().isEmpty) {
      return <String, String>{};
    }

    try {
      final decoded = jsonDecode(rawValue);
      if (decoded is! Map) {
        return <String, String>{};
      }

      return decoded.map<String, String>(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    } catch (_) {
      return <String, String>{};
    }
  }

  Future<List<String>> _readSelectedFriendKeys(String ownerId) async {
    final sharedPreferences = await _sharedPreferencesFuture;
    final rawValue = sharedPreferences.getString(
      _friendListStorageKey(ownerId),
    );
    if (rawValue == null || rawValue.trim().isEmpty) {
      return <String>[];
    }

    try {
      final decoded = jsonDecode(rawValue);
      if (decoded is! List) {
        return <String>[];
      }

      return decoded.map((value) => value.toString()).toSet().toList();
    } catch (_) {
      return <String>[];
    }
  }

  ProfileFriendModel? _toFriendModel(
    Contact contact,
    Map<String, String> nicknameMap,
  ) {
    final phoneNumber = contact.phones
        .map((phone) => phone.number.trim())
        .firstWhere((value) => value.isNotEmpty, orElse: () => '');

    if (phoneNumber.isEmpty) {
      return null;
    }

    final displayName = contact.displayName.trim();
    final contactKey = _contactKey(phoneNumber);
    return ProfileFriendModel(
      contactKey: contactKey,
      displayName: displayName.isEmpty ? 'Golf Kaki' : displayName,
      phoneNumber: phoneNumber,
      nickname: nicknameMap[contactKey] ?? '',
    );
  }

  String _nicknameStorageKey(String ownerId) =>
      '$_nicknameStoragePrefix$ownerId';

  String _friendListStorageKey(String ownerId) =>
      '$_friendListStoragePrefix$ownerId';

  String _customFriendListStorageKey(String ownerId) =>
      '$_customFriendListStoragePrefix$ownerId';

  String _contactKey(String phoneNumber) {
    final normalized = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    return normalized.isEmpty ? phoneNumber : normalized;
  }

  Future<List<ProfileFriendModel>> _readCustomFriends(
    String ownerId,
    Map<String, String> nicknameMap,
  ) async {
    final sharedPreferences = await _sharedPreferencesFuture;
    final rawValue = sharedPreferences.getString(
      _customFriendListStorageKey(ownerId),
    );
    if (rawValue == null || rawValue.trim().isEmpty) {
      return <ProfileFriendModel>[];
    }

    try {
      final decoded = jsonDecode(rawValue);
      if (decoded is! List) {
        return <ProfileFriendModel>[];
      }

      return decoded
          .whereType<Map>()
          .map((entry) {
            final map = Map<String, dynamic>.from(entry);
            final contactKey = map['contactKey']?.toString() ?? '';
            final phoneNumber = map['phoneNumber']?.toString() ?? '';
            final displayName = map['displayName']?.toString() ?? 'Golf Kaki';
            if (contactKey.isEmpty || phoneNumber.isEmpty) {
              return null;
            }

            return ProfileFriendModel(
              contactKey: contactKey,
              displayName: displayName,
              phoneNumber: phoneNumber,
              nickname: nicknameMap[contactKey] ?? '',
            );
          })
          .whereType<ProfileFriendModel>()
          .toList();
    } catch (_) {
      return <ProfileFriendModel>[];
    }
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
