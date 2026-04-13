import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_model.dart';

import '../../viewmodel/booking_list_view_contract.dart';
import 'booking_details_container.dart';

class BookingTabContent extends StatelessWidget {
  const BookingTabContent({
    required this.bookings,
    required this.emptyLabel,
    required this.isLoading,
    required this.hasLoaded,
    required this.tab,
    required this.onRefresh,
    required this.onViewBookingDetailClick,
    super.key,
  });

  final List<BookingModel> bookings;
  final String emptyLabel;
  final bool isLoading;
  final bool hasLoaded;
  final BookingListTab tab;
  final Future<void> Function(BookingListTab tab) onRefresh;
  final ValueChanged<BookingModel> onViewBookingDetailClick;

  @override
  Widget build(BuildContext context) {
    if (isLoading && !hasLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => onRefresh(tab),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (bookings.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  emptyLabel,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList.separated(
                itemCount: bookings.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, index) => BookingDetailsContainer(
                  item: bookings[index],
                  onViewBookingDetailClick: onViewBookingDetailClick,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
