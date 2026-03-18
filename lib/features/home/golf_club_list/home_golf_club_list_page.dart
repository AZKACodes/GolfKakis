import 'package:flutter/material.dart';
import 'package:golf_kakis/features/booking/club/detail/golf_club_detail_page.dart';
import 'package:golf_kakis/features/foundation/model/booking/golf_club_model.dart';

class HomeGolfClubListPage extends StatelessWidget {
  const HomeGolfClubListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Golf Club List')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _clubs.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final club = _clubs[index];
          return _GolfClubListCard(
            club: club,
            priceLabel: _priceLabels[index],
            teeWindowLabel: _teeWindowLabels[index],
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => GolfClubDetailPage(club: club),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _GolfClubListCard extends StatelessWidget {
  const _GolfClubListCard({
    required this.club,
    required this.priceLabel,
    required this.teeWindowLabel,
    required this.onTap,
  });

  final GolfClubModel club;
  final String priceLabel;
  final String teeWindowLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
                      icon: Icons.schedule_outlined,
                      label: teeWindowLabel,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ClubMetaChip(
                      icon: Icons.payments_outlined,
                      label: priceLabel,
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

const List<GolfClubModel> _clubs = [
  GolfClubModel(
    id: '1',
    slug: 'kinrara-golf-club',
    name: 'Kinrara Golf Club',
    address: 'Bandar Kinrara, Puchong',
    noOfHoles: 18,
  ),
  GolfClubModel(
    id: '2',
    slug: 'saujana-golf-country-club',
    name: 'Saujana Golf & Country Club',
    address: 'Shah Alam, Selangor',
    noOfHoles: 36,
  ),
  GolfClubModel(
    id: '3',
    slug: 'kota-permai-golf-country-club',
    name: 'Kota Permai Golf & Country Club',
    address: 'Kota Kemuning, Shah Alam',
    noOfHoles: 18,
  ),
  GolfClubModel(
    id: '4',
    slug: 'mines-resort-golf-club',
    name: 'The Mines Resort & Golf Club',
    address: 'Serdang, Selangor',
    noOfHoles: 18,
  ),
];

const List<String> _priceLabels = [
  'From MYR 39',
  'From MYR 52',
  'From MYR 47',
  'From MYR 58',
];

const List<String> _teeWindowLabels = [
  'Morning slots from 7:20 AM',
  'Peak play from 8:00 AM',
  'Weekend tee-off from 7:50 AM',
  'Early access from 7:40 AM',
];
