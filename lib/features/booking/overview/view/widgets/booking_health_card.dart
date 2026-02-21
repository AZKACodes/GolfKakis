import 'package:flutter/material.dart';

class BookingHealthCard extends StatelessWidget {
  const BookingHealthCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: const Column(
        children: [
          _HealthRow(label: 'Upcoming Confirmed', value: '2'),
          SizedBox(height: 10),
          _HealthRow(label: 'Pending Payment', value: '1'),
          SizedBox(height: 10),
          _HealthRow(label: 'Avg Booking Lead Time', value: '3.4 days'),
        ],
      ),
    );
  }
}

class _HealthRow extends StatelessWidget {
  const _HealthRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF12332A),
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
