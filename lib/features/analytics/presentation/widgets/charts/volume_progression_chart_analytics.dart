/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/widgets/charts
/// 🎯 Feature: analytics
/// 🔧 Type: widget (chart)
///
/// Volume Progression Chart (Analytics) - Shows total volume over time
///
/// **Purpose**: Track volume (weight × reps) progression for an exercise
///
/// **Features**:
/// - Bar chart showing volume per session
/// - Color-coded bars (green for PR sessions, blue for normal)
/// - Touch interaction to see exact values
/// - Auto-scales Y-axis based on data
///
/// **Data Source**: ExerciseHistory.sessions → totalVolume per session
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:intl/intl.dart';

/// Volume progression chart
class VolumeProgressionChartAnalytics extends StatelessWidget {
  const VolumeProgressionChartAnalytics({
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

    // Extract volume per session
    final barGroups = <BarChartGroupData>[];
    double maxVolume = 0;

    for (int i = 0; i < sessions.length; i++) {
      final session = sessions[i];
      final volume = session.totalVolume;
      if (volume > maxVolume) maxVolume = volume;

      // Check if this session has a PR (highest 1RM)
      final isPR = session.highestEstimated1RM == history.personalRecord;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: volume,
              color: isPR ? context.colors.success : context.colors.primary,
              width: 12,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxVolume * 1.1, // 10% padding on top
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => context.colors.surfaceContainerHighest,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final session = sessions[groupIndex];
                final date = DateFormat('MMM d, yyyy').format(session.date);
                return BarTooltipItem(
                  '${rod.toY.toStringAsFixed(0)} kg\n$date',
                  context.textTheme.bodySmall!.copyWith(
                    color: context.colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
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
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= sessions.length) {
                    return const SizedBox();
                  }
                  // Show date every N bars to avoid overlap
                  if (sessions.length > 10 && index % (sessions.length ~/ 5) != 0) {
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
                reservedSize: 50,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${(value / 1000).toStringAsFixed(1)}k',
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
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxVolume / 5,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: context.colors.onSurfaceVariant.withValues(alpha: 0.1),
                strokeWidth: 1,
              );
            },
          ),
          barGroups: barGroups,
        ),
      ),
    );
  }
}
