/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/analytics/presentation/widgets
/// Feature: analytics
/// Type: widget
///
///
/// Mini Sparkline - Compact line chart for exercise progression
///
/// **Purpose**: Show weight progression trend in exercise list
/// **Features**:
/// - Compact 60x24px line chart
/// - Color based on trend (green/orange/gray)
/// - Smooth curve with gradient fill
/// - Normalized data (0-1 range)
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'dart:math' as math;

/// Mini sparkline widget showing exercise progression
class MiniSparkline extends StatelessWidget {
  const MiniSparkline({
    super.key,
    required this.dataPoints,
    required this.isPositiveTrend,
    this.width = 60,
    this.height = 24,
  });

  /// Data points to plot (should be 8-12 recent sessions)
  final List<double> dataPoints;

  /// Whether trend is positive (green) or negative (orange)
  final bool isPositiveTrend;

  /// Chart width
  final double width;

  /// Chart height
  final double height;

  @override
  Widget build(BuildContext context) {
    // Handle empty or insufficient data
    if (dataPoints.isEmpty || dataPoints.length < 2) {
      return SizedBox(
        width: width,
        height: height,
        child: Center(
          child: Icon(
            AppIcons.remove,
            size: 16,
            color: context.colors.onSurfaceVariant.withValues(alpha: 0.3),
          ),
        ),
      );
    }

    return CustomPaint(
      size: Size(width, height),
      painter: _SparklinePainter(
        dataPoints: dataPoints,
        isPositiveTrend: isPositiveTrend,
        lineColor: isPositiveTrend
            ? context.colors.success
            : context.colors.warning,
        backgroundColor: context.colors.surface,
      ),
    );
  }
}

/// Custom painter for sparkline
class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.dataPoints,
    required this.isPositiveTrend,
    required this.lineColor,
    required this.backgroundColor,
  });

  final List<double> dataPoints;
  final bool isPositiveTrend;
  final Color lineColor;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty || dataPoints.length < 2) return;

    // Normalize data points to 0-1 range
    final normalizedPoints = _normalizeData(dataPoints);

    // Create line path
    final path = Path();
    final fillPath = Path();

    // Calculate spacing between points
    final spacing = size.width / (normalizedPoints.length - 1);

    // Start at first point
    const firstX = 0.0;
    final firstY = size.height - (normalizedPoints[0] * size.height);
    path.moveTo(firstX, firstY);
    fillPath.moveTo(firstX, size.height);
    fillPath.lineTo(firstX, firstY);

    // Draw smooth curve through points
    for (int i = 1; i < normalizedPoints.length; i++) {
      final x = i * spacing;
      final y = size.height - (normalizedPoints[i] * size.height);

      // Use quadratic bezier for smooth curve
      final prevX = (i - 1) * spacing;
      final prevY = size.height - (normalizedPoints[i - 1] * size.height);
      final controlX = (prevX + x) / 2;
      final controlY = (prevY + y) / 2;

      path.quadraticBezierTo(controlX, controlY, x, y);
      fillPath.quadraticBezierTo(controlX, controlY, x, y);
    }

    // Complete fill path
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Draw gradient fill
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        lineColor.withValues(alpha: 0.2),
        lineColor.withValues(alpha: 0.05),
      ],
    );

    final fillPaint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);
  }

  /// Normalize data points to 0-1 range
  List<double> _normalizeData(List<double> data) {
    if (data.isEmpty) return [];

    final minValue = data.reduce(math.min);
    final maxValue = data.reduce(math.max);
    final range = maxValue - minValue;

    // Handle flat data (all same value)
    if (range == 0) {
      return List.filled(data.length, 0.5); // Middle line
    }

    return data.map((value) => (value - minValue) / range).toList();
  }

  @override
  bool shouldRepaint(_SparklinePainter oldDelegate) {
    return oldDelegate.dataPoints != dataPoints ||
        oldDelegate.isPositiveTrend != isPositiveTrend;
  }
}
