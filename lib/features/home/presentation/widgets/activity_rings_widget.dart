/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/home/presentation/widgets
/// Feature: home
/// Type: widget
///
/// Activity Rings Widget - Apple-style activity rings display
///
/// Displays three concentric progress rings:
/// - Move (Red): Active calories burned
/// - Exercise (Green): Exercise minutes
/// - Stand (Blue): Stand hours
library;

import 'dart:async' show unawaited;
import 'dart:io' show Platform;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/features/health_sync/presentation/providers/activity_rings_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

/// Activity Rings widget showing Move/Exercise/Stand progress
class ActivityRingsWidget extends ConsumerStatefulWidget {
  const ActivityRingsWidget({
    super.key,
    this.size = 120,
    this.strokeWidth = 12,
    this.showLabels = true,
    this.onTap,
  });

  /// Size of the rings (diameter)
  final double size;

  /// Width of each ring stroke
  final double strokeWidth;

  /// Whether to show labels below rings
  final bool showLabels;

  /// Callback when widget is tapped
  final VoidCallback? onTap;

  @override
  ConsumerState<ActivityRingsWidget> createState() =>
      _ActivityRingsWidgetState();
}

class _ActivityRingsWidgetState extends ConsumerState<ActivityRingsWidget> {
  bool _timedOut = false;

