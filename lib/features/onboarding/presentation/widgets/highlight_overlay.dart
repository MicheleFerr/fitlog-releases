import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';

class HighlightOverlay extends StatefulWidget {

  const HighlightOverlay({
    super.key,
    required this.child,
    this.targetKey,
    this.title,
    this.description,
    this.onTap,
    this.onNext,
    this.onSkip,
    this.showOverlay = false,
    this.shape = HighlightShape.rectangle,
    this.padding = const EdgeInsets.all(8.0),
    this.overlayColor = const Color(0xAA000000),
    this.animationDuration = const Duration(milliseconds: 300),
  });
  final Widget child;
  final GlobalKey? targetKey;
  final String? title;
  final String? description;
  final VoidCallback? onTap;
  final VoidCallback? onNext;
  final VoidCallback? onSkip;
  final bool showOverlay;
  final HighlightShape shape;
  final EdgeInsets padding;
  final Color overlayColor;
  final Duration animationDuration;

  @override
  State<HighlightOverlay> createState() => _HighlightOverlayState();
}

class _HighlightOverlayState extends State<HighlightOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.showOverlay) {
      _animationController.forward();
      _startPulseAnimation();
    }
  }

  void _startPulseAnimation() {
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && widget.showOverlay) {
        _animationController.reverse().then((_) {
          if (mounted && widget.showOverlay) {
            _animationController.forward();
          }
        });
      }
    });
  }

  @override
  void didUpdateWidget(HighlightOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showOverlay != oldWidget.showOverlay) {
      if (widget.showOverlay) {
        _animationController.forward();
        _startPulseAnimation();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.showOverlay)
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: _buildOverlay(context),
              );
            },
          ),
      ],
    );
  }

  Widget _buildOverlay(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    // Get target position if key is provided
    Rect? targetRect;
    if (widget.targetKey?.currentContext != null) {
      final RenderBox renderBox = widget.targetKey!.currentContext!
          .findRenderObject() as RenderBox;
      final position = renderBox.localToGlobal(Offset.zero);
      targetRect = Rect.fromLTWH(
        position.dx - widget.padding.left,
        position.dy - widget.padding.top,
        renderBox.size.width + widget.padding.horizontal,
        renderBox.size.height + widget.padding.vertical,
      );
    }

    return Stack(
      children: [
        // Semi-transparent overlay
        GestureDetector(
          onTap: widget.onTap,
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: targetRect != null
                ? CustomPaint(
                    painter: HighlightPainter(
                      targetRect: targetRect,
                      overlayColor: widget.overlayColor,
                      shape: widget.shape,
                      pulseAnimation: _pulseAnimation,
                    ),
                  )
                : Container(color: widget.overlayColor),
          ),
        ),

        // Tooltip if target exists
        if (targetRect != null && (widget.title != null || widget.description != null))
          _buildTooltip(context, targetRect, theme),

        // Skip button
        if (widget.onSkip != null)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: TextButton(
                onPressed: widget.onSkip,
                style: TextButton.styleFrom(
                  foregroundColor: context.colors.surface,
                  backgroundColor: context.colors.onSurface.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Skip'),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTooltip(BuildContext context, Rect targetRect, ThemeData theme) {
    final size = MediaQuery.of(context).size;
    final isTopHalf = targetRect.center.dy < size.height / 2;

    return Positioned(
      left: 16,
      right: 16,
      top: isTopHalf
          ? targetRect.bottom + 16
          : null,
      bottom: !isTopHalf
          ? size.height - targetRect.top + 16
          : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: context.colors.onSurface.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.title != null) ...[
                Text(
                  widget.title!,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              if (widget.description != null) ...[
                Text(
                  widget.description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (widget.onNext != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: widget.onNext,
                    child: const Text('Next'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

enum HighlightShape {
  rectangle,
  circle,
  roundedRectangle,
}

class HighlightPainter extends CustomPainter {

  HighlightPainter({
    required this.targetRect,
    required this.overlayColor,
    required this.shape,
    required this.pulseAnimation,
  }) : super(repaint: pulseAnimation);
  final Rect targetRect;
  final Color overlayColor;
  final HighlightShape shape;
  final Animation<double> pulseAnimation;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final highlightPaint = Paint()
      ..color = context.colors.surface
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 * pulseAnimation.value;

    // Create path for the entire screen
    final screenPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Create path for the highlighted area
    final highlightPath = Path();

    switch (shape) {
      case HighlightShape.rectangle:
        highlightPath.addRect(targetRect);
        break;
      case HighlightShape.circle:
        final center = targetRect.center;
        final radius = math.max(targetRect.width, targetRect.height) / 2;
        highlightPath.addOval(Rect.fromCircle(center: center, radius: radius));
        break;
      case HighlightShape.roundedRectangle:
        highlightPath.addRRect(RRect.fromRectAndRadius(
          targetRect,
          const Radius.circular(8),
        ));
        break;
    }

    // Subtract highlight path from screen path
    final overlayPath = Path.combine(
      PathOperation.difference,
      screenPath,
      highlightPath,
    );

    // Draw overlay
    canvas.drawPath(overlayPath, paint);

    // Draw highlight border with pulse effect
    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(HighlightPainter oldDelegate) {
    return oldDelegate.targetRect != targetRect ||
        oldDelegate.overlayColor != overlayColor ||
        oldDelegate.shape != shape;
  }
}

// Helper widget to make any widget highlightable
class HighlightableWidget extends StatefulWidget {

  const HighlightableWidget({
    super.key,
    required this.child,
    required this.highlightKey,
    this.title,
    this.description,
    this.onHighlighted,
  });
  final Widget child;
  final GlobalKey highlightKey;
  final String? title;
  final String? description;
  final VoidCallback? onHighlighted;

  @override
  State<HighlightableWidget> createState() => _HighlightableWidgetState();
}

class _HighlightableWidgetState extends State<HighlightableWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      key: widget.highlightKey,
      child: widget.child,
    );
  }
}