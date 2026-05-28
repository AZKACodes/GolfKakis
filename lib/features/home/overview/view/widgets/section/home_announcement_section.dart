import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/model/home_announcement_view_data.dart';

import '../item/home_announcement_item.dart';

class HomeAnnouncementSection extends StatefulWidget {
  const HomeAnnouncementSection({required this.items, super.key});

  final List<HomeAnnouncementViewData> items;

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
    _controller = PageController(viewportFraction: 0.9);
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
          height: 208,
          child: widget.items.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: _EmptyAnnouncementCard(),
                )
              : PageView.builder(
                  padEnds: false,
                  controller: _controller,
                  itemCount: widget.items.length,
                  onPageChanged: (value) {
                    setState(() {
                      _currentPage = value;
                    });
                  },
                  itemBuilder: (context, index) {
                    final item = widget.items[index];
                    final isFirst = index == 0;
                    final isLast = index == widget.items.length - 1;
                    return Padding(
                      padding: EdgeInsets.only(
                        left: isFirst ? 16 : 0,
                        right: isLast ? 16 : 10,
                      ),
                      child: HomeAnnouncementItemCard(
                        item: item,
                        index: index,
                        onTap: () => _showAnnouncementDetails(context, item),
                      ),
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
                      ? const Color(0xFF0A1F1A)
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

void _showAnnouncementDetails(
  BuildContext context,
  HomeAnnouncementViewData item,
) {
  showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    useSafeArea: true,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) {
      return _AnnouncementDetailsSheet(item: item);
    },
  );
}

class _AnnouncementDetailsSheet extends StatelessWidget {
  const _AnnouncementDetailsSheet({required this.item});

  final HomeAnnouncementViewData item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = item.imageUrl?.trim();
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        24 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: hasImage
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const _AnnouncementSheetPlaceholder();
                      },
                    )
                  : const _AnnouncementSheetPlaceholder(),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF6F0),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              item.announcementType,
              style: theme.textTheme.labelMedium?.copyWith(
                color: const Color(0xFF1E5B4A),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            item.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w900,
              height: 1.08,
            ),
          ),
          if (item.subtitle.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              item.subtitle,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AnnouncementSheetPlaceholder extends StatelessWidget {
  const _AnnouncementSheetPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[Color(0xFF0A1F1A), Color(0xFF2FBF71)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(Icons.campaign_outlined, color: Colors.white, size: 42),
      ),
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
          colors: <Color>[Color(0xFF0A1F1A), Color(0xFF2FBF71)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Announcement',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Announcements will appear here soon.',
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