  @override
  void initState() {
    super.initState();
    // Fetch data on mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activityRingsProvider.notifier).fetchActivityData();
    });

    // Timeout after 5 seconds to avoid infinite loader
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        final data = ref.read(activityRingsProvider);
        if (!data.hasData && !data.hasError) {
          setState(() => _timedOut = true);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(activityRingsProvider);

    return GestureDetector(
      onTap: widget.onTap ??
          () => ref.read(activityRingsProvider.notifier).fetchActivityData(),
      child: Card(
        elevation: 0,
        color: context.colors.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    AppIcons.favorite,
                    color: context.colors.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Activity',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (data.hasData)
                    Text(
                      'HealthKit',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Rings or loading/error state
              if (!data.hasData && !data.hasError && !_timedOut)
                SizedBox(
                  height: widget.size,
                  child: const Center(child: LoadingIndicator()),
                )
              else if (data.hasError || _timedOut)
                _buildErrorState(
                  context,
                  _timedOut ? 'No activity data' : (data.errorMessage ?? 'Error'),
                )
              else
                Row(
                  children: [
                    // Rings
                    SizedBox(
                      width: widget.size,
                      height: widget.size,
                      child: CustomPaint(
                        painter: _ActivityRingsPainter(
                          moveProgress: data.moveProgress,
                          exerciseProgress: data.exerciseProgress,
                          standProgress: data.standProgress,
                          strokeWidth: widget.strokeWidth,
                          moveColor: _moveColor,
                          exerciseColor: _exerciseColor,
                          standColor: _standColor,
                          backgroundColor:
                              context.colors.onSurface.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Stats
                    if (widget.showLabels)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStatRow(
                              context,
                              color: _moveColor,
                              label: 'Move',
                              value: '${data.moveCalories.toInt()}',
                              unit: 'kcal',
                              goal: data.moveGoal.toInt(),
                            ),
                            const SizedBox(height: 8),
                            _buildStatRow(
                              context,
                              color: _exerciseColor,
                              label: 'Exercise',
                              value: '${data.exerciseMinutes}',
                              unit: 'min',
                              goal: data.exerciseGoal,
                            ),
                            const SizedBox(height: 8),
                            _buildStatRow(
                              context,
                              color: _standColor,
                              label: 'Stand',
                              value: '${data.standHours}',
                              unit: 'hrs',
                              goal: data.standGoal,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context, {
    required Color color,
    required String label,
    required String value,
    required String unit,
    required int goal,
  }) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '/$goal $unit',
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    final isNoData = _timedOut || message.contains('No activity');

    return GestureDetector(
      onTap: () => _openFitnessApp(),
      child: SizedBox(
        height: widget.size,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isNoData ? AppIcons.fitnessCenter : AppIcons.errorOutline,
                color: isNoData ? context.colors.primary : context.colors.error,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                isNoData
                    ? context.l10n.openFitnessApp
                    : 'Connect Health',
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                isNoData
                    ? context.l10n.tapToSyncActivityData
                    : context.l10n.tapToRetry,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Open Apple Fitness app (iOS) or Google Fit (Android)
  Future<void> _openFitnessApp() async {
    if (Platform.isIOS) {
      // Try Apple Fitness first, fallback to Health
      final fitnessUri = Uri.parse('fb1562915830686498://'); // Fitness app
      final healthUri = Uri.parse('x-apple-health://'); // Health app

      if (await canLaunchUrl(fitnessUri)) {
        await launchUrl(fitnessUri);
      } else if (await canLaunchUrl(healthUri)) {
        await launchUrl(healthUri);
      }
    } else if (Platform.isAndroid) {
      // Google Fit
      final fitUri = Uri.parse('https://www.google.com/fit/');
      if (await canLaunchUrl(fitUri)) {
        await launchUrl(fitUri, mode: LaunchMode.externalApplication);
      }
    }

    // Retry fetch after a short delay
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      // Fire and forget - we don't need to wait for the fetch to complete
      unawaited(ref.read(activityRingsProvider.notifier).fetchActivityData());
      setState(() => _timedOut = false);
    }
  }

  // Apple-style colors
  static const Color _moveColor = Color(0xFFFA114F); // Red/Pink
  static const Color _exerciseColor = Color(0xFF92E82A); // Green/Lime
  static const Color _standColor = Color(0xFF1EEAEF); // Cyan/Blue
}

/// Custom painter for Activity Rings
class _ActivityRingsPainter extends CustomPainter {
  _ActivityRingsPainter({
    required this.moveProgress,
    required this.exerciseProgress,
    required this.standProgress,
    required this.strokeWidth,
    required this.moveColor,
    required this.exerciseColor,
    required this.standColor,
    required this.backgroundColor,
  });

  final double moveProgress;
  final double exerciseProgress;
  final double standProgress;
  final double strokeWidth;
  final Color moveColor;
  final Color exerciseColor;
  final Color standColor;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final gap = strokeWidth + 4; // Gap between rings

    // Outer ring (Move - red)
    final moveRadius = (size.width / 2) - (strokeWidth / 2);
    _drawRing(
      canvas,
      center,
      moveRadius,
      moveProgress,
      moveColor,
    );

    // Middle ring (Exercise - green)
    final exerciseRadius = moveRadius - gap;
    _drawRing(
      canvas,
      center,
      exerciseRadius,
      exerciseProgress,
      exerciseColor,
    );

    // Inner ring (Stand - blue)
    final standRadius = exerciseRadius - gap;
    _drawRing(
      canvas,
      center,
      standRadius,
      standProgress,
      standColor,
    );
  }

  void _drawRing(
    Canvas canvas,
    Offset center,
    double radius,
    double progress,
    Color color,
  ) {
    // Background ring
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress ring
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      // Start from top (-90 degrees) and go clockwise
      const startAngle = -math.pi / 2;
      // Clamp progress for drawing (can show overflow separately)
      final clampedProgress = progress.clamp(0.0, 1.0);
      final sweepAngle = 2 * math.pi * clampedProgress;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );

      // If progress exceeds 100%, draw overflow arc with slight offset
      if (progress > 1.0) {
        final overflowProgress = (progress - 1.0).clamp(0.0, 1.0);
        final overflowSweepAngle = 2 * math.pi * overflowProgress;

        final overflowPaint = Paint()
          ..color = color.withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth * 0.8
          ..strokeCap = StrokeCap.round;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          overflowSweepAngle,
          false,
          overflowPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_ActivityRingsPainter oldDelegate) {
    return moveProgress != oldDelegate.moveProgress ||
        exerciseProgress != oldDelegate.exerciseProgress ||
        standProgress != oldDelegate.standProgress;
  }
}
