import 'package:flutter/material.dart';

import '../data/course_details_repository.dart';
import '../viewmodel/course_details_view_contract.dart';
import 'package:golf_kakis/features/foundation/widgets/container/golf_kakis_loading_container.dart';
import 'widgets/section/course_details_map_section.dart';
import 'widgets/section/course_details_weather_section.dart';

class CourseDetailsView extends StatelessWidget {
  const CourseDetailsView({
    required this.state,
    required this.onRefresh,
    required this.onBackTap,
    required this.onDirectionsTap,
    super.key,
  });

  final CourseDetailsViewState state;
  final Future<void> Function() onRefresh;
  final VoidCallback onBackTap;
  final VoidCallback onDirectionsTap;

  @override
  Widget build(BuildContext context) {
    final detail = state.detail;
    final club = detail.club;

    if (state.isLoading) {
      return _CourseDetailsLoadingView(onBackTap: onBackTap);
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          _CourseCoverHero(
            coverPhotoUrl: _resolveHeaderCoverPhotoUrl(
              galleryImageUrls: club.galleryImageUrls,
              photoUrls: detail.photoUrls,
              coverPhotoUrl: club.coverPhotoUrl,
            ),
            onBackTap: onBackTap,
          ),
          Transform.translate(
            offset: const Offset(0, -36),
            child: _CourseDetailsSheet(
              clubName: club.name,
              address: club.address,
              description: detail.description,
              facilityLabels: detail.facilityLabels,
              photoUrls: detail.photoUrls,
              weather: detail.weather,
              weeklyForecast: detail.weeklyForecast,
              latitude: club.latitude,
              longitude: club.longitude,
              onDirectionsTap: onDirectionsTap,
            ),
          ),
          const SizedBox(height: 96),
        ],
      ),
    );
  }

  String? _resolveHeaderCoverPhotoUrl({
    required List<String> galleryImageUrls,
    required List<String> photoUrls,
    required String? coverPhotoUrl,
  }) {
    if (galleryImageUrls.isNotEmpty) {
      return galleryImageUrls.first;
    }
    if (photoUrls.isNotEmpty) {
      return photoUrls.first;
    }
    return coverPhotoUrl;
  }
}

class _CourseDetailsLoadingView extends StatelessWidget {
  const _CourseDetailsLoadingView({required this.onBackTap});

  final VoidCallback onBackTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: const BoxDecoration(color: Color(0xFFCDEEFF)),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: onBackTap,
                      icon: const Icon(Icons.chevron_left_rounded, size: 34),
                    ),
                  ),
                  Text(
                    'Course Details',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const Expanded(
              child: Center(
                child: GolfKakisLoadingContainer(
                  message: 'Loading golf club details...',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseCoverHero extends StatelessWidget {
  const _CourseCoverHero({
    required this.coverPhotoUrl,
    required this.onBackTap,
  });

  final String? coverPhotoUrl;
  final VoidCallback onBackTap;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return SizedBox(
      height: 360,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (coverPhotoUrl != null && coverPhotoUrl!.trim().isNotEmpty)
            Image.network(
              coverPhotoUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const _CoverPlaceholder(),
            )
          else
            const _CoverPlaceholder(),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0x66000000), Color(0x00000000)],
                begin: Alignment.topCenter,
                end: Alignment.center,
              ),
            ),
          ),
          Positioned(
            top: topPadding + 18,
            left: 24,
            child: _HeroCircleButton(
              icon: Icons.chevron_left_rounded,
              onPressed: onBackTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/course_placeholder.png',
      fit: BoxFit.cover,
    );
  }
}

class _HeroCircleButton extends StatelessWidget {
  const _HeroCircleButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 8,
      shadowColor: const Color(0x22000000),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 30),
        color: Colors.black87,
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(),
      ),
    );
  }
}

class _CourseDetailsSheet extends StatelessWidget {
  const _CourseDetailsSheet({
    required this.clubName,
    required this.address,
    required this.description,
    required this.facilityLabels,
    required this.photoUrls,
    required this.weather,
    required this.weeklyForecast,
    required this.latitude,
    required this.longitude,
    required this.onDirectionsTap,
  });

  final String clubName;
  final String address;
  final String description;
  final List<String> facilityLabels;
  final List<String> photoUrls;
  final CourseWeatherSummary? weather;
  final List<CourseWeatherForecastItem> weeklyForecast;
  final double? latitude;
  final double? longitude;
  final VoidCallback onDirectionsTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedFacilities = facilityLabels.isEmpty
        ? const <String>['Driving Range', 'Changing Room', 'Buggy', 'Caddie']
        : facilityLabels;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 30, 28, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(42)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFF0D7A3A),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _initialFor(clubName),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clubName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address.trim().isEmpty ? 'Golf course' : address,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            description.trim().isEmpty
                ? 'Explore tee times, course facilities, weather and directions before booking your next round.'
                : description,
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.45,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Features',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final label in resolvedFacilities.take(8))
                _FeatureChip(label: label),
            ],
          ),
          const SizedBox(height: 24),
          CourseDetailsWeatherSection(
            weather: weather,
            weatherForecast: weeklyForecast,
          ),
          const SizedBox(height: 16),
          CourseDetailsMapSection(
            address: address,
            latitude: latitude,
            longitude: longitude,
            onDirectionsTap: onDirectionsTap,
          ),
          if (photoUrls.isNotEmpty) ...[
            const SizedBox(height: 24),
            _CourseGallerySection(photoUrls: photoUrls),
          ],
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CourseGallerySection extends StatelessWidget {
  const _CourseGallerySection({required this.photoUrls});

  final List<String> photoUrls;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final galleryItems = photoUrls
        .map((url) => url.trim())
        .where((url) => url.isNotEmpty)
        .toList();

    if (galleryItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gallery',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 116,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: galleryItems.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final imageUrl = galleryItems[index];
              return GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => _FullScreenGalleryImage(imageUrl: imageUrl),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: AspectRatio(
                    aspectRatio: 1.35,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFFE9EEF2),
                        child: const Icon(Icons.broken_image_outlined),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FullScreenGalleryImage extends StatelessWidget {
  const _FullScreenGalleryImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 4,
              child: Center(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white70,
                    size: 48,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 12,
            right: 16,
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _initialFor(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return 'G';
  }
  return trimmed.characters.first.toUpperCase();
}
