import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/model/profile/profile_friend_model.dart';
import 'package:golf_kakis/features/profile/friends/domain/profile_friends_use_case_impl.dart';
import 'package:golf_kakis/features/profile/friends/view/profile_friends_view.dart';
import 'package:golf_kakis/features/profile/friends/viewmodel/profile_friends_view_contract.dart';
import 'package:golf_kakis/features/profile/friends/viewmodel/profile_friends_view_model.dart';

class ProfileFriendsPage extends StatefulWidget {
  const ProfileFriendsPage({required this.ownerId, super.key});

  final String ownerId;

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
      _viewModel.onUserIntent(OnInitFriends(widget.ownerId));
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

  Future<void> _showAddFriendPicker({
    required List<ProfileFriendModel> contacts,
    required Set<String> selectedKeys,
  }) async {
    final selectedFriend = await showModalBottomSheet<ProfileFriendModel>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) =>
          _AddFriendSheet(contacts: contacts, selectedKeys: selectedKeys),
    );

    if (!mounted || selectedFriend == null) {
      return;
    }

    _viewModel.onUserIntent(
      OnAddFriendToGolfKakis(ownerId: widget.ownerId, friend: selectedFriend),
    );
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
        ownerId: widget.ownerId,
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
        ownerId: widget.ownerId,
        contactKey: friend.contactKey,
      ),
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
              _viewModel.onUserIntent(OnRefreshFriends(widget.ownerId));
            },
            onRetryPermission: () => _viewModel.onUserIntent(
              OnGrantContactsPermission(widget.ownerId),
            ),
            onAddFriend: () {
              if (!viewState.hasPermission) {
                _viewModel.onUserIntent(
                  OnGrantContactsPermission(widget.ownerId),
                );
                return;
              }

              _showAddFriendPicker(
                contacts: viewState.availableContacts,
                selectedKeys: viewState.friends
                    .map((friend) => friend.contactKey)
                    .toSet(),
              );
            },
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

class _AddFriendSheet extends StatefulWidget {
  const _AddFriendSheet({required this.contacts, required this.selectedKeys});

  final List<ProfileFriendModel> contacts;
  final Set<String> selectedKeys;

  @override
  State<_AddFriendSheet> createState() => _AddFriendSheetState();
}

class _AddFriendSheetState extends State<_AddFriendSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = _query.trim().toLowerCase();
    final filteredContacts = widget.contacts.where((contact) {
      if (normalizedQuery.isEmpty) {
        return true;
      }

      return contact.displayName.toLowerCase().contains(normalizedQuery) ||
          contact.phoneNumber.toLowerCase().contains(normalizedQuery) ||
          contact.effectiveDisplayName.toLowerCase().contains(normalizedQuery);
    }).toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.72,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Search Contacts',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Pick a contact number to add into My Golf Kakis.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 14),
              TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search by name or number',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: filteredContacts.isEmpty
                    ? Center(
                        child: Text(
                          'No matching contacts found.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    : ListView.separated(
                        itemCount: filteredContacts.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final contact = filteredContacts[index];
                          final isAdded = widget.selectedKeys.contains(
                            contact.contactKey,
                          );
                          return ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(color: Color(0xFFE3EAF8)),
                            ),
                            tileColor: const Color(0xFFF8FAFF),
                            title: Text(contact.displayName),
                            subtitle: Text(contact.phoneNumber),
                            trailing: isAdded
                                ? const Chip(label: Text('Added'))
                                : const Icon(Icons.add_circle_outline),
                            onTap: isAdded
                                ? null
                                : () => Navigator.of(context).pop(contact),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
