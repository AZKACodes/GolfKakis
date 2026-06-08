import 'dart:io';

import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/model/user_profile_model.dart';

const String _defaultProfileImageAsset =
    'assets/images/default_profile_pic.png';

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
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
        image: DecorationImage(
          image: _profileImageProvider(profile.avatarImagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

ImageProvider _profileImageProvider(String? imagePath) {
  final resolvedPath = imagePath?.trim();
  if (resolvedPath == null || resolvedPath.isEmpty) {
    return const AssetImage(_defaultProfileImageAsset);
  }
  if (resolvedPath.startsWith('http://') ||
      resolvedPath.startsWith('https://')) {
    return NetworkImage(resolvedPath);
  }
  return FileImage(File(resolvedPath));
}
