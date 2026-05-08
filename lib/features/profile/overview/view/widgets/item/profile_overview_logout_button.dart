import 'package:flutter/material.dart';

class ProfileOverviewLogoutButton extends StatelessWidget {
  const ProfileOverviewLogoutButton({
    required this.onLogoutClick,
    super.key,
  });

  final VoidCallback onLogoutClick;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onLogoutClick,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          foregroundColor: const Color(0xFF9F2D2D),
          side: const BorderSide(color: Color(0xFFE7A1A1)),
          backgroundColor: Colors.white,
        ),
        icon: const Icon(Icons.logout_outlined),
        label: const Text('Logout'),
      ),
    );
  }
}
