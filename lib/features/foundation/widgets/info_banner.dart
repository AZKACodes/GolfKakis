import 'package:flutter/material.dart';

class InfoBanner extends StatelessWidget {
  const InfoBanner({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF3D6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9C46A)),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: const Color(0xFF7A5B00),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
