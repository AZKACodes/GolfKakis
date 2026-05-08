import 'package:flutter/material.dart';

class ProfileOverviewTouchpointTile extends StatelessWidget {
  const ProfileOverviewTouchpointTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    this.isPrimary = false,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final bool isPrimary;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          margin: EdgeInsets.only(bottom: isPrimary ? 0 : 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isPrimary ? accent.withValues(alpha: 0.08) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: accent.withValues(alpha: 0.22)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: accent),
            ],
          ),
        ),
      ),
    );
  }
}
