import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/model/booking/golf_club_model.dart';
import 'package:golf_kakis/features/foundation/util/string_util.dart';

class HomeGolfClubListCard extends StatelessWidget {
  const HomeGolfClubListCard({
    required this.club,
    required this.onTap,
    super.key,
  });

  final GolfClubModel club;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final supportsNineHoles =
        club.supportsNineHoles || club.supportedNines.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE1E7E4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          club.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          club.address,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF6F0),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${club.noOfHoles} holes',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF1E5B4A),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _ClubMetaChip(
                      icon: Icons.flag_outlined,
                      label: supportsNineHoles
                          ? 'Supports 9 holes'
                          : '18-hole routing',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ClubMetaChip(
                      icon: Icons.payments_outlined,
                      label: club.paymentMethods.isEmpty
                          ? 'Payment at club'
                          : StringUtil.formatSentenceLabel(
                              club.paymentMethods.first,
                              fallback: 'Payment at club',
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: onTap,
                  child: const Text('View Details'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClubMetaChip extends StatelessWidget {
  const _ClubMetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF173B7A)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF173B7A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
