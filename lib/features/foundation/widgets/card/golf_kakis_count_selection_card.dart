import 'package:flutter/material.dart';

class GolfKakisCountSelectionCard extends StatelessWidget {
  const GolfKakisCountSelectionCard({
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.minValue = 0,
    this.maxValue,
    super.key,
  });

  final String title;
  final String? subtitle;
  final int value;
  final int minValue;
  final int? maxValue;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: _GolfKakisCountSelectionRow(
        title: title,
        subtitle: subtitle,
        value: value,
        minValue: minValue,
        maxValue: maxValue,
        onChanged: onChanged,
      ),
    );
  }
}

class _GolfKakisCountSelectionRow extends StatelessWidget {
  const _GolfKakisCountSelectionRow({
    required this.title,
    required this.value,
    required this.minValue,
    required this.onChanged,
    this.subtitle,
    this.maxValue,
  });

  final String title;
  final String? subtitle;
  final int value;
  final int minValue;
  final int? maxValue;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          _GolfKakisCounterControl(
            value: value,
            minValue: minValue,
            maxValue: maxValue,
            onChanged: onChanged,
            buttonSize: 32,
            iconSize: 15,
            valueWidth: 28,
          ),
        ],
      ),
    );
  }
}

class _GolfKakisCounterControl extends StatelessWidget {
  const _GolfKakisCounterControl({
    required this.value,
    required this.onChanged,
    this.minValue = 0,
    this.maxValue,
    this.buttonSize = 40,
    this.iconSize = 18,
    this.valueWidth = 32,
  });

  final int value;
  final int minValue;
  final int? maxValue;
  final ValueChanged<int> onChanged;
  final double buttonSize;
  final double iconSize;
  final double valueWidth;

  @override
  Widget build(BuildContext context) {
    final canIncrease = maxValue == null || value < maxValue!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: buttonSize,
          height: buttonSize,
          child: IconButton.outlined(
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            onPressed: value > minValue ? () => onChanged(value - 1) : null,
            icon: Icon(Icons.remove, size: iconSize),
          ),
        ),
        SizedBox(
          width: valueWidth,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        SizedBox(
          width: buttonSize,
          height: buttonSize,
          child: IconButton.filled(
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            onPressed: canIncrease ? () => onChanged(value + 1) : null,
            icon: Icon(Icons.add, size: iconSize),
          ),
        ),
      ],
    );
  }
}
