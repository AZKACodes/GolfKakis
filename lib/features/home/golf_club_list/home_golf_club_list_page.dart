import 'package:flutter/material.dart';
import 'package:golf_kakis/features/booking/api/booking_api_service.dart';
import 'package:golf_kakis/features/booking/club/detail/golf_club_detail_page.dart';
import 'package:golf_kakis/features/foundation/model/booking/golf_club_model.dart';

const double _bottomNavScrollClearance = 136;

class HomeGolfClubListPage extends StatefulWidget {
  const HomeGolfClubListPage({super.key});

  @override
  State<HomeGolfClubListPage> createState() => _HomeGolfClubListPageState();
}

class _HomeGolfClubListPageState extends State<HomeGolfClubListPage> {
  late final BookingApiService _apiService;
  late Future<List<GolfClubModel>> _clubsFuture;

  @override
  void initState() {
    super.initState();
    _apiService = BookingApiService();
    _clubsFuture = _loadClubs();
  }

  Future<List<GolfClubModel>> _loadClubs() async {
    final response = await _apiService.onFetchGolfClubList();
    return _parseGolfClubList(response);
  }

  Future<void> _refresh() async {
    final future = _loadClubs();
    setState(() {
      _clubsFuture = future;
    });
    await future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Golf Club List')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<GolfClubModel>>(
          future: _clubsFuture,
          builder: (context, snapshot) {
            final clubs = snapshot.data ?? const <GolfClubModel>[];

            if (snapshot.connectionState == ConnectionState.waiting &&
                clubs.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError && clubs.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  16,
                  32,
                  16,
                  _bottomNavScrollClearance,
                ),
                children: [
                  _EmptyState(
                    title: 'Unable to load golf clubs',
                    message: 'Pull to refresh and try again.',
                  ),
                ],
              );
            }

            if (clubs.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  16,
                  32,
                  16,
                  _bottomNavScrollClearance,
                ),
                children: const [
                  _EmptyState(
                    title: 'No golf clubs found',
                    message: 'Try again in a moment.',
                  ),
                ],
              );
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                _bottomNavScrollClearance,
              ),
              itemCount: clubs.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final club = clubs[index];
                return _GolfClubListCard(
                  club: club,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => GolfClubDetailPage(
                          clubSlug: club.slug,
                          initialClub: club,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  List<GolfClubModel> _parseGolfClubList(dynamic rawResponse) {
    if (rawResponse is List) {
      return rawResponse
          .whereType<Map<String, dynamic>>()
          .map(GolfClubModel.fromJson)
          .where((club) => club.slug.isNotEmpty)
          .toList();
    }

    if (rawResponse is Map<String, dynamic>) {
      final dynamic nestedList =
          rawResponse['data'] ??
          rawResponse['items'] ??
          rawResponse['clubs'] ??
          rawResponse['golfClubs'];
      return _parseGolfClubList(nestedList);
    }

    return const <GolfClubModel>[];
  }
}

class _GolfClubListCard extends StatelessWidget {
  const _GolfClubListCard({required this.club, required this.onTap});

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
                          : _formatSentenceLabel(club.paymentMethods.first),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE1E7E4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

String _formatSentenceLabel(String value) {
  final normalized = value.trim();
  if (normalized.isEmpty) {
    return 'Payment at club';
  }

  return normalized
      .split('_')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}
