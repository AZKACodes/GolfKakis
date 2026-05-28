import 'package:flutter/material.dart';

class CourseDetailsBottomBarSection extends StatelessWidget {
  const CourseDetailsBottomBarSection({
    required this.onBookNowTap,
    required this.onCallTap,
    required this.onDirectionsTap,
    super.key,
  });

  final VoidCallback onBookNowTap;
  final VoidCallback onCallTap;
  final VoidCallback onDirectionsTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(22, 10, 22, 18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(36),
          boxShadow: const [
            BoxShadow(
              color: Color(0x18000000),
              blurRadius: 22,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            _RoundActionButton(icon: Icons.call_outlined, onPressed: onCallTap),
            const SizedBox(width: 14),
            Expanded(
              child: FilledButton(
                onPressed: onBookNowTap,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0D8BFF),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(58),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  'Book Now',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(width: 14),
            _RoundActionButton(
              icon: Icons.directions_outlined,
              onPressed: onDirectionsTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundActionButton extends StatelessWidget {
  const _RoundActionButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      shadowColor: const Color(0x18000000),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        color: Colors.black87,
        constraints: const BoxConstraints.tightFor(width: 56, height: 56),
      ),
    );
  }
}
