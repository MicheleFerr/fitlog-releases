/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/widgets/charts
/// 🎯 Feature: analytics
/// 🔧 Type: widget (chart)
///
/// Max Weight Progression Chart - Shows heaviest weight lifted over time
///
/// **Purpose**: Track max weight progression for an exercise
///
/// **Features**:
/// - Line chart showing max weight per session
/// - Dots on data points for clarity
/// - Gradient fill under line
/// - Touch interaction to see exact values
/// - Auto-scales Y-axis based on data
///
/// **Data Source**: ExerciseHistory.sessions → max weight per session
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:intl/intl.dart';

/// Max weight progression chart
class MaxWeightProgressionChart extends StatelessWidget {
  const MaxWeightProgressionChart({
    required this.history,
    super.key,
  });

  final ExerciseHistory history;

  @override
  Widget build(BuildContext context) {
    final sessions = history.sessionsSortedByDateAscending;

    if (sessions.isEmpty) {
      return Center(
        child: Text(
          context.l10n.noDataAvailable,
          style: context.textTheme.bodyLarge?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      );
    }

    // Extract max weight per session
    final spots = <FlSpot>[];
    for (int i = 0; i < sessions.length; i++) {
      final session = sessions[i];
      final maxWeight = session.sets
          .map((s) => s.weight)
          .reduce((a, b) => a > b ? a : b);
      spots.add(FlSpot(i.toDouble(), maxWeight));
    }

    // Calculate Y-axis range
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final padding = (maxY - minY) * 0.1; // 10% padding

    return Padding(
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxY - minY + 2 * padding) / 5,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: context.colors.onSurfaceVariant.withValues(alpha: 0.1),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: sessions.length > 10 ? sessions.length / 5 : 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= sessions.length) {
                    return const SizedBox();
                  }
                  final date = sessions[index].date;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      DateFormat('MMM d').format(date),
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()} kg',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(
                color: context.colors.onSurfaceVariant.withValues(alpha: 0.2),
              ),
              left: BorderSide(
                color: context.colors.onSurfaceVariant.withValues(alpha: 0.2),
              ),
            ),
          ),
          minX: 0,
          maxX: (sessions.length - 1).toDouble(),
          minY: minY - padding,
          maxY: maxY + padding,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.3,
              color: context.colors.primary,
              barWidth: 3,
              isStrokeCapRound: true,
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
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    context.colors.primary.withValues(alpha: 0.3),
                    context.colors.primary.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) => context.colors.surfaceContainerHighest,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final index = spot.x.toInt();
                  final session = sessions[index];
                  final date = DateFormat('MMM d, yyyy').format(session.date);
                  return LineTooltipItem(
                    '${spot.y.toStringAsFixed(1)} kg\n$date',
                    context.textTheme.bodySmall!.copyWith(
                      color: context.colors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }
}
