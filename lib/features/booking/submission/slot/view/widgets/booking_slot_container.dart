import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/enums/booking/tee_time_slot.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_slot_model.dart';
import 'package:golf_kakis/features/foundation/util/currency_util.dart';
import 'package:golf_kakis/features/foundation/widgets/icon_info_pill.dart';

class BookingSlotContainer extends StatelessWidget {
  const BookingSlotContainer({
    super.key,
    required this.slots,
    required this.selectedIndex,
    required this.unavailableIndices,
    required this.onSelected,
  });

  final List<BookingSlotModel> slots;
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
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: slots.length,
            separatorBuilder: (_, _) => const SizedBox(height: spacing),
            itemBuilder: (context, index) {
              final slot = slots[index];
              final teeTimeSlot = TeeTimeSlot.fromLabel(slot.time);

              final bool isUnavailable = unavailableIndices.contains(index);
              final bool isSelected = selectedIndex == index;
              final bool isExtendedPlayerSlot =
                  teeTimeSlot?.isExtendedPlayerSlot ?? false;

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
                borderRadius: BorderRadius.circular(18),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 170),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: fillColor,
                    borderRadius: BorderRadius.circular(18),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: Center(
                              child: Text(
                                slot.time,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: textColor,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ),
                          ),

                          if (isSelected)
                            const Positioned(
                              right: 0,
                              child: Icon(
                                Icons.check_circle_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Divider(height: 1, thickness: 1, color: dividerColor),

                      const SizedBox(height: 10),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Price / pax',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: textColor.withValues(
                                          alpha: 0.78,
                                        ),
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  CurrencyUtil.formatPrice(
                                    slot.price,
                                    slot.currency,
                                    suffix: '/ pax',
                                  ),
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        color: textColor,
                                        fontWeight: FontWeight.w900,
                                      ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            flex: 3,
                            child: IconInfoPill(
                              icon: Icons.group_outlined,
                              label: 'Players',
                              value: teeTimeSlot?.playerRange ?? '1-4',
                              backgroundColor: isSelected
                                  ? Colors.white.withValues(alpha: 0.12)
                                  : const Color(0xFFF7F7F4),
                              borderColor: isSelected
                                  ? Colors.white.withValues(alpha: 0.16)
                                  : const Color(0x14000000),
                              foregroundColor: textColor,
                              textColor: textColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              borderRadius: 12,
                              iconSize: 16,
                              spacing: 8,
                              expandContent: true,
                              labelStyle: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: textColor.withValues(alpha: 0.82),
                                    fontWeight: FontWeight.w700,
                                  ),
                              valueStyle: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: textColor,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            flex: 3,
                            child: IconInfoPill(
                              icon: Icons.golf_course_outlined,
                              label: 'Holes',
                              value: '${slot.noOfHoles}',
                              backgroundColor: isSelected
                                  ? Colors.white.withValues(alpha: 0.12)
                                  : const Color(0xFFF7F7F4),
                              borderColor: isSelected
                                  ? Colors.white.withValues(alpha: 0.16)
                                  : const Color(0x14000000),
                              foregroundColor: textColor,
                              textColor: textColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              borderRadius: 12,
                              iconSize: 16,
                              spacing: 8,
                              expandContent: true,
                              labelStyle: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: textColor.withValues(alpha: 0.82),
                                    fontWeight: FontWeight.w700,
                                  ),
                              valueStyle: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: textColor,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ),
                        ],
                      ),

                      if (isExtendedPlayerSlot)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
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
                                fontWeight: FontWeight.w800,
                              ),
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
