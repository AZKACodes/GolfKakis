import 'package:flutter/material.dart';

class BookingPage extends StatelessWidget {
  const BookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Booking',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}
