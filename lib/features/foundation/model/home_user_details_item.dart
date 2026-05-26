class HomeUserDetailsItem {
  const HomeUserDetailsItem({
    required this.displayName,
    required this.avatarIndex,
    this.avatarUrl,
  });

  final String displayName;
  final int avatarIndex;
  final String? avatarUrl;
}
