/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/profile/presentation/widgets
/// Feature: Profile Hub - Metric Ring Cards
/// Type: Widget
///
/// Apple Fitness+ style ring cards showing progress metrics
/// with animated fill and glow effects on completion.
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Configuration for a metric ring
class MetricRingConfig {
  const MetricRingConfig({
    required this.title,
    required this.value,
    required this.percentage,
    required this.color,
    this.onTap,
  });

  /// Title displayed below the ring
  final String title;

  /// Value displayed inside the ring (e.g., "4/5", "75%")
  final String value;

  /// Progress percentage (0.0 to 1.0)
  final double percentage;

  /// Ring color
  final Color color;

  /// Callback when card is tapped
  final VoidCallback? onTap;
}

/// Apple Fitness+ style metric ring card
///
/// Displays a circular progress ring with animated fill,
/// glow effect on completion, and tap interaction.
class MetricRingCard extends StatefulWidget {
  const MetricRingCard({required this.config, super.key});

  final MetricRingConfig config;

  /// Ring diameter
  static const double ringSize = 80.0;

  /// Ring stroke width
  static const double strokeWidth = 8.0;

  /// Card height
  static const double cardHeight = 120.0;

  /// Animation duration
  static const Duration animationDuration = Duration(milliseconds: 800);

  @override
  State<MetricRingCard> createState() => _MetricRingCardState();
}

class _MetricRingCardState extends State<MetricRingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: MetricRingCard.animationDuration,
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.config.percentage,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Start animation after a slight delay for stagger effect
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void didUpdateWidget(MetricRingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config.percentage != widget.config.percentage) {
      _progressAnimation =
          Tween<double>(
            begin: _progressAnimation.value,
            end: widget.config.percentage,
          ).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
          );
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isComplete = widget.config.percentage >= 1.0;

    return GestureDetector(
      onTap: () {
        if (widget.config.onTap != null) {
          HapticFeedback.lightImpact();
          widget.config.onTap!();
        }
      },
      child: AnimatedBuilder(
        animation: _progressAnimation,
        builder: (context, child) {
          final currentProgress = _progressAnimation.value;
          final showGlow = currentProgress >= 1.0;

          return Container(
            height: MetricRingCard.cardHeight,
            decoration: BoxDecoration(
              // ✨ Material 3 2025: Elevated surface with defined border
              color: context.colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: showGlow
                    ? widget.config.color.withValues(alpha: 0.4)
                    : context.colors.outlineVariant.withValues(alpha: 0.5),
                width: showGlow ? 1.5 : 1,
              ),
              boxShadow: showGlow
                  ? [
                      // Enhanced glow when complete
                      BoxShadow(
                        color: widget.config.color.withValues(alpha: 0.25),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: widget.config.color.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [
                      // Subtle shadow when not complete
                      BoxShadow(
                        color: context.colors.shadow.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ring with progress
                SizedBox(
                  width: MetricRingCard.ringSize,
                  height: MetricRingCard.ringSize,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background ring
                      CustomPaint(
                        size: const Size(
                          MetricRingCard.ringSize,
                          MetricRingCard.ringSize,
                        ),
                        painter: _RingPainter(
                          progress: 1.0,
                          color: context.colors.surfaceContainerLow,
                          strokeWidth: MetricRingCard.strokeWidth,
                        ),
                      ),
                      // Progress ring
                      CustomPaint(
                        size: const Size(
                          MetricRingCard.ringSize,
                          MetricRingCard.ringSize,
                        ),
                        painter: _RingPainter(
                          progress: currentProgress,
                          color: widget.config.color,
                          strokeWidth: MetricRingCard.strokeWidth,
                          isGlowing: showGlow,
                        ),
                      ),
                      // Value text
                      Text(
                        widget.config.value,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isComplete
                              ? widget.config.color
                              : context.colors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Title
                Text(
                  widget.config.title,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Custom painter for circular progress ring
class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
    this.isGlowing = false,
  });

  final double progress;
  final Color color;
  final double strokeWidth;
  final bool isGlowing;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (isGlowing) {
      // Add glow effect
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    }

    // Draw arc from top (-90 degrees) going clockwise
    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.isGlowing != isGlowing;
  }
}

/// Row of three metric ring cards
///
/// Standard layout for Profile Hub metrics display
class MetricRingsRow extends StatelessWidget {
  const MetricRingsRow({required this.rings, super.key});

  /// List of ring configurations (typically 3)
  final List<MetricRingConfig> rings;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          for (int i = 0; i < rings.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            Expanded(child: MetricRingCard(config: rings[i])),
          ],
        ],
      ),
    );
  }
}
