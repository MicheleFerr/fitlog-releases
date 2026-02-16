/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/analytics/presentation/widgets
/// Feature: analytics
/// Type: widget
///
/// Exercise Image Carousel - Alternates between 0.jpg and 1.jpg for exercises
///
/// For JPG exercises with pattern .../0.jpg, displays carousel alternating
/// between 0.jpg and 1.jpg every 2 seconds. For GIF exercises, displays static image.
library;

import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Image carousel for exercise compact cards.
///
/// **Behavior**:
/// - JPG with /0.jpg → carousel alternating 0.jpg and 1.jpg every 2s
/// - GIF or other → static image
/// - Disposes timer on widget disposal
class ExerciseImageCarousel extends StatefulWidget {
  const ExerciseImageCarousel({
    required this.imageUrl,
    required this.height,
    required this.width,
    required this.placeholder,
    required this.errorWidget,
    super.key,
  });

  final String imageUrl;
  final double height;
  final double width;
  final Widget placeholder;
  final Widget errorWidget;

  @override
  State<ExerciseImageCarousel> createState() => _ExerciseImageCarouselState();
}

class _ExerciseImageCarouselState extends State<ExerciseImageCarousel> {
  Timer? _timer;
  int _currentIndex = 0;
  List<String> _imageUrls = [];

  @override
  void initState() {
    super.initState();
    _setupCarousel();
  }

  @override
  void didUpdateWidget(ExerciseImageCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _timer?.cancel();
      _setupCarousel();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _setupCarousel() {
    final url = widget.imageUrl;

    // Check if JPG with /0.jpg pattern
    if (url.endsWith('/0.jpg')) {
      // Setup carousel with 0.jpg and 1.jpg
      final baseUrl = url.substring(0, url.length - 5); // Remove /0.jpg
      _imageUrls = [
        '$baseUrl/0.jpg',
        '$baseUrl/1.jpg',
      ];

      // Alternate every 2 seconds
      _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
        if (mounted) {
          setState(() {
            _currentIndex = (_currentIndex + 1) % _imageUrls.length;
          });
        }
      });
    } else {
      // Static image (GIF or non-carousel JPG)
      _imageUrls = [url];
      _currentIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_imageUrls.isEmpty) return widget.errorWidget;

    final currentUrl = _imageUrls[_currentIndex];

    return CachedNetworkImage(
      imageUrl: currentUrl,
      height: widget.height,
      width: widget.width,
      fit: BoxFit.cover,
      placeholder: (_, __) => widget.placeholder,
      errorWidget: (_, __, ___) => widget.errorWidget,
      // Key ensures smooth transition between images
      key: ValueKey(currentUrl),
      // Fade transition between images
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 300),
    );
  }
}
