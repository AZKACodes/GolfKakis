import 'package:flutter/material.dart';

class BookingSubmissionDetailCounterControl extends StatelessWidget {
  const BookingSubmissionDetailCounterControl({
    required this.value,
    required this.onChanged,
    this.minValue = 0,
    super.key,
  });

  final int value;
  final int minValue;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.outlined(
          onPressed: value > minValue ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove),
        ),

        SizedBox(
          width: 32,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        
        IconButton.filled(
          onPressed: () => onChanged(value + 1),
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
