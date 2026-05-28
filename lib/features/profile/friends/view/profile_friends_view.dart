import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/model/profile_friend_model.dart';
import 'package:golf_kakis/features/foundation/widgets/error_banner.dart';

import '../viewmodel/profile_friends_view_contract.dart';

class ProfileFriendsView extends StatelessWidget {
  const ProfileFriendsView({
    required this.state,
    required this.onRefresh,
    required this.onAddNewKaki,
    required this.onEditNickname,
    required this.onDeleteFriend,
    super.key,
  });

  final ProfileFriendsViewState state;
  final Future<void> Function() onRefresh;
  final VoidCallback onAddNewKaki;
  final ValueChanged<ProfileFriendModel> onEditNickname;
  final ValueChanged<ProfileFriendModel> onDeleteFriend;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFFBF3), Color(0xFFF4F7FF), Color(0xFFF2FCF8)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            const _FriendsHeroCard(),
            const SizedBox(height: 16),
            _AddNewKakisCard(onTap: onAddNewKaki),
            const SizedBox(height: 16),
            if (state.errorMessage != null) ...[
              ErrorBanner(message: state.errorMessage!),
              const SizedBox(height: 12),
            ],
            if (state.isLoading) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 12),
            ],
            if (!state.hasFriends)
              const _EmptyFriendsCard()
            else
              _FriendsListSection(
                friends: state.friends,
                savingContactKey: state.savingContactKey,
                onEditNickname: onEditNickname,
                onDeleteFriend: onDeleteFriend,
              ),
          ],
        ),
      ),
    );
  }
}

class _AddNewKakisCard extends StatelessWidget {
  const _AddNewKakisCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE1E7E4)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF6F0),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.contacts_outlined,
                color: Color(0xFF1E5B4A),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add New Kakis',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Open your phone contacts',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

class _FriendsHeroCard extends StatelessWidget {
  const _FriendsHeroCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF183153), Color(0xFF2F7BFF), Color(0xFF35C7A5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x332F7BFF),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.groups_2_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'My Golf Kakis',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Keep your golf circle close. Import contacts, browse your friend list, and save personal nicknames only visible inside GolfKakis.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyFriendsCard extends StatelessWidget {
  const _EmptyFriendsCard();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'No Golf Kakis Yet',
      accent: const Color(0xFF00A76F),
      child: Text(
        'You have not added any golfers yet. Tap the address book icon to search your contacts and add a number to My Golf Kakis.',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

class _FriendsListSection extends StatelessWidget {
  const _FriendsListSection({
    required this.friends,
    required this.savingContactKey,
    required this.onEditNickname,
    required this.onDeleteFriend,
  });

  final List<ProfileFriendModel> friends;
  final String? savingContactKey;
  final ValueChanged<ProfileFriendModel> onEditNickname;
  final ValueChanged<ProfileFriendModel> onDeleteFriend;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Friend List',
      accent: const Color(0xFF2F7BFF),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${friends.length} Golf Kakis from your contacts',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 12),
          ...friends.map(
            (friend) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _FriendListTile(
                friend: friend,
                isSaving: savingContactKey == friend.contactKey,
                onEditNickname: () => onEditNickname(friend),
                onDeleteFriend: () => onDeleteFriend(friend),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FriendListTile extends StatelessWidget {
  const _FriendListTile({
    required this.friend,
    required this.isSaving,
    required this.onEditNickname,
    required this.onDeleteFriend,
  });

  final ProfileFriendModel friend;
  final bool isSaving;
  final VoidCallback onEditNickname;
  final VoidCallback onDeleteFriend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3EAF8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFF2F7BFF),
            child: Text(
              friend.initials,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friend.effectiveDisplayName,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  friend.phoneNumber,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                ),
                if (friend.hasNickname) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F4FF),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Saved as "${friend.nickname}" in app',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: const Color(0xFF173B7A),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'nickname':
                        onEditNickname();
                      case 'delete':
                        onDeleteFriend();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      value: 'nickname',
                      child: Text(
                        friend.hasNickname ? 'Edit Nickname' : 'Add Nickname',
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Delete Friend'),
                    ),
                  ],
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0x14000000)),
                    ),
                    child: const Icon(
                      Icons.more_horiz_rounded,
                      color: Colors.black54,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.accent,
    required this.child,
  });

  final String title;
  final Color accent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
