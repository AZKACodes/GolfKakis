import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/model/home/courses_list_item_view_data.dart';

class CourseListItem extends StatelessWidget {
  const CourseListItem({
    required this.club,
    required this.onTap,
    super.key,
  });

  final CoursesListItemViewData club;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final visibleFacilities = club.facilities.take(4).toList();
    final isEnabled = club.isEnabled;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isEnabled ? Colors.white : const Color(0xFFF4F5F7),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isEnabled
                  ? const Color(0xFFE1E7E4)
                  : const Color(0xFFD7DCE3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          club.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: isEnabled ? null : Colors.black45,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          club.address,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: isEnabled ? Colors.black54 : Colors.black38,
                              ),
                        ),
                        if (club.distanceLabel != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            club.distanceLabel!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: const Color(0xFF173B7A),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                        if (!isEnabled) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Coming soon',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF8A5A00),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isEnabled
                          ? const Color(0xFFEAF6F0)
                          : const Color(0xFFE7EBF0),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      club.holesLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isEnabled
                            ? const Color(0xFF1E5B4A)
                            : const Color(0xFF667085),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (visibleFacilities.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final facility in visibleFacilities)
                      _CourseFacilityChip(facility: facility),
                  ],
                ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: isEnabled ? onTap : null,
                  child: Text(isEnabled ? 'View Details' : 'Unavailable'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CourseFacilityChip extends StatelessWidget {
  const _CourseFacilityChip({required this.facility});

  final CoursesListFacilityItemViewData facility;

  @override
  Widget build(BuildContext context) {
    final icon = _resolveFacilityIcon(facility.facilityType);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E7F4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF173B7A)),
          const SizedBox(width: 8),
          Text(
            facility.title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF173B7A),
            ),
          ),
        ],
      ),
    );
  }
}

IconData _resolveFacilityIcon(String facilityType) {
  switch (facilityType.trim().toLowerCase()) {
    case 'holes_18':
    case 'routing_18_holes':
    case 'supports_nine_holes':
    case 'golf_course':
      return Icons.golf_course_outlined;
    case 'buggy_required':
    case 'buggy_optional':
    case 'required':
    case 'optional':
    case 'golf_cart':
      return Icons.golf_course;
    case 'restaurant':
    case 'cafe':
      return Icons.restaurant_outlined;
    case 'driving_range':
      return Icons.sports_golf_outlined;
    case 'locker_room':
    case 'shower':
      return Icons.room_preferences_outlined;
    case 'pay_counter':
    case 'payment_at_club':
      return Icons.payments_outlined;
    case 'pro_shop':
      return Icons.storefront_outlined;
    default:
      return Icons.check_circle_outline;
  }
}
