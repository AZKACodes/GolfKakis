import 'package:flutter/material.dart';

class TeeTimeSlotGrid extends StatelessWidget {
  const TeeTimeSlotGrid({
    super.key,
    required this.slots,
    required this.selectedIndex,
    required this.unavailableIndices,
    required this.onSelected,
  });

  final List<String> slots;
  final int? selectedIndex;
  final Set<int> unavailableIndices;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: List.generate(slots.length, (index) {
          final bool isUnavailable = unavailableIndices.contains(index);
          final bool isSelected = selectedIndex == index;

          final Color fillColor = isUnavailable
              ? Colors.grey.shade300
              : isSelected
                  ? theme.colorScheme.primary
                  : Colors.white;
          final Color textColor = isUnavailable
              ? Colors.black45
              : isSelected
                  ? Colors.white
                  : Colors.black87;

          return InkWell(
            onTap: isUnavailable ? null : () => onSelected(index),
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 170),
              width: 96,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : isUnavailable
                          ? Colors.grey.shade300
                          : theme.colorScheme.outlineVariant,
                ),
                boxShadow: isSelected
                    ? const [
                        BoxShadow(
                          color: Color(0x22000000),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.event_seat,
                    size: 16,
                    color: textColor,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    slots[index],
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
