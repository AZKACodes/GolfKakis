import 'package:flutter/material.dart';
import 'package:golf_kakis/features/booking/submission/slot/view/widgets/bottomsheet/golf_club_picker.dart';
import 'package:golf_kakis/features/foundation/model/booking/golf_club_model.dart';
import 'package:golf_kakis/features/foundation/widgets/icon_info_pill.dart';

class GolfClubPickerCard extends StatelessWidget {
  const GolfClubPickerCard({
    required this.selectedClub,
    required this.clubs,
    required this.isLoading,
    required this.enabled,
    required this.onClubSelected,
    super.key,
  });

  final GolfClubModel? selectedClub;
  final List<GolfClubModel> clubs;
  final bool isLoading;
  final bool enabled;
  final ValueChanged<GolfClubModel> onClubSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final club = selectedClub;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? () => showClubPicker(context) : null,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: <Color>[Color(0xFFF5FBF5), Color(0xFFEAF4EE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFCEE2D2)),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D7A3A),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.golf_course_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: isLoading
                      ? Row(
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Loading golf clubs...',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : club == null
                      ? Text(
                          'No golf clubs available',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              club.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0A1F1A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              club.address,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                IconInfoPill(
                                  icon: Icons.flag_outlined,
                                  label: '${club.noOfHoles} holes',
                                ),
                        
                              ],
                            ),
                          ],
                        ),
                ),
                const SizedBox(width: 12),
                if (!isLoading)
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0x1A000000)),
                    ),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF0A1F1A),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> showClubPicker(BuildContext context) async {
    await GolfClubPicker.show(
      context: context,
      clubs: clubs,
      selectedClub: selectedClub,
      onClubSelected: onClubSelected,
    );
  }
}
