import 'package:flutter/material.dart';

import '../item/course_details_hero_card.dart';

class CourseDetailsHeaderSection extends StatelessWidget {
  const CourseDetailsHeaderSection({
    required this.clubName,
    required this.address,
    required this.distanceLabel,
    required this.openSlotsLabel,
    required this.weekdayStartingPriceLabel,
    required this.weekendStartingPriceLabel,
    super.key,
  });

  final String clubName;
  final String address;
  final String distanceLabel;
  final String openSlotsLabel;
  final String weekdayStartingPriceLabel;
  final String weekendStartingPriceLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              CourseDetailsHeroCard(clubName: clubName, address: address),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _HeaderInfoPill(
                      icon: Icons.near_me_outlined,
                      label: 'Distance',
                      value: distanceLabel,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _HeaderInfoPill(
                      icon: Icons.event_available_outlined,
                      label: 'Slots',
                      value: openSlotsLabel,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _StartingFromCard(
                weekdayStartingPriceLabel: weekdayStartingPriceLabel,
                weekendStartingPriceLabel: weekendStartingPriceLabel,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeaderInfoPill extends StatelessWidget {
  const _HeaderInfoPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE1E7E4)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF173B7A)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0A1F1A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StartingFromCard extends StatelessWidget {
  const _StartingFromCard({
    required this.weekdayStartingPriceLabel,
    required this.weekendStartingPriceLabel,
  });

  final String weekdayStartingPriceLabel;
  final String weekendStartingPriceLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE1E7E4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.payments_outlined,
                size: 18,
                color: Color(0xFF173B7A),
              ),
              const SizedBox(width: 8),
              Text(
                'Starting From',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0A1F1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _StartingFromRow(label: 'Weekday', value: weekdayStartingPriceLabel),
          const SizedBox(height: 6),
          _StartingFromRow(label: 'Weekend', value: weekendStartingPriceLabel),
        ],
      ),
    );
  }
}

class _StartingFromRow extends StatelessWidget {
  const _StartingFromRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label :',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.black54,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0A1F1A),
            ),
          ),
        ),
      ],
    );
  }
}
