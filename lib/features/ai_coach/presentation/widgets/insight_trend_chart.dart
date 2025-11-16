/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/presentation/widgets
/// 🎯 Feature: ai_coach
/// 🔧 Type: widget
///
/// Insight Trend Chart - visualizes insight metrics over time using fl_chart
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Chart widget for visualizing insight trends
///
/// Displays line chart with:
/// - Time series data (x-axis: dates, y-axis: metric value)
/// - Touch tooltips with values
/// - Grid lines for readability
/// - Theme-aware colors
///
/// Usage:
/// ```dart
/// InsightTrendChart(
///   title: 'Volume Progression',
///   dataPoints: [
///     ChartDataPoint(date: DateTime.now().subtract(Duration(days: 7)), value: 5000),
///     ChartDataPoint(date: DateTime.now().subtract(Duration(days: 3)), value: 5500),
///     ChartDataPoint(date: DateTime.now(), value: 6000),
///   ],
///   yAxisLabel: 'Volume (kg)',
/// )
/// ```
class InsightTrendChart extends StatelessWidget {
  const InsightTrendChart({
    required this.title,
    required this.dataPoints,
    this.yAxisLabel,
    this.lineColor,
    this.showGrid = true,
    this.height = 200,
    super.key,
  });

  /// Chart title
  final String title;

  /// Data points to plot
  final List<ChartDataPoint> dataPoints;

  /// Y-axis label (e.g., "Volume (kg)", "Sets per week")
  final String? yAxisLabel;

  /// Line color (defaults to primary)
  final Color? lineColor;

  /// Whether to show grid lines
  final bool showGrid;

  /// Chart height
  final double height;

  @override
  Widget build(BuildContext context) {
    if (dataPoints.isEmpty) {
      return _buildEmptyState(context);
    }

    // Sort data points by date
    final sortedData = List<ChartDataPoint>.from(dataPoints)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Convert to FlSpot (x = index, y = value)
    final spots = sortedData
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.value))
        .toList();

    // Find min/max for y-axis
    final values = sortedData.map((d) => d.value).toList();
    final minY = values.reduce((a, b) => a < b ? a : b);
    final maxY = values.reduce((a, b) => a > b ? a : b);
    final yRange = maxY - minY;

    // Add padding to y-axis (10% above/below)
    final yMin = (minY - yRange * 0.1).floorToDouble();
    final yMax = (maxY + yRange * 0.1).ceilToDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Y-axis label (optional)
        if (yAxisLabel != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              yAxisLabel!,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),

        // Chart
        SizedBox(
          height: height,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LineChart(
              LineChartData(
                minY: yMin,
                maxY: yMax,
                gridData: FlGridData(
                  show: showGrid,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: context.colors.outlineVariant.withValues(alpha: 0.3),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  // Left titles (Y-axis)
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          _formatNumber(value),
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        );
                      },
                    ),
                  ),
                  // Bottom titles (X-axis dates)
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= sortedData.length) {
                          return const SizedBox.shrink();
                        }

                        // Show date for first, last, and middle points
                        if (index == 0 ||
                            index == sortedData.length - 1 ||
                            index == sortedData.length ~/ 2) {
                          final date = sortedData[index].date;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _formatDate(date),
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.colors.onSurfaceVariant,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  // Hide right and top titles
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: lineColor ?? context.colors.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: lineColor ?? context.colors.primary,
                          strokeWidth: 2,
                          strokeColor: context.colors.surface,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: (lineColor ?? context.colors.primary)
                          .withValues(alpha: 0.1),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) =>
                        context.colors.surfaceContainerHighest,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final index = spot.x.toInt();
                        if (index < 0 || index >= sortedData.length) {
                          return null;
                        }

                        final dataPoint = sortedData[index];
                        return LineTooltipItem(
                          '${_formatDate(dataPoint.date)}\n${_formatNumber(spot.y)}',
                          context.textTheme.bodySmall!.copyWith(
                            color: context.colors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build empty state when no data
  Widget _buildEmptyState(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child: Text(
          context.l10n.noData,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  /// Format number for display (e.g., 5000 → 5K)
  String _formatNumber(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }

  /// Format date for display (e.g., Jan 15)
  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}

/// Data point for chart
class ChartDataPoint {
  const ChartDataPoint({
    required this.date,
    required this.value,
  });

  final DateTime date;
  final double value;
}
