import 'package:flutter/material.dart';

class ActivityOverviewPage extends StatelessWidget {
  const ActivityOverviewPage({super.key});

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
