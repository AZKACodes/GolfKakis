import 'dart:io';

import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/model/user_profile_model.dart';

class ProfileOverviewProfileAvatar extends StatelessWidget {
  const ProfileOverviewProfileAvatar({
    required this.profile,
    required this.size,
    super.key,
  });

  final UserProfileModel profile;
  final double size;

  @override
  Widget build(BuildContext context) {
    final localAvatarPath = profile.avatarImagePath?.trim();
    if (localAvatarPath != null && localAvatarPath.isNotEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
          image: DecorationImage(
            image: FileImage(File(localAvatarPath)),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    final palette =
        _avatarPalettes[profile.avatarIndex % _avatarPalettes.length];

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: palette,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: Center(
        child: Text(
          profile.initials,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

const List<List<Color>> _avatarPalettes = <List<Color>>[
  <Color>[Color(0xFF2F7BFF), Color(0xFF35C7A5)],
  <Color>[Color(0xFFFF9F1C), Color(0xFFFFD166)],
  <Color>[Color(0xFF9C4DFF), Color(0xFF5E60CE)],
  <Color>[Color(0xFF00A76F), Color(0xFF52B788)],
];
