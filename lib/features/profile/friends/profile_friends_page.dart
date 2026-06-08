import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:golf_kakis/features/foundation/model/profile_friend_model.dart';
import 'package:golf_kakis/features/foundation/session/session_state.dart';
import 'package:golf_kakis/features/foundation/util/debug_log.dart';
import 'package:golf_kakis/features/profile/friends/domain/profile_friends_use_case_impl.dart';
import 'package:golf_kakis/features/profile/friends/view/profile_friends_view.dart';
import 'package:golf_kakis/features/profile/friends/viewmodel/profile_friends_view_contract.dart';
import 'package:golf_kakis/features/profile/friends/viewmodel/profile_friends_view_model.dart';

class ProfileFriendsPage extends StatefulWidget {
  const ProfileFriendsPage({required this.session, super.key});

  final SessionState session;

  @override
  State<ProfileFriendsPage> createState() => _ProfileFriendsPageState();
}

class _ProfileFriendsPageState extends State<ProfileFriendsPage> {
  late final ProfileFriendsViewModel _viewModel;
  StreamSubscription<ProfileFriendsNavEffect>? _navEffectSubscription;

  @override
  void initState() {
    super.initState();
    _viewModel = ProfileFriendsViewModel(
      useCase: ProfileFriendsUseCaseImpl.create(),
    );
    _navEffectSubscription = _viewModel.navEffects.listen(_handleNavEffect);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _viewModel.onUserIntent(OnInitFriends(widget.session));
    });
  }

  @override
  void dispose() {
    _navEffectSubscription?.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  void _handleNavEffect(ProfileFriendsNavEffect effect) {
    if (!mounted) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      switch (effect) {
        case ShowFriendsFeedback():
          final messenger = ScaffoldMessenger.maybeOf(context);
          messenger?.showSnackBar(SnackBar(content: Text(effect.message)));
      }
    });
  }

  Future<void> _showNicknameEditor(ProfileFriendModel friend) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => _NicknameEditorDialog(friend: friend),
    );

    if (!mounted || result == null) {
      return;
    }

    _viewModel.onUserIntent(
      OnSaveFriendNickname(
        session: widget.session,
        contactKey: friend.contactKey,
        nickname: result,
      ),
    );
  }

  Future<void> _confirmDeleteFriend(ProfileFriendModel friend) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Friend'),
          content: Text(
            'Remove ${friend.effectiveDisplayName} from your Golf Kakis list?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFC62828),
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (!mounted || shouldDelete != true) {
      return;
    }

    _viewModel.onUserIntent(
      OnRemoveFriendFromGolfKakis(
        session: widget.session,
        contactKey: friend.contactKey,
      ),
    );
  }

  Future<void> _openNativeContactPicker() async {
    logDebug('[Friends] Add New Kakis tapped');
    ScaffoldMessenger.maybeOf(
      context,
    )?.showSnackBar(const SnackBar(content: Text('Opening contacts...')));

    try {
      logDebug('[Friends] Calling FlutterContacts.openExternalPick');
      final pickedContact = await FlutterContacts.openExternalPick();
      logDebug(
        '[Friends] Contact picker returned id=${pickedContact?.id ?? 'null'}',
      );
      if (!mounted || pickedContact == null) {
        return;
      }

      final contact = pickedContact.phones.isNotEmpty
          ? pickedContact
          : await FlutterContacts.getContact(
              pickedContact.id,
              withProperties: true,
              withThumbnail: false,
              withPhoto: false,
            );
      if (!mounted || contact == null) {
        return;
      }

      final friend = _friendFromContact(contact);
      if (friend == null) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          const SnackBar(
            content: Text('Selected contact does not have a phone number.'),
          ),
        );
        return;
      }

      _viewModel.onUserIntent(
        OnAddFriendToGolfKakis(session: widget.session, friend: friend),
      );
    } catch (_) {
      logDebug('[Friends] Native contact picker failed; requesting permission');
      if (!mounted) {
        return;
      }

      final hasPermission = await FlutterContacts.requestPermission(
        readonly: true,
      );
      logDebug('[Friends] Contact permission result=$hasPermission');
      if (!mounted) {
        return;
      }
      if (!hasPermission) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          const SnackBar(content: Text('Contacts permission is required.')),
        );
        return;
      }

      await _openNativeContactPicker();
    }
  }

  ProfileFriendModel? _friendFromContact(Contact contact) {
    final phoneNumber = contact.phones
        .map((phone) => phone.number.trim())
        .firstWhere((value) => value.isNotEmpty, orElse: () => '');
    if (phoneNumber.isEmpty) {
      return null;
    }

    final displayName = contact.displayName.trim();
    final contactKey = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    return ProfileFriendModel(
      contactKey: contactKey.isEmpty ? phoneNumber : contactKey,
      displayName: displayName.isEmpty ? 'Golf Kaki' : displayName,
      phoneNumber: phoneNumber,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final viewState = _viewModel.viewState;
        return Scaffold(
          appBar: AppBar(title: const Text('My Golf Kakis')),
          body: ProfileFriendsView(
            state: viewState,
            onRefresh: () async {
              _viewModel.onUserIntent(OnRefreshFriends(widget.session));
            },
            onAddNewKaki: () => unawaited(_openNativeContactPicker()),
            onEditNickname: _showNicknameEditor,
            onDeleteFriend: _confirmDeleteFriend,
          ),
        );
      },
    );
  }
}

class _NicknameEditorDialog extends StatefulWidget {
  const _NicknameEditorDialog({required this.friend});

  final ProfileFriendModel friend;

  @override
  State<_NicknameEditorDialog> createState() => _NicknameEditorDialogState();
}

class _NicknameEditorDialogState extends State<_NicknameEditorDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.friend.nickname);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Save Nickname'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          labelText: 'Nickname for ${widget.friend.displayName}',
          hintText: 'Eg. Weekend Flight Captain',
        ),
      ),
      actions: [
        if (widget.friend.hasNickname)
          TextButton(
            onPressed: () => Navigator.of(context).pop(''),
            child: const Text('Remove'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
