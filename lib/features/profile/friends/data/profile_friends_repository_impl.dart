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
  Future<bool> requestContactsPermission() async {
    final hasPermission = await FlutterContacts.requestPermission(
      readonly: true,
    );
    if (hasPermission) {
      return true;
    }

    final status = await Permission.contacts.status;
    return status.isGranted || status.isLimited;
  }

  @override
  Future<ProfileFriendModel?> onPickDeviceContact() async {
    final pickedContact = await FlutterContacts.openExternalPick();
    if (pickedContact == null) {
      return null;
    }

    final contact = pickedContact.phones.isNotEmpty
        ? pickedContact
        : await FlutterContacts.getContact(
            pickedContact.id,
            withProperties: true,
            withThumbnail: false,
            withPhoto: false,
          );
    if (contact == null) {
      return null;
    }

    return _toFriendModel(contact);
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
}
