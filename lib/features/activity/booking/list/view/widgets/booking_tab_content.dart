import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_model.dart';
import 'package:golf_kakis/features/foundation/widgets/error_banner.dart';
import 'package:golf_kakis/features/foundation/widgets/info_banner.dart';

import '../../viewmodel/activity_booking_list_view_contract.dart';
import 'booking_details_container.dart';

class BookingTabContent extends StatelessWidget {
  const BookingTabContent({
    required this.bookings,
    required this.emptyLabel,
    required this.isLoading,
    required this.hasLoaded,
    required this.isUsingFallback,
    required this.errorMessage,
    required this.tab,
    required this.onRetryClick,
    required this.onRefresh,
    required this.onViewBookingDetailClick,
    super.key,
  });

  final List<BookingModel> bookings;
  final String emptyLabel;
  final bool isLoading;
  final bool hasLoaded;
  final bool isUsingFallback;
  final String? errorMessage;
  final ActivityBookingListTab tab;
  final ValueChanged<ActivityBookingListTab> onRetryClick;
  final Future<void> Function(ActivityBookingListTab tab) onRefresh;
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
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate.fixed([
                if (isUsingFallback) ...[
                  const InfoBanner(
                    message:
                        'Showing fallback bookings until this endpoint is ready.',
                  ),

                  const SizedBox(height: 12),
                ],

                if (errorMessage != null) ...[
                  ErrorBanner(
                    message: errorMessage!,
                    actionLabel: 'Retry',
                    onAction: () => onRetryClick(tab),
                  ),

                  const SizedBox(height: 12),
                ],
              ]),
            ),
          ),
          
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
