/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/presentation/widgets
/// 🎯 Feature: ai_coach
/// 🔧 Type: widget
///
/// Inline Chart - Lightweight chart widget for AI Coach responses
///
/// **Purpose**: Embed visual data in chat messages without leaving conversation
///
/// **Features**:
/// - Line chart for progression trends (PRs over time)
/// - Bar chart for volume comparison (weekly/monthly)
/// - Metric cards with trend indicators (↑ 12% from last week)
/// - Compact design (fits in message bubble)
///
/// **Chart Types**:
/// - `InlineChart.progression()`: Line chart for PR progression
/// - `InlineChart.volume()`: Bar chart for volume trends
/// - `InlineChart.metric()`: Single metric with trend
///
/// **Usage**:
/// ```dart
/// // In AI message metadata:
/// metadata: {
///   'chartType': 'progression',
///   'chartData': {
///     'exerciseName': 'Bench Press',
///     'data': [
///       {'date': '2025-01-01', 'value': 100},
///       {'date': '2025-01-08', 'value': 105},
///       {'date': '2025-01-15', 'value': 110},
///     ],
///   },
/// }
///
/// // In MessageBubble:
/// if (message.metadata?['chartType'] != null)
///   InlineChart.fromMetadata(message.metadata!)
/// ```
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_colors.dart';
import 'package:intl/intl.dart';

/// Inline chart widget for AI Coach responses
class InlineChart extends StatelessWidget {

  const InlineChart({
    super.key,
    required this.type,
    required this.data,
    this.title,
    this.unit,
  });

  /// Create chart from message metadata
  factory InlineChart.fromMetadata(Map<String, dynamic> metadata) {
    final chartType = metadata['chartType'] as String;
    final chartData = metadata['chartData'] as Map<String, dynamic>;

    // Parse data points
    final dataList = (chartData['data'] as List<dynamic>).map((item) {
      final dataMap = item as Map<String, dynamic>;
      return ChartDataPoint(
        date: DateTime.parse(dataMap['date'] as String),
        value: (dataMap['value'] as num).toDouble(),
        label: dataMap['label'] as String?,
      );
    }).toList();

    return InlineChart(
      type: InlineChartType.values.firstWhere(
        (t) => t.name == chartType,
        orElse: () => InlineChartType.line,
      ),
      title: chartData['title'] as String?,
      data: dataList,
      unit: chartData['unit'] as String?,
    );
  }

  /// Create progression line chart
  factory InlineChart.progression({
    required String exerciseName,
    required List<ChartDataPoint> data,
    String unit = 'kg',
  }) {
    return InlineChart(
      type: InlineChartType.line,
      title: exerciseName,
      data: data,
      unit: unit,
    );
  }

  /// Create volume bar chart
  factory InlineChart.volume({
    required List<ChartDataPoint> data,
    String unit = 'kg',
  }) {
    return InlineChart(
      type: InlineChartType.bar,
      title: 'Weekly Volume',
      data: data,
      unit: unit,
    );
  }
  final InlineChartType type;
  final String? title;
  final List<ChartDataPoint> data;
  final String? unit;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          if (title != null) ...[
            Text(
              title!,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Chart
          SizedBox(
            height: 180,
            child: type == InlineChartType.line
                ? _buildLineChart(context)
                : _buildBarChart(context),
          ),

          // Legend with trend
          const SizedBox(height: 8),
          _buildLegend(context),
        ],
      ),
    );
  }

  /// Build line chart for progression
  Widget _buildLineChart(BuildContext context) {
    final sortedData = List<ChartDataPoint>.from(data)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Calculate min/max for Y axis
    final values = sortedData.map((d) => d.value).toList();
    final minY = (values.reduce((a, b) => a < b ? a : b) * 0.9).floorToDouble();
    final maxY = (values.reduce((a, b) => a > b ? a : b) * 1.1).ceilToDouble();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY - minY) / 4,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: context.colors.outline.withValues(alpha: 0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}${unit ?? ''}',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= sortedData.length) {
                  return const SizedBox.shrink();
                }
                final date = sortedData[value.toInt()].date;
                return Text(
                  DateFormat('MMM d').format(date),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: sortedData
                .asMap()
                .entries
                .map((e) => FlSpot(e.key.toDouble(), e.value.value))
                .toList(),
            isCurved: true,
            color: context.colors.primary,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: context.colors.primary,
                  strokeWidth: 2,
                  strokeColor: context.colors.surface,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: context.colors.primary.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  /// Build bar chart for volume
  Widget _buildBarChart(BuildContext context) {
    final sortedData = List<ChartDataPoint>.from(data)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Calculate max for Y axis
    final maxY = sortedData
            .map((d) => d.value)
            .reduce((a, b) => a > b ? a : b) *
        1.1;

    return BarChart(
      BarChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: context.colors.outline.withValues(alpha: 0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}${unit ?? ''}',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= sortedData.length) {
                  return const SizedBox.shrink();
                }
                final date = sortedData[value.toInt()].date;
                return Text(
                  sortedData[value.toInt()].label ??
                      DateFormat('MMM d').format(date),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        maxY: maxY,
        barGroups: sortedData
            .asMap()
            .entries
            .map(
              (e) => BarChartGroupData(
                x: e.key,
                barRods: [
                  BarChartRodData(
                    toY: e.value.value,
                    color: context.colors.primary,
                    width: 16,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  /// Build legend with trend indicator
  Widget _buildLegend(BuildContext context) {
    if (data.length < 2) {
      return const SizedBox.shrink();
    }

    // Calculate trend (first vs last)
    final sortedData = List<ChartDataPoint>.from(data)
      ..sort((a, b) => a.date.compareTo(b.date));

    final first = sortedData.first.value;
    final last = sortedData.last.value;
    final change = last - first;
    final changePercent = (change / first * 100).abs();

    final isIncrease = change > 0;
    final trendColor = isIncrease ? context.iconSuccess : context.iconError;
    final trendIcon = isIncrease ? '↑' : '↓';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${sortedData.first.value.toStringAsFixed(1)} ${unit ?? ''} → ${sortedData.last.value.toStringAsFixed(1)} ${unit ?? ''}',
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        Row(
          children: [
            Text(
              trendIcon,
              style: context.textTheme.titleMedium?.copyWith(
                color: trendColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${changePercent.toStringAsFixed(1)}%',
              style: context.textTheme.bodySmall?.copyWith(
                color: trendColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Chart data point
class ChartDataPoint { // Optional custom label for X-axis

  ChartDataPoint({
    required this.date,
    required this.value,
    this.label,
  });
  final DateTime date;
  final double value;
  final String? label;
}

/// Chart type enum
enum InlineChartType {
  line,
  bar,
}
