import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/model/golf_club_model.dart';

import '../../../viewmodel/booking_submission_slot_view_contract.dart';

class GolfClubSelectionBottomSheet {
  const GolfClubSelectionBottomSheet._();

  static Future<void> show({
    required BuildContext context,
    required List<GolfClubModel> clubs,
    required GolfClubModel? selectedClub,
    required ValueChanged<GolfClubModel> onClubSelected,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _GolfClubSelectionSheet(
        clubs: clubs,
        selectedClub: selectedClub,
        onClubSelected: onClubSelected,
      ),
    );
  }
}

class _GolfClubSelectionSheet extends StatefulWidget {
  const _GolfClubSelectionSheet({
    required this.clubs,
    required this.selectedClub,
    required this.onClubSelected,
  });

  final List<GolfClubModel> clubs;
  final GolfClubModel? selectedClub;
  final ValueChanged<GolfClubModel> onClubSelected;

  @override
  State<_GolfClubSelectionSheet> createState() =>
      _GolfClubSelectionSheetState();
}

class _GolfClubSelectionSheetState extends State<_GolfClubSelectionSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clubs = _filteredClubs;
    final sheetHeight = MediaQuery.sizeOf(context).height * 0.86;

    return Container(
      height: sheetHeight,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 44,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: Text(
                      'Select Golf Club',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            const Divider(height: 1),

            const SizedBox(height: 16),

            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search golf clubs',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.trim().isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
                filled: true,
                fillColor: const Color(0xFFF6F7F4),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0x14000000)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0x14000000)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF0D7A3A)),
                ),
              ),
            ),

            const SizedBox(height: 14),

            Expanded(
              child: clubs.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Text(
                          'No golf clubs found',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: clubs.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final club = clubs[index];
                        return _GolfClubSelectionItem(
                          club: club,
                          selectedClub: widget.selectedClub,
                          onClubSelected: widget.onClubSelected,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<GolfClubModel> get _filteredClubs {
    final normalizedQuery = _query.trim().toLowerCase();
    final sorted = List<GolfClubModel>.of(widget.clubs)
      ..sort((a, b) {
        final aEnabled = isGolfClubEnabledForCurrentRelease(a);
        final bEnabled = isGolfClubEnabledForCurrentRelease(b);
        if (aEnabled != bEnabled) {
          return aEnabled ? -1 : 1;
        }
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

    if (normalizedQuery.isEmpty) {
      return sorted;
    }

    return sorted.where((club) {
      final searchable = '${club.name} ${club.address} ${club.slug}'
          .toLowerCase();
      return searchable.contains(normalizedQuery);
    }).toList();
  }
}

class _GolfClubSelectionItem extends StatelessWidget {
  const _GolfClubSelectionItem({
    required this.club,
    required this.selectedClub,
    required this.onClubSelected,
  });

  final GolfClubModel club;
  final GolfClubModel? selectedClub;
  final ValueChanged<GolfClubModel> onClubSelected;

  @override
  Widget build(BuildContext context) {
    final isEnabled = isGolfClubEnabledForCurrentRelease(club);
    final isSelected = club.slug == selectedClub?.slug;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: isEnabled
            ? () {
                Navigator.of(context).pop();
                onClubSelected(club);
              }
            : null,
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFF0F8F2)
                : const Color(0xFFF8F8F6),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF0D7A3A)
                  : const Color(0x14000000),
            ),
          ),
          child: Row(
            children: [
              Opacity(
                opacity: isEnabled ? 1 : 0.45,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isEnabled
                        ? const Color(0xFFE2F3E8)
                        : const Color(0xFFE9E9E6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isEnabled
                        ? Icons.golf_course_rounded
                        : Icons.lock_outline_rounded,
                    size: 20,
                    color: isEnabled ? const Color(0xFF0D7A3A) : Colors.black38,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Opacity(
                  opacity: isEnabled ? 1 : 0.52,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        club.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        club.address,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                      ),

                      if (!isEnabled) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Coming soon',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Colors.black45,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Opacity(
                opacity: isEnabled ? 1 : 0.45,
                child: Text(
                  '${club.noOfHoles} holes',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF0D7A3A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              if (isSelected) ...[
                const SizedBox(width: 10),
                const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF0D7A3A),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
