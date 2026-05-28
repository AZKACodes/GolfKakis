import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class CourseDetailsMapSection extends StatelessWidget {
  const CourseDetailsMapSection({
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.onDirectionsTap,
    super.key,
  });

  final String address;
  final double? latitude;
  final double? longitude;
  final VoidCallback onDirectionsTap;

  @override
  Widget build(BuildContext context) {
    final hasCoordinates = latitude != null && longitude != null;

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
              child: hasCoordinates
                  ? _LiveMapPreview(
                      latitude: latitude!,
                      longitude: longitude!,
                      onTap: onDirectionsTap,
                    )
                  : _MapFallback(onTap: onDirectionsTap),
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
  const _MapFallback({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[Color(0xFFEAF6F0), Color(0xFFDDEBFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Icon(Icons.map_outlined, size: 40, color: Color(0xFF173B7A)),
        ),
      ),
    );
  }
}

class _LiveMapPreview extends StatelessWidget {
  const _LiveMapPreview({
    required this.latitude,
    required this.longitude,
    required this.onTap,
  });

  final double latitude;
  final double longitude;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final delta = 0.012;
    final bbox =
        '${longitude - delta},${latitude - delta},${longitude + delta},${latitude + delta}';
    final uri = Uri.https(
      'www.openstreetmap.org',
      '/export/embed.html',
      <String, String>{
        'bbox': bbox,
        'layer': 'mapnik',
        'marker': '$latitude,$longitude',
      },
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(uri.toString())),
          initialSettings: InAppWebViewSettings(
            transparentBackground: true,
            supportZoom: false,
            disableHorizontalScroll: true,
            disableVerticalScroll: true,
          ),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(onTap: onTap),
        ),
      ],
    );
  }
}
