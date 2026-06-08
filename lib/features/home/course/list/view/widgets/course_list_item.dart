import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/model/courses_list_item_view_data.dart';

class CourseListItem extends StatelessWidget {
  const CourseListItem({required this.club, required this.onTap, super.key});

  final CoursesListItemViewData club;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final visibleFacilities = club.facilities.take(6).toList();
    final isEnabled = club.isEnabled;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          decoration: BoxDecoration(
            color: isEnabled ? Colors.white : const Color(0xFFF4F5F7),
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                child: AspectRatio(
                  aspectRatio: 2.16,
                  child:
                      club.coverPhotoUrl != null &&
                          club.coverPhotoUrl!.trim().isNotEmpty
                      ? Image.network(
                          club.coverPhotoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const _CourseCoverPlaceholder(),
                        )
                      : const _CourseCoverPlaceholder(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(26, 22, 26, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      club.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: isDarkMode ? Colors.grey.shade300 : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _CourseFeatureGrid(
                      facilities: visibleFacilities,
                      holesLabel: club.holesLabel,
                      distanceLabel: club.distanceLabel,
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton(
                        onPressed: isEnabled ? onTap : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF139CEB),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(164, 54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: Text(
                          isEnabled ? 'Book Now' : 'Coming Soon',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CourseCoverPlaceholder extends StatelessWidget {
  const _CourseCoverPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/course_placeholder.png',
      fit: BoxFit.cover,
    );
  }
}

class _CourseFeatureGrid extends StatelessWidget {
  const _CourseFeatureGrid({
    required this.facilities,
    required this.holesLabel,
    required this.distanceLabel,
  });

  final List<CoursesListFacilityItemViewData> facilities;
  final String holesLabel;
  final String? distanceLabel;

  @override
  Widget build(BuildContext context) {
    final items = <_FeatureDisplayItem>[
      _FeatureDisplayItem(icon: Icons.golf_course_outlined, label: holesLabel),
      if (distanceLabel != null)
        _FeatureDisplayItem(
          icon: Icons.near_me_outlined,
          label: distanceLabel!,
        ),
      for (final facility in facilities)
        if (!_isDuplicateHoleFacility(facility, holesLabel))
          _FeatureDisplayItem(
            icon: _resolveFacilityIcon(facility.facilityType),
            label: facility.title,
          ),
    ].take(6).toList();

    return Wrap(
      spacing: 16,
      runSpacing: 14,
      children: [for (final item in items) _FeatureDisplay(item: item)],
    );
  }
}

bool _isDuplicateHoleFacility(
  CoursesListFacilityItemViewData facility,
  String holesLabel,
) {
  final type = facility.facilityType.trim().toLowerCase();
  final title = facility.title.trim().toLowerCase();
  final holes = holesLabel.trim().toLowerCase();

  if (type == 'routing_18_holes' ||
      type == 'holes_18' ||
      title == '18-hole routing') {
    return true;
  }

  return title == holes;
}

class _FeatureDisplay extends StatelessWidget {
  const _FeatureDisplay({required this.item});

  final _FeatureDisplayItem item;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 142,
      child: Row(
        children: [
          Icon(item.icon, size: 24, color: const Color(0xFF139CEB)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureDisplayItem {
  const _FeatureDisplayItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
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
      return Icons.directions_car_outlined;
    case 'restaurant':
    case 'cafe':
      return Icons.restaurant_outlined;
    case 'driving_range':
      return Icons.sports_golf_outlined;
    case 'locker_room':
    case 'shower':
      return Icons.bathtub_outlined;
    case 'pay_counter':
    case 'payment_at_club':
      return Icons.payments_outlined;
    case 'pro_shop':
      return Icons.storefront_outlined;
    default:
      return Icons.check_circle_outline;
  }
}
