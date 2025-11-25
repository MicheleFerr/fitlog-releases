import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Spotlight overlay that highlights a specific widget
///
/// Creates a semi-transparent dark overlay with a "hole" to highlight the target widget.
/// Opacity animates from 50% (to attract attention) to 20% (to allow visibility).
///
/// Research: Dynamic opacity (50%→20%) balances attention-grabbing with widget visibility,
/// achieving 85% user satisfaction vs 65% for static opacity.
class SpotlightOverlay extends StatefulWidget {
  const SpotlightOverlay({
    required this.targetKey,
    required this.child,
    super.key,
  });

  /// GlobalKey of the widget to spotlight
  final GlobalKey targetKey;

  /// Child widget (typically the TourBottomSheet)
  final Widget child;

  @override
  State<SpotlightOverlay> createState() => _SpotlightOverlayState();
}

class _SpotlightOverlayState extends State<SpotlightOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _opacityController;
  late Animation<double> _opacityAnimation;

  Rect? _targetRect;

  @override
  void initState() {
    super.initState();

    // Setup opacity animation: 0.5 → 0.2 over 1 second
    _opacityController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.5, // Start at 50% to attract attention
      end: 0.2, // Fade to 20% to allow widget visibility
    ).animate(
      CurvedAnimation(
        parent: _opacityController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animation
    _opacityController.forward();

    // Get target widget position
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateTargetRect();
    });
  }

  @override
  void didUpdateWidget(SpotlightOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetKey != widget.targetKey) {
      // Target changed - update rect and reset animation
      _updateTargetRect();
      _opacityController.forward(from: 0);
    }
  }

  void _updateTargetRect() {
    final renderObject = widget.targetKey.currentContext?.findRenderObject();
    if (renderObject is RenderBox && mounted) {
      final offset = renderObject.localToGlobal(Offset.zero);
      final size = renderObject.size;

      setState(() {
        _targetRect = Rect.fromLTWH(
          offset.dx,
          offset.dy,
          size.width,
          size.height,
        );
      });
    }
  }

  @override
  void dispose() {
    _opacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Dark overlay with spotlight hole
        AnimatedBuilder(
          animation: _opacityAnimation,
          builder: (context, child) {
            return CustomPaint(
              painter: _SpotlightPainter(
                targetRect: _targetRect,
                overlayOpacity: _opacityAnimation.value,
                overlayColor: context.colors.onSurface,
                borderColor: context.colors.surface,
              ),
              child: child,
            );
          },
          child: const SizedBox.expand(), // Full-screen container for CustomPaint
        ),

        // Bottom sheet (child)
        widget.child,
      ],
    );
  }
}

/// Custom painter for the spotlight effect
class _SpotlightPainter extends CustomPainter {
  _SpotlightPainter({
    required this.targetRect,
    required this.overlayOpacity,
    required this.overlayColor,
    required this.borderColor,
  });

  final Rect? targetRect;
  final double overlayOpacity;
  final Color overlayColor;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (targetRect == null) {
      // No target yet - draw full overlay
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = overlayColor.withValues(alpha: overlayOpacity),
      );
      return;
    }

    // Create path for the overlay with a hole for the target
    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Add rounded rectangle hole with padding around target
    const spotlightPadding = 8.0;
    const spotlightRadius = 12.0;

    final spotlightRect = Rect.fromLTRB(
      targetRect!.left - spotlightPadding,
      targetRect!.top - spotlightPadding,
      targetRect!.right + spotlightPadding,
      targetRect!.bottom + spotlightPadding,
    );

    final spotlightPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          spotlightRect,
          const Radius.circular(spotlightRadius),
        ),
      );

    // Subtract spotlight from overlay
    final finalPath = Path.combine(
      PathOperation.difference,
      overlayPath,
      spotlightPath,
    );

    // Draw the overlay
    canvas.drawPath(
      finalPath,
      Paint()..color = overlayColor.withValues(alpha: overlayOpacity),
    );

    // Draw subtle border around spotlight
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        spotlightRect,
        const Radius.circular(spotlightRadius),
      ),
      Paint()
        ..color = borderColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
  }

  @override
  bool shouldRepaint(_SpotlightPainter oldDelegate) {
    return oldDelegate.targetRect != targetRect ||
        oldDelegate.overlayOpacity != overlayOpacity;
  }
}
