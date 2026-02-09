import 'package:flutter/material.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Activity',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}
