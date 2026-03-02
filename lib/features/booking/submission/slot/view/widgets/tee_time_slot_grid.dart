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
      child: LayoutBuilder(
        builder: (context, constraints) {
          const double spacing = 10;
          final bool canFitTwoColumns = constraints.maxWidth >= 260;
          final int crossAxisCount = canFitTwoColumns ? 2 : 1;

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: slots.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              childAspectRatio: 1.65,
            ),
            itemBuilder: (context, index) {
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

              final Color dividerColor = isUnavailable
                  ? Colors.black26
                  : isSelected
                      ? Colors.white54
                      : Colors.black12;

              return InkWell(
                onTap: isUnavailable ? null : () => onSelected(index),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 170),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        slots[index],
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Divider(height: 1, thickness: 1, color: dividerColor),
                      const SizedBox(height: 8),
                      Text(
                        'Players: --',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: textColor,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Total Rounds: --',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: textColor,
                            ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
