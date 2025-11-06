import 'package:flutter/material.dart';

/// Custom painter for drawing animated spotlight effect with dynamic positioning
///
/// Creates a semi-transparent dark overlay with a "hole" highlighting the target widget.
/// The opacity animates to draw user attention while allowing visibility of the target.
///
/// Features:
///   - Animated opacity (configurable range)
///   - Rounded rectangle spotlight with optional border
///   - Path operations to create the "hole" effect
///   - Optimized shouldRepaint for performance
class DynamicSpotlightPainter extends CustomPainter {
  /// The bounds of the widget to spotlight
  final Rect? spotlightBounds;

  /// Current opacity of the overlay (0.0 to 1.0)
  final double opacity;

  /// Border radius of the spotlight hole
  final double borderRadius;

  /// Color of the overlay (default: 50% black)
  final Color overlayColor;

  /// Optional paint for drawing border around spotlight
  final Paint? borderPaint;

  /// Padding around the target widget
  final double padding;

  DynamicSpotlightPainter({
    required this.spotlightBounds,
    required this.opacity,
    this.borderRadius = 4.0,
    this.overlayColor = const Color.fromARGB(128, 0, 0, 0),
    this.borderPaint,
    this.padding = 8.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // If no spotlight bounds, draw full overlay
    if (spotlightBounds == null) {
      _drawFullOverlay(canvas, size);
      return;
    }

    // Draw overlay with spotlight hole
    _drawSpotlightOverlay(canvas, size);
  }

  /// Draws a full-screen overlay (when no spotlight target)
  void _drawFullOverlay(Canvas canvas, Size size) {
    // Apply opacity to overlay color
    final argb32 = overlayColor.toARGB32();
    final colorAlpha = ((argb32 >> 24) & 0xFF) / 255.0;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = overlayColor.withValues(alpha: colorAlpha * opacity),
    );
  }

  /// Draws the spotlight overlay with hole for target widget
  void _drawSpotlightOverlay(Canvas canvas, Size size) {
    // Create the full screen rect
    final fullScreenPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Create spotlight rect with padding
    final spotlightRect = Rect.fromLTRB(
      spotlightBounds!.left - padding,
      spotlightBounds!.top - padding,
      spotlightBounds!.right + padding,
      spotlightBounds!.bottom + padding,
    );

    // Create spotlight path with rounded corners
    final spotlightPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          spotlightRect,
          Radius.circular(borderRadius),
        ),
      );

    // Combine paths: full screen minus spotlight = overlay with hole
    final overlayPath = Path.combine(
      PathOperation.difference,
      fullScreenPath,
      spotlightPath,
    );

    // Draw the overlay
    final argb32 = overlayColor.toARGB32();
    final colorAlpha = ((argb32 >> 24) & 0xFF) / 255.0;
    canvas.drawPath(
      overlayPath,
      Paint()
        ..color = overlayColor.withValues(
          alpha: colorAlpha * opacity,
        ),
    );

    // Draw optional border around spotlight
    if (borderPaint != null) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          spotlightRect,
          Radius.circular(borderRadius),
        ),
        borderPaint!,
      );
    }
  }

  @override
  bool shouldRepaint(DynamicSpotlightPainter oldDelegate) {
    return oldDelegate.spotlightBounds != spotlightBounds ||
        oldDelegate.opacity != opacity ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.overlayColor != overlayColor ||
        oldDelegate.padding != padding;
  }

  @override
  bool shouldRebuildSemantics(DynamicSpotlightPainter oldDelegate) {
    return oldDelegate.spotlightBounds != spotlightBounds;
  }
}
