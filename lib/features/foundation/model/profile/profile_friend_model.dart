class ProfileFriendModel {
  const ProfileFriendModel({
    required this.contactKey,
    required this.displayName,
    required this.phoneNumber,
    this.nickname = '',
  });

  final String contactKey;
  final String displayName;
  final String phoneNumber;
  final String nickname;

  bool get hasNickname => nickname.trim().isNotEmpty;

  String get effectiveDisplayName =>
      hasNickname ? nickname.trim() : displayName;

  String get initials {
    final source = effectiveDisplayName.trim().isEmpty
        ? displayName
        : effectiveDisplayName;
    final parts = source
        .split(' ')
        .where((part) => part.trim().isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return 'GK';
    }

    if (parts.length == 1) {
      final part = parts.first;
      return part.substring(0, part.length >= 2 ? 2 : 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  ProfileFriendModel copyWith({
    String? contactKey,
    String? displayName,
    String? phoneNumber,
    String? nickname,
  }) {
    return ProfileFriendModel(
      contactKey: contactKey ?? this.contactKey,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      nickname: nickname ?? this.nickname,
    );
  }
}
