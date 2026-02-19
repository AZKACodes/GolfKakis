import 'package:flutter/material.dart';

class ProfileOverviewPage extends StatelessWidget {
  const ProfileOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Profile',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}
