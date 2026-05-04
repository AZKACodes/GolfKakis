import 'package:flutter/material.dart';

class HomeHeaderSection extends StatelessWidget {
  const HomeHeaderSection({
    required this.greeting,
    required this.showAvatar,
    required this.avatarIndex,
    super.key,
  });

  final String greeting;
  final bool showAvatar;
  final int avatarIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: <Color>[
            Color(0xFF0E2A47),
            Color(0xFF154C79),
            Color(0xFF2D7CA8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showAvatar)
            Row(
              children: [
                const Spacer(),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: _avatarBackgroundColors[
                      avatarIndex % _avatarBackgroundColors.length
                  ],
                  child: Text(
                    _resolveInitials(greeting),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF0E2A47),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          if (showAvatar) const SizedBox(height: 16),
          Text(
            greeting,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
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
