import 'package:flutter/material.dart';

class CourseDetailsMapSection extends StatelessWidget {
  const CourseDetailsMapSection({
    required this.courseName,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.onDirectionsTap,
    super.key,
  });

  final String courseName;
  final String address;
  final double? latitude;
  final double? longitude;
  final VoidCallback onDirectionsTap;

  @override
  Widget build(BuildContext context) {
    final hasCoordinates = latitude != null && longitude != null;
    final staticMapUrl = hasCoordinates
        ? 'https://staticmap.openstreetmap.de/staticmap.php?center=$latitude,$longitude&zoom=14&size=1200x500&markers=$latitude,$longitude,red-pushpin'
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: staticMapUrl == null
                  ? _MapFallback(courseName: courseName, address: address)
                  : Image.network(
                      staticMapUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _MapFallback(
                          courseName: courseName,
                          address: address,
                        );
                      },
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined, color: Color(0xFF173B7A)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  address,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onDirectionsTap,
              icon: const Icon(Icons.near_me_outlined),
              label: const Text('Directions'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapFallback extends StatelessWidget {
  const _MapFallback({required this.courseName, required this.address});

  final String courseName;
  final String address;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFFEAF6F0), Color(0xFFDDEBFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.map_outlined, size: 28, color: Color(0xFF173B7A)),
            const Spacer(),
            Text(
              courseName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0A1F1A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              address,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
