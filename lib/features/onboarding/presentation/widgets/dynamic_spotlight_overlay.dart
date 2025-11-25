import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/widgets/dynamic_spotlight_painter.dart';

/// Overlay widget with animated spotlight effect
///
/// Displays a full-screen overlay with animated opacity and a spotlight "hole"
/// highlighting a target widget. Supports both internal and external animation control.
///
/// Features:
///   - Configurable opacity animation range
///   - Auto-animates when spotlight bounds change
///   - Can use external AnimationController for synchronization
///   - Optimized rendering with CustomPaint
///   - Handles null bounds gracefully
///
/// The animation:
///   - Animates from [maxOpacity] to [minOpacity] over 800ms
///   - Uses easeInOut curve for smooth transitions
///   - Restarts when bounds change (forward(from: 0))
class DynamicSpotlightOverlay extends StatefulWidget {

  const DynamicSpotlightOverlay({
    required this.spotlightBounds,
    required this.child,
    this.offset,
    this.animationController,
    this.minOpacity = 0.2,
    this.maxOpacity = 0.5,
    this.animationDuration = const Duration(milliseconds: 800),
    this.spotlightBorderRadius = 4.0,
    this.spotlightPadding = 8.0,
    this.overlayColor = const Color.fromARGB(128, 0, 0, 0),
    this.spotlightBorderPaint,
    super.key,
  }) : assert(minOpacity >= 0 && minOpacity <= 1),
       assert(maxOpacity >= 0 && maxOpacity <= 1),
       assert(minOpacity <= maxOpacity);
  /// Global bounds of the widget to spotlight
  final Rect? spotlightBounds;

  /// Calculated offset for positioning (optional, for future use)
  final Offset? offset;

  /// Child widget (usually TourBottomSheet)
  final Widget child;

  /// Optional external animation controller
  /// If provided, will not create internal controller
  final AnimationController? animationController;

  /// Minimum opacity (destination of animation)
  final double minOpacity;

  /// Maximum opacity (start of animation)
  final double maxOpacity;

  /// Duration of opacity animation
  final Duration animationDuration;

  /// Border radius for spotlight hole
  final double spotlightBorderRadius;

  /// Padding around spotlight
  final double spotlightPadding;

  /// Color of the overlay
  final Color overlayColor;

  /// Optional border paint around spotlight
  final Paint? spotlightBorderPaint;

  @override
  State<DynamicSpotlightOverlay> createState() => _DynamicSpotlightOverlayState();
}

class _DynamicSpotlightOverlayState extends State<DynamicSpotlightOverlay>
    with TickerProviderStateMixin {
  /// Internal animation controller (if not provided externally)
  late AnimationController _internalController;

  /// The animation controller we'll actually use
  late AnimationController _controller;

  /// Opacity animation
  late Animation<double> _opacityAnimation;

  /// Bounds transition controller for smooth position changes
  late AnimationController _boundsController;

  /// Animation for smooth bounds transition
  Animation<Rect?>? _boundsAnimation;

  /// Previous bounds for smooth transition
  Rect? _previousBounds;

  @override
  void initState() {
    super.initState();

    // Use provided controller or create internal one
    if (widget.animationController != null) {
      _controller = widget.animationController!;
    } else {
      _internalController = AnimationController(
        vsync: this,
        duration: widget.animationDuration,
      );
      _controller = _internalController;
    }

    // Create bounds transition controller (fast, 300ms)
    _boundsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Initialize previous bounds
    _previousBounds = widget.spotlightBounds;

    // Setup opacity animation
    _setupOpacityAnimation();

    // Start continuous pulsing animation for smooth professional effect
    _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(DynamicSpotlightOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If spotlight bounds changed, animate the transition smoothly
    if (oldWidget.spotlightBounds != widget.spotlightBounds) {
      debugPrint(
        '🎯 [DynamicSpotlightOverlay] Animating spotlight transition from '
        '${_previousBounds ?? oldWidget.spotlightBounds} to ${widget.spotlightBounds}',
      );

      // Create smooth transition animation from old to new bounds
      _boundsAnimation = RectTween(
        begin: _previousBounds ?? oldWidget.spotlightBounds,
        end: widget.spotlightBounds,
      ).animate(CurvedAnimation(
        parent: _boundsController,
        curve: Curves.easeInOut,
      ));

      // Start transition animation
      _boundsController.forward(from: 0).then((_) {
        // Update previous bounds after transition completes
        _previousBounds = widget.spotlightBounds;
      });
    }

    // If animation duration changed, update controller
    if (oldWidget.animationDuration != widget.animationDuration) {
      if (widget.animationController == null) {
        _internalController.duration = widget.animationDuration;
      }
      _setupOpacityAnimation();
    }

    // If opacity range changed, update animation smoothly
    if (oldWidget.minOpacity != widget.minOpacity ||
        oldWidget.maxOpacity != widget.maxOpacity) {
      _setupOpacityAnimation();
      // Don't restart - let animation continue smoothly with new range
    }
  }

  /// Sets up the opacity animation with current settings
  void _setupOpacityAnimation() {
    _opacityAnimation = Tween<double>(
      begin: widget.maxOpacity, // Start at max (brightest overlay)
      end: widget.minOpacity, // End at min (dimmer overlay)
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    // Dispose bounds controller
    _boundsController.dispose();

    // Only dispose internal controller
    if (widget.animationController == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Spotlight overlay with animated opacity AND bounds
        AnimatedBuilder(
          animation: Listenable.merge([_opacityAnimation, _boundsController]),
          builder: (context, child) {
            // Use animated bounds if transition is active, otherwise use target bounds
            final currentBounds = _boundsAnimation?.value ?? widget.spotlightBounds;

            return CustomPaint(
              painter: DynamicSpotlightPainter(
                spotlightBounds: currentBounds,
                opacity: _opacityAnimation.value,
                borderRadius: widget.spotlightBorderRadius,
                overlayColor: widget.overlayColor,
                borderPaint: widget.spotlightBorderPaint,
                padding: widget.spotlightPadding,
              ),
              child: const SizedBox.expand(),
            );
          },
        ),

        // Child widget (usually TourBottomSheet) overlaid on top
        widget.child,
      ],
    );
  }
}
