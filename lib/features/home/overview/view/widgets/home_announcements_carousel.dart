import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/model/home/home_announcement_item.dart';

class HomeAnnouncementsCarousel extends StatefulWidget {
  const HomeAnnouncementsCarousel({super.key});

  @override
  State<HomeAnnouncementsCarousel> createState() =>
      _HomeAnnouncementsCarouselState();
}

class _HomeAnnouncementsCarouselState extends State<HomeAnnouncementsCarousel> {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 176,
          child: PageView.builder(
            controller: _controller,
            itemCount: _announcements.length,
            onPageChanged: (value) {
              setState(() {
                _currentPage = value;
              });
            },
            itemBuilder: (context, index) {
              final item = _announcements[index];
              final isLast = index == _announcements.length - 1;
              return Padding(
                padding: EdgeInsets.only(right: isLast ? 0 : 10),
                child: _AnnouncementCard(item: item),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List<Widget>.generate(_announcements.length, (index) {
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
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({required this.item});

  final HomeAnnouncementItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: item.colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  item.tag,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              Icon(item.icon, color: Colors.white70),
            ],
          ),
          const Spacer(),
          Text(
            item.title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.88),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

const List<HomeAnnouncementItem> _announcements = <HomeAnnouncementItem>[
  HomeAnnouncementItem(
    tag: 'Club Notice',
    title: 'Weekend tee sheet opens earlier this Friday',
    subtitle:
        'Members can secure preferred morning slots from 6:00 PM onwards.',
    icon: Icons.event_available_outlined,
    colors: <Color>[Color(0xFF173B7A), Color(0xFF2F7BFF)],
  ),
  HomeAnnouncementItem(
    tag: 'Course Update',
    title: 'Kinrara greens maintenance scheduled tomorrow',
    subtitle:
        'Expect smoother front-nine play with light maintenance on selected holes.',
    icon: Icons.grass_outlined,
    colors: <Color>[Color(0xFF14532D), Color(0xFF2F855A)],
  ),
  HomeAnnouncementItem(
    tag: 'Promo',
    title: 'Early-bird weekday rounds now from MYR 39',
    subtitle:
        'Book selected morning sessions and lock in lower rates before noon.',
    icon: Icons.local_offer_outlined,
    colors: <Color>[Color(0xFF7C2D12), Color(0xFFEA580C)],
  ),
];
