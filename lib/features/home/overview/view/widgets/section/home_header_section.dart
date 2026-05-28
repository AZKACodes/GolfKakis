import 'package:flutter/material.dart';

class HomeHeaderSection extends StatelessWidget {
  const HomeHeaderSection({
    required this.greeting,
    required this.showAvatar,
    required this.avatarIndex,
    this.avatarUrl,
    super.key,
  });

  final String greeting;
  final bool showAvatar;
  final int avatarIndex;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final resolvedAvatarUrl = avatarUrl?.trim();
    final hasAvatarImage =
        resolvedAvatarUrl != null && resolvedAvatarUrl.isNotEmpty;
    final headerName = _resolveHeaderName(greeting);
    final subtitle = showAvatar
        ? 'Ready for your next round?'
        : 'Find your next tee time';

    return Row(
      children: [
        if (showAvatar) ...[
          CircleAvatar(
            radius: 23,
            backgroundColor:
                _avatarBackgroundColors[avatarIndex %
                    _avatarBackgroundColors.length],
            backgroundImage: hasAvatarImage
                ? NetworkImage(resolvedAvatarUrl)
                : null,
            onBackgroundImageError: hasAvatarImage ? (_, _) {} : null,
            child: hasAvatarImage
                ? null
                : Text(
                    _resolveInitials(greeting),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF0E2A47),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                headerName,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w900,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Visibility(
          visible: false,
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE1E7E4)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.notifications_none_rounded,
                  color: colorScheme.onSurface,
                ),
                Positioned(
                  top: 12,
                  right: 13,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD92D20),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

String _resolveHeaderName(String greeting) {
  final cleaned = greeting
      .replaceFirst('Welcome back,', 'Hello')
      .replaceFirst('Welcome,', 'Hello')
      .trim();

  if (cleaned.isEmpty) {
    return 'Hello Golfer';
  }

  return cleaned;
}

String _resolveInitials(String greeting) {
  final parts = greeting
      .replaceFirst('Welcome back,', '')
      .replaceFirst('Welcome,', '')
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();

  if (parts.isEmpty) {
    return 'GK';
  }

  final letters = parts.take(2).map((part) => part[0].toUpperCase()).join();
  return letters.isEmpty ? 'GK' : letters;
}

const List<Color> _avatarBackgroundColors = <Color>[
  Color(0xFFFFE1A6),
  Color(0xFFFFC7C7),
  Color(0xFFBFE7D6),
  Color(0xFFC6D7FF),
];
