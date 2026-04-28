import 'package:flutter/material.dart';

class HomeAnnouncementItem {
  const HomeAnnouncementItem({
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
  });

  final String tag;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
}
