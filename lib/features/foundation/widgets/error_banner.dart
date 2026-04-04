import 'package:flutter/material.dart';

class ErrorBanner extends StatelessWidget {
  const ErrorBanner({
    required this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final showAction =
        actionLabel != null &&
        actionLabel!.trim().isNotEmpty &&
        onAction != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDECEC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE7A1A1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF8A3D3D),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (showAction) ...[
            const SizedBox(width: 12),
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
