import 'package:flutter/material.dart';

class HomeQuickActionItem extends StatelessWidget {
  const HomeQuickActionItem({
    required this.icon,
    required this.label,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F7F6),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE6ECEA)),
          ),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFF0A1F1A)),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF081512),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
