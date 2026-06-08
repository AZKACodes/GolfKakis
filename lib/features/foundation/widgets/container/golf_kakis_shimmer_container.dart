import 'package:flutter/material.dart';

class GolfKakisShimmerContainer extends StatefulWidget {
  const GolfKakisShimmerContainer({
    required this.height,
    this.width,
    this.borderRadius = 16,
    super.key,
  });

  final double height;
  final double? width;
  final double borderRadius;

  @override
  State<GolfKakisShimmerContainer> createState() =>
      _GolfKakisShimmerContainerState();
}

class _GolfKakisShimmerContainerState extends State<GolfKakisShimmerContainer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? const Color(0xFF232B2F)
        : const Color(0xFFE9EEF0);
    final highlightColor = isDark
        ? const Color(0xFF323C42)
        : const Color(0xFFF8FAFA);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final shimmerPosition = (_controller.value * 2.4) - 1.2;

        return ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: Container(
            width: widget.width ?? double.infinity,
            height: widget.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(shimmerPosition - 1, 0),
                end: Alignment(shimmerPosition + 1, 0),
                colors: <Color>[baseColor, highlightColor, baseColor],
                stops: const <double>[0.25, 0.5, 0.75],
              ),
            ),
          ),
        );
      },
    );
  }
}
