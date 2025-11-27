import 'package:flutter/material.dart';

/// Custom painter that draws a semi-transparent scrim with a spotlight cutout.
///
/// Used by [UnifiedContextualOverlay] to highlight the target widget.
///
/// ## Performance:
/// - Uses PathFillType.evenOdd for optimal rendering
/// - shouldRepaint only triggers on actual changes
///
/// ## Example:
/// ```dart
/// CustomPaint(
///   painter: SpotlightPainter(
///     targetRect: Rect.fromLTWH(100, 200, 120, 48),
///     spotlightPadding: 8.0,
///   ),
/// )
/// ```
class SpotlightPainter extends CustomPainter {
  SpotlightPainter({
    required this.targetRect,
    this.spotlightPadding = 8.0,
    this.scrimColor = const Color(0x99000000),
    this.borderRadius = 8.0,
  });

  /// The rectangle of the target widget to highlight.
  final Rect targetRect;

  /// Padding around the target rect for the spotlight cutout.
  /// Default: 8.0
  final double spotlightPadding;

  /// Color of the scrim overlay.
  /// Default: 60% black (0x99000000)
  final Color scrimColor;

  /// Border radius for the spotlight cutout.
  /// Default: 8.0
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = scrimColor;

    // Use PathFillType.evenOdd for performance:
    // - Fills everything except the spotlight area
    // - Single draw call vs multiple rects
    final path = Path()
      ..fillType = PathFillType.evenOdd
      // Full screen rect
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      // Spotlight cutout (inflated by padding)
      ..addRRect(RRect.fromRectAndRadius(
        targetRect.inflate(spotlightPadding),
        Radius.circular(borderRadius),
      ));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(SpotlightPainter oldDelegate) {
    return targetRect != oldDelegate.targetRect ||
        spotlightPadding != oldDelegate.spotlightPadding ||
        scrimColor != oldDelegate.scrimColor ||
        borderRadius != oldDelegate.borderRadius;
  }
}

/// Animated spotlight painter with glow effect.
///
/// Extends SpotlightPainter with:
/// - Animated glow around spotlight
/// - Configurable glow color and radius
class AnimatedSpotlightPainter extends CustomPainter {
  AnimatedSpotlightPainter({
    required this.targetRect,
    required this.animation,
    this.spotlightPadding = 8.0,
    this.scrimColor = const Color(0x99000000),
    this.glowColor,
    this.borderRadius = 8.0,
    this.maxGlowRadius = 4.0,
  }) : super(repaint: animation);

  final Rect targetRect;
  final Animation<double> animation;
  final double spotlightPadding;
  final Color scrimColor;
  final Color? glowColor;
  final double borderRadius;
  final double maxGlowRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = scrimColor;

    // Draw scrim with spotlight cutout
    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(
        targetRect.inflate(spotlightPadding),
        Radius.circular(borderRadius),
      ));

    canvas.drawPath(path, paint);

    // Draw animated glow
    if (glowColor != null) {
      final glowPaint = Paint()
        ..color = glowColor!.withValues(alpha: 0.3 + (animation.value * 0.4))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 + (animation.value * maxGlowRadius);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          targetRect.inflate(spotlightPadding),
          Radius.circular(borderRadius),
        ),
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(AnimatedSpotlightPainter oldDelegate) {
    return targetRect != oldDelegate.targetRect ||
        spotlightPadding != oldDelegate.spotlightPadding ||
        scrimColor != oldDelegate.scrimColor ||
        glowColor != oldDelegate.glowColor;
  }
}
