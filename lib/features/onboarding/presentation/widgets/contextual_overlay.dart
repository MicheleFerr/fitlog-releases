import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Contextual overlay widget that highlights a target widget with spotlight effect
///
/// Uses LayerLink + CompositedTransformFollower for precise positioning
/// Includes spotlight (dimmed background with cutout), tooltip card, and optional CTA
///
/// **Design**: Non-intrusive, visually guides attention, action-oriented
class ContextualOverlay extends StatefulWidget {
  const ContextualOverlay({
    super.key,
    required this.targetKey,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
    this.spotlightPadding = 8.0,
  });

  final GlobalKey targetKey;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onDismiss;
  final double spotlightPadding;

  @override
  State<ContextualOverlay> createState() => _ContextualOverlayState();
}

class _ContextualOverlayState extends State<ContextualOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  Rect? _targetRect;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    // Get target widget rect
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateTargetRect();
      _controller.forward();
    });
  }

  void _calculateTargetRect() {
    final RenderBox? targetBox =
        widget.targetKey.currentContext?.findRenderObject() as RenderBox?;

    if (targetBox != null && mounted) {
      final targetSize = targetBox.size;
      final targetPosition = targetBox.localToGlobal(Offset.zero);

      setState(() {
        _targetRect = Rect.fromLTWH(
          targetPosition.dx - widget.spotlightPadding,
          targetPosition.dy - widget.spotlightPadding,
          targetSize.width + (widget.spotlightPadding * 2),
          targetSize.height + (widget.spotlightPadding * 2),
        );
      });
    } else {
      // Fallback: if target not found, use centered rect for message-only display
      debugPrint('⚠️ [ContextualOverlay] Target not found, using fallback');
      if (mounted) {
        final size = MediaQuery.of(context).size;
        setState(() {
          // Create a small rect at center to show message without spotlight
          _targetRect = Rect.fromCenter(
            center: Offset(size.width / 2, size.height / 2),
            width: 1,
            height: 1,
          );
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_targetRect == null) {
      return const SizedBox.shrink(); // Wait for rect calculation
    }

    final colors = context.colors;
    final screenSize = MediaQuery.of(context).size;

    // Determine tooltip position (above or below target)
    final showAbove = _targetRect!.bottom > screenSize.height * 0.6;
    final tooltipTop = showAbove
        ? _targetRect!.top - 120 // Above target
        : _targetRect!.bottom + 20; // Below target

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Stack(
        children: [
          // Dimmed background with spotlight cutout
          GestureDetector(
            onTap: widget.onDismiss,
            child: Container(
              width: screenSize.width,
              height: screenSize.height,
              color: context.colors.surface.withValues(alpha: 0),
              child: CustomPaint(
                painter: _SpotlightPainter(
                  spotlightRect: _targetRect!,
                  backgroundColor: context.colors.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ),
          ),

          // Pulsing ring around target
          Positioned(
            left: _targetRect!.left,
            top: _targetRect!.top,
            width: _targetRect!.width,
            height: _targetRect!.height,
            child: _PulsingRing(
              color: colors.primary,
            ),
          ),

          // Tooltip card
          Positioned(
            left: 24,
            right: 24,
            top: tooltipTop,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: _TooltipCard(
                message: widget.message,
                actionLabel: widget.actionLabel,
                onAction: widget.onAction,
                onDismiss: widget.onDismiss,
                showArrowAbove: !showAbove,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for dimmed background with spotlight cutout
class _SpotlightPainter extends CustomPainter {
  const _SpotlightPainter({
    required this.spotlightRect,
    required this.backgroundColor,
  });

  final Rect spotlightRect;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = backgroundColor;

    // Draw full background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Cut out spotlight area
    final spotlightPaint = Paint()..blendMode = BlendMode.clear;
    canvas.drawRRect(
      RRect.fromRectAndRadius(spotlightRect, const Radius.circular(12)),
      spotlightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) {
    return oldDelegate.spotlightRect != spotlightRect ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}

/// Pulsing ring animation around target widget
class _PulsingRing extends StatefulWidget {
  const _PulsingRing({
    required this.color,
  });

  final Color color;

  @override
  State<_PulsingRing> createState() => _PulsingRingState();
}

class _PulsingRingState extends State<_PulsingRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: widget.color.withValues(alpha: 0.3 + (_controller.value * 0.4)),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }
}

/// Tooltip card with message and optional action button
class _TooltipCard extends StatelessWidget {
  const _TooltipCard({
    required this.message,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
    required this.showArrowAbove,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onDismiss;
  final bool showArrowAbove;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Arrow pointing to target (above tooltip)
        if (showArrowAbove)
          CustomPaint(
            size: const Size(20, 10),
            painter: _ArrowPainter(
              color: colors.surfaceContainerHighest,
              pointUp: true,
            ),
          ),

        // Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: context.colors.onSurface.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Message
              Text(
                message,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: colors.onSurface,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),

              if (actionLabel != null || onDismiss != null)
                const SizedBox(height: 16),

              // Action buttons
              if (actionLabel != null || onDismiss != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onDismiss != null)
                      TextButton(
                        onPressed: onDismiss,
                        child: Text(
                          'Skip',
                          style: context.textTheme.labelLarge?.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    if (onDismiss != null && actionLabel != null)
                      const SizedBox(width: 8),
                    if (actionLabel != null)
                      ElevatedButton(
                        onPressed: onAction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: colors.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(actionLabel!),
                      ),
                  ],
                ),
            ],
          ),
        ),

        // Arrow pointing to target (below tooltip)
        if (!showArrowAbove)
          CustomPaint(
            size: const Size(20, 10),
            painter: _ArrowPainter(
              color: colors.surfaceContainerHighest,
              pointUp: false,
            ),
          ),
      ],
    );
  }
}

/// Painter for arrow pointing to target
class _ArrowPainter extends CustomPainter {
  const _ArrowPainter({
    required this.color,
    required this.pointUp,
  });

  final Color color;
  final bool pointUp;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    if (pointUp) {
      // Arrow pointing up
      path.moveTo(size.width / 2, 0); // Top center (tip)
      path.lineTo(0, size.height); // Bottom left
      path.lineTo(size.width, size.height); // Bottom right
    } else {
      // Arrow pointing down
      path.moveTo(0, 0); // Top left
      path.lineTo(size.width, 0); // Top right
      path.lineTo(size.width / 2, size.height); // Bottom center (tip)
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.pointUp != pointUp;
  }
}
