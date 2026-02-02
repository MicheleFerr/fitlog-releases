/// RPE Gauge Widget - Syncfusion implementation
///
/// Semi-circular gauge for effort/RPE with color zones and mini sparkline.
/// Based on UX research: gauges are more intuitive for beginners to understand effort.
library;

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_progress_metrics.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/constants/app_icons.dart';

class RpeGaugeWidget extends StatelessWidget {
  const RpeGaugeWidget({
    super.key,
    required this.sets,
    this.height = 220,
    this.animate = true,
  });

  final List<ExerciseSetData> sets;
  final double height;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    // Filter sets with RPE data
    final setsWithRpe = sets.where((s) => s.rpe != null).toList();

    if (setsWithRpe.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                AppIcons.speed,
                size: 48,
                color: context.colors.onSurfaceVariant.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.noRpeDataAvailable,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Calculate average RPE
    final avgRpe = setsWithRpe.fold<double>(0, (sum, s) => sum + (s.rpe ?? 0)) /
        setsWithRpe.length;

    // Get effort label based on RPE
    final (effortLabel, effortColor) = _getEffortInfo(avgRpe, context);

    return SizedBox(
      height: height,
      child: Column(
        children: [
          // Main gauge
          Expanded(
            flex: 3,
            child: SfRadialGauge(
              enableLoadingAnimation: animate,
              animationDuration: 1500,
              axes: <RadialAxis>[
                RadialAxis(
                  minimum: 0,
                  maximum: 10,
                  startAngle: 180,
                  endAngle: 0,
                  showLabels: true,
                  showTicks: true,
                  showLastLabel: true,
                  labelOffset: 15,
                  axisLabelStyle: GaugeTextStyle(
                    color: context.colors.onSurfaceVariant,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  majorTickStyle: MajorTickStyle(
                    length: 8,
                    thickness: 2,
                    color: context.colors.outline.withValues(alpha: 0.3),
                  ),
                  minorTickStyle: MinorTickStyle(
                    length: 4,
                    thickness: 1,
                    color: context.colors.outline.withValues(alpha: 0.2),
                  ),
                  minorTicksPerInterval: 1,
                  axisLineStyle: AxisLineStyle(
                    thickness: 20,
                    cornerStyle: CornerStyle.bothCurve,
                    gradient: SweepGradient(
                      colors: [
                        context.colors.success, // 0-5: Easy
                        context.colors.success,
                        // 6-7: Moderate - blend between success and warning
                        Color.lerp(
                          context.colors.success,
                          context.colors.warning,
                          0.6,
                        )!,
                        context.colors.warning, // 8: Hard
                        context.colors.error, // 9-10: Maximum
                      ],
                      stops: const [0.0, 0.5, 0.7, 0.8, 1.0],
                    ),
                  ),
                  pointers: <GaugePointer>[
                    // Main needle pointer
                    NeedlePointer(
                      value: avgRpe,
                      needleLength: 0.6,
                      needleStartWidth: 1,
                      needleEndWidth: 4,
                      needleColor: context.colors.onSurface,
                      knobStyle: KnobStyle(
                        knobRadius: 0.08,
                        color: context.colors.onSurface,
                        borderColor: context.colors.surface,
                        borderWidth: 2,
                      ),
                      enableAnimation: animate,
                      animationDuration: 1500,
                      animationType: AnimationType.easeOutBack,
                    ),
                  ],
                  annotations: <GaugeAnnotation>[
                    // Center value
                    GaugeAnnotation(
                      widget: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            avgRpe.toStringAsFixed(1),
                            style: context.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: effortColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: effortColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              effortLabel,
                              style: context.textTheme.labelMedium?.copyWith(
                                color: effortColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      positionFactor: 0.5,
                      angle: 90,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Mini sparkline showing RPE trend
          if (setsWithRpe.length > 2)
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildMiniSparkline(context, setsWithRpe),
              ),
            ),
        ],
      ),
    );
  }

  /// Build mini sparkline showing recent RPE trend
  Widget _buildMiniSparkline(BuildContext context, List<ExerciseSetData> setsWithRpe) {
    // Take last 10 sessions max
    final recentSets = setsWithRpe.length > 10
        ? setsWithRpe.sublist(setsWithRpe.length - 10)
        : setsWithRpe;

    return Row(
      children: [
        Text(
          context.l10n.recentHistory,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SizedBox(
            height: 30,
            child: CustomPaint(
              painter: _SparklinePainter(
                data: recentSets.map((s) => (s.rpe ?? 0).toDouble()).toList(),
                color: context.colors.error,
                backgroundColor: context.colors.error.withValues(alpha: 0.1),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Get effort label and color based on RPE value
  /// TODO: Add proper l10n keys for gauge labels
  (String, Color) _getEffortInfo(double rpe, BuildContext context) {
    if (rpe <= 5) {
      // Easy / Recovery zone
      return ('Easy', context.colors.success);
    } else if (rpe <= 7) {
      // Moderate zone
      // Moderate: blend between success and warning for theme awareness
      return ('Moderate', Color.lerp(context.colors.success, context.colors.warning, 0.6)!);
    } else if (rpe <= 8) {
      // Challenging / Hard zone
      return ('Challenging', context.colors.warning);
    } else {
      // Maximum effort
      return ('Maximum', context.colors.error);
    }
  }
}

/// Custom painter for mini sparkline
class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.data,
    required this.color,
    required this.backgroundColor,
  });

  final List<double> data;
  final Color color;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final minValue = data.reduce((a, b) => a < b ? a : b);
    final range = maxValue - minValue;
    final normalizedData = range == 0
        ? data.map((_) => 0.5).toList()
        : data.map((v) => (v - minValue) / range).toList();

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();
    final stepX = size.width / (normalizedData.length - 1);
    const paddingY = 4.0;
    final availableHeight = size.height - paddingY * 2;

    for (int i = 0; i < normalizedData.length; i++) {
      final x = i * stepX;
      final y = paddingY + availableHeight * (1 - normalizedData[i]);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw dots at each point
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < normalizedData.length; i++) {
      final x = i * stepX;
      final y = paddingY + availableHeight * (1 - normalizedData[i]);
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.color != color;
  }
}
