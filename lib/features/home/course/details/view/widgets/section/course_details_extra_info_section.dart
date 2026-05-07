import 'package:flutter/material.dart';

import '../item/course_details_facility_chip.dart';
import '../item/course_details_section_card.dart';

class CourseDetailsExtraInfoSection extends StatefulWidget {
  const CourseDetailsExtraInfoSection({
    required this.description,
    required this.facilityLabels,
    required this.photoUrls,
    required this.courseName,
    super.key,
  });

  final String description;
  final List<String> facilityLabels;
  final List<String> photoUrls;
  final String courseName;

  @override
  State<CourseDetailsExtraInfoSection> createState() =>
      _CourseDetailsExtraInfoSectionState();
}

class _CourseDetailsExtraInfoSectionState
    extends State<CourseDetailsExtraInfoSection> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final galleryItems = widget.photoUrls.isNotEmpty
        ? widget.photoUrls
        : const <String>[];

    return CourseDetailsSectionCard(
      title: 'Course Details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.black87,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Facilities',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in widget.facilityLabels)
                CourseDetailsFacilityChip(label: item),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Course Gallery',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 190,
            child: galleryItems.isEmpty
                ? _GalleryPlaceholder(courseName: widget.courseName)
                : PageView.builder(
                    controller: _pageController,
                    itemCount: galleryItems.length,
                    onPageChanged: (value) {
                      setState(() {
                        _currentPage = value;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(
                          right: index == galleryItems.length - 1 ? 0 : 12,
                        ),
                        child: _GalleryImageCard(
                          imageUrl: galleryItems[index],
                          title: '${widget.courseName} View ${index + 1}',
                        ),
                      );
                    },
                  ),
          ),
          if (galleryItems.length > 1) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(galleryItems.length, (index) {
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
      ),
    );
  }
}

class _GalleryImageCard extends StatelessWidget {
  const _GalleryImageCard({required this.imageUrl, required this.title});

  final String imageUrl;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const _GalleryFallbackBackground();
            },
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[
                  Colors.black.withValues(alpha: 0.05),
                  Colors.black.withValues(alpha: 0.5),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned(
            left: 14,
            right: 14,
            bottom: 14,
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GalleryPlaceholder extends StatelessWidget {
  const _GalleryPlaceholder({required this.courseName});

  final String courseName;

  @override
  Widget build(BuildContext context) {
    return const _GalleryFallbackBackground();
  }
}

class _GalleryFallbackBackground extends StatelessWidget {
  const _GalleryFallbackBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFF173B7A), Color(0xFF2A7A62)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          'Course gallery',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
