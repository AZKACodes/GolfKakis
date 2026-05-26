import 'package:flutter/material.dart';

class GolfKakisSelectionCard extends StatelessWidget {
  const GolfKakisSelectionCard({
    required this.placeholder,
    required this.unavailablePlaceholder,
    required this.hasOptions,
    required this.isLoading,
    required this.enabled,
    this.loadingPlaceholder = 'Loading...',
    this.icon = Icons.check_circle_outline_rounded,
    this.selectedBuilder,
    this.onTap,
    super.key,
  });

  final String placeholder;
  final String unavailablePlaceholder;
  final String loadingPlaceholder;
  final bool hasOptions;
  final bool isLoading;
  final bool enabled;
  final IconData icon;
  final WidgetBuilder? selectedBuilder;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canTap = enabled && !isLoading && onTap != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: canTap ? onTap : null,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: <Color>[Color(0xFFF5FBF5), Color(0xFFEAF4EE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFCEE2D2)),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D7A3A),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: isLoading
                      ? Row(
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              loadingPlaceholder,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : selectedBuilder == null
                      ? Text(
                          hasOptions ? placeholder : unavailablePlaceholder,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : selectedBuilder!(context),
                ),
                const SizedBox(width: 12),
                if (!isLoading)
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0x1A000000)),
                    ),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF0A1F1A),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
