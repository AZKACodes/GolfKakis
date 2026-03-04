import 'package:flutter/material.dart';
import 'package:xxx_demo_app/features/foundation/enums/booking/tee_time_slot.dart';
import 'package:xxx_demo_app/features/foundation/widgets/booking_submission_metric_column.dart';

class BookingSubmissionSlotGrid extends StatelessWidget {
  const BookingSubmissionSlotGrid({
    super.key,
    required this.slots,
    required this.selectedIndex,
    required this.unavailableIndices,
    required this.onSelected,
  });

  final List<TeeTimeSlot> slots;
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
              childAspectRatio: 1.45,
            ),
            itemBuilder: (context, index) {
              final slot = slots[index];
              final bool isUnavailable = unavailableIndices.contains(index);
              final bool isSelected = selectedIndex == index;
              final bool isExtendedPlayerSlot = slot.isExtendedPlayerSlot;

              final Color fillColor = isUnavailable
                  ? Colors.grey.shade300
                  : isSelected
                      ? theme.colorScheme.primary
                      : isExtendedPlayerSlot
                          ? const Color(0xFFF6FBF4)
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
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  decoration: BoxDecoration(
                    color: fillColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : isUnavailable
                              ? Colors.grey.shade300
                              : isExtendedPlayerSlot
                                  ? const Color(0xFFB9D6B9)
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        slot.label,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Divider(height: 1, thickness: 1, color: dividerColor),
                      const SizedBox(height: 4),
                      Expanded(
                        child: IntrinsicHeight(
                          child: Row(
                            children: [
                              BookingSubmissionMetricColumn(
                                icon: Icons.group_outlined,
                                label: 'Players',
                                value: slot.playerRange,
                                color: textColor,
                              ),
                              const SizedBox(width: 8),
                              BookingSubmissionMetricColumn(
                                icon: Icons.golf_course_outlined,
                                label: 'Rounds',
                                value: '1',
                                color: textColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (isExtendedPlayerSlot)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFF7C948)
                                : const Color(0xFFE3F3E6),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Extended Group Slot',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF0D7A3A),
                              fontWeight: FontWeight.w700,
                              fontSize: 9,
                            ),
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
