import 'package:flutter/material.dart';

class IconInfoPill extends StatelessWidget {
  const IconInfoPill({
    required this.icon,
    required this.label,
    this.backgroundColor = const Color(0xDBFFFFFF),
    this.borderColor = const Color(0x14000000),
    this.foregroundColor = const Color(0xFF0D7A3A),
    this.textColor = const Color(0xFF0A1F1A),
    super.key,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color borderColor;
  final Color foregroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foregroundColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
