import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/model/home/home_advertisement_view_data.dart';

import '../item/home_announcement_item.dart';

class HomeAnnouncementSection extends StatefulWidget {
  const HomeAnnouncementSection({required this.items, super.key});

  final List<HomeAdvertisementViewData> items;

  @override
  State<HomeAnnouncementSection> createState() =>
      _HomeAnnouncementSectionState();
}

class _HomeAnnouncementSectionState extends State<HomeAnnouncementSection> {
  late final PageController _controller;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.92);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Advertisements',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: widget.items.isEmpty
              ? const _EmptyAnnouncementCard()
              : PageView.builder(
                  controller: _controller,
                  itemCount: widget.items.length,
                  onPageChanged: (value) {
                    setState(() {
                      _currentPage = value;
                    });
                  },
                  itemBuilder: (context, index) {
                    final item = widget.items[index];
                    final isLast = index == widget.items.length - 1;
                    return Padding(
                      padding: EdgeInsets.only(right: isLast ? 0 : 10),
                      child: HomeAnnouncementItemCard(item: item, index: index),
                    );
                  },
                ),
        ),
        if (widget.items.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List<Widget>.generate(widget.items.length, (index) {
              final isActive = index == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 22 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF173B7A)
                      : const Color(0xFFD7DEE7),
                  borderRadius: BorderRadius.circular(999),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

class _EmptyAnnouncementCard extends StatelessWidget {
  const _EmptyAnnouncementCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFF173B7A), Color(0xFF2F7BFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Advertisement',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Promotions will appear here soon.',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
