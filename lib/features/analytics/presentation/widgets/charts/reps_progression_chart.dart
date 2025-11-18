/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/widgets/charts
/// 🎯 Feature: analytics
/// 🔧 Type: widget (chart)
///
/// Reps Progression Chart - Shows average reps per session over time
///
/// **Purpose**: Track endurance progression (reps performed)
///
/// **Features**:
/// - Line chart showing average reps per session
/// - Gradient fill under line
/// - Dots on data points
/// - Touch interaction to see exact values
/// - Shows trend of working in different rep ranges
///
/// **Data Source**: ExerciseHistory.sessions → average reps per session
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:intl/intl.dart';

/// Reps progression chart
class RepsProgressionChart extends StatelessWidget {
  const RepsProgressionChart({
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

    // Extract average reps per session
    final spots = <FlSpot>[];
    for (int i = 0; i < sessions.length; i++) {
      final session = sessions[i];
      // Calculate average reps across all sets
      final totalReps = session.sets.fold<int>(0, (sum, set) => sum + set.reps);
      final avgReps = totalReps / session.sets.length;
      spots.add(FlSpot(i.toDouble(), avgReps));
    }

    // Calculate Y-axis range
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final padding = (maxY - minY) * 0.15; // 15% padding

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
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
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
              color: context.colors.tertiary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: context.colors.tertiary,
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
                    context.colors.tertiary.withValues(alpha: 0.3),
                    context.colors.tertiary.withValues(alpha: 0.0),
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
                    '${spot.y.toStringAsFixed(1)} reps avg\n$date',
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
