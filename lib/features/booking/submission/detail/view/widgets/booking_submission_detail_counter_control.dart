import 'package:flutter/material.dart';

class BookingSubmissionDetailCounterControl extends StatelessWidget {
  const BookingSubmissionDetailCounterControl({
    required this.value,
    required this.onChanged,
    this.minValue = 0,
    this.buttonSize = 40,
    this.iconSize = 18,
    this.valueWidth = 32,
    super.key,
  });

  final int value;
  final int minValue;
  final ValueChanged<int> onChanged;
  final double buttonSize;
  final double iconSize;
  final double valueWidth;

  @override
  Widget build(BuildContext context) {
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
            onPressed: () => onChanged(value + 1),
            icon: Icon(Icons.add, size: iconSize),
          ),
        ),
      ],
    );
  }
}
