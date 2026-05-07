import 'package:flutter/material.dart';

class CourseNearbyButton extends StatelessWidget {
  const CourseNearbyButton({
    required this.isActive,
    required this.onTap,
    super.key,
  });

  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? const Color(0xFF173B7A) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive
                  ? const Color(0xFF173B7A)
                  : const Color(0xFFE1E7E4),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.my_location,
                size: 18,
                color: isActive ? Colors.white : const Color(0xFF173B7A),
              ),
              const SizedBox(width: 8),
              Text(
                'Nearby',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isActive ? Colors.white : const Color(0xFF173B7A),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
