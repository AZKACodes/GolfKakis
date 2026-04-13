import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_model.dart';
import 'package:golf_kakis/features/foundation/widgets/icon_info_pill.dart';
import 'package:golf_kakis/features/foundation/widgets/status_pill.dart';

class BookingDetailsContainer extends StatelessWidget {
  const BookingDetailsContainer({
    required this.item,
    required this.onViewBookingDetailClick,
    super.key,
  });

  final BookingModel item;
  final ValueChanged<BookingModel> onViewBookingDetailClick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.courseName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              StatusPill(label: item.statusLabel, color: item.statusColor),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.dateLabel,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.black87,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.timeLabel,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              IconInfoPill(
                icon: Icons.groups_outlined,
                label: item.playersLabel,
                backgroundColor: Colors.grey.shade100,
                borderColor: Colors.transparent,
                foregroundColor: Colors.black54,
                textColor: Colors.black87,
              ),
              IconInfoPill(
                icon: Icons.account_balance_wallet_outlined,
                label: item.feeLabel,
                backgroundColor: Colors.grey.shade100,
                borderColor: Colors.transparent,
                foregroundColor: Colors.black54,
                textColor: Colors.black87,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => onViewBookingDetailClick(item),
              icon: const Icon(Icons.visibility_outlined),
              label: const Text('View Details'),
            ),
          ),
        ],
      ),
    );
  }
}
