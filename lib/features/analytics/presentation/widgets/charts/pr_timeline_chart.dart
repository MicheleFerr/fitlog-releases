/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/widgets/charts
/// 🎯 Feature: analytics
/// 🔧 Type: widget (chart)
///
/// PR Timeline Chart - Shows Personal Records achieved over time
///
/// **Purpose**: Visualize when PRs were achieved (motivational)
///
/// **Features**:
/// - Scatter plot showing PR moments
/// - Color-coded by intensity (darker = higher weight)
/// - Touch interaction to see PR details
/// - Only shows sessions where PR was achieved
///
/// **Data Source**: ExerciseHistory.sessions → sessions with new PRs
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_session.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:intl/intl.dart';

/// PR timeline chart
class PRTimelineChart extends StatelessWidget {
  const PRTimelineChart({
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

    // Find PR sessions (sessions where 1RM improved)
    final prSessions = <({int index, ExerciseSession session})>[];
    double currentBest = 0;

    for (int i = 0; i < sessions.length; i++) {
      final session = sessions[i];
      final oneRM = session.highestEstimated1RM;

      if (oneRM > currentBest) {
        prSessions.add((index: i, session: session));
        currentBest = oneRM;
      }
    }

    if (prSessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '🏆',
              style: context.textTheme.displayMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'No PRs yet!',
              style: context.textTheme.titleLarge?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Keep training to achieve your first PR',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    // Create scatter spots for PRs
    final spots = <ScatterSpot>[];
    final maxY = prSessions.last.session.highestEstimated1RM;
    final minY = prSessions.first.session.highestEstimated1RM;

    for (final pr in prSessions) {
      final oneRM = pr.session.highestEstimated1RM;
      spots.add(ScatterSpot(pr.index.toDouble(), oneRM));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ScatterChart(
        ScatterChartData(
          scatterSpots: spots,
          minX: 0,
          maxX: (sessions.length - 1).toDouble(),
          minY: minY * 0.95,
          maxY: maxY * 1.05,
          scatterLabelSettings: ScatterLabelSettings(
            showLabel: false,
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxY - minY) / 5,
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
          scatterTouchData: ScatterTouchData(
            enabled: true,
            touchTooltipData: ScatterTouchTooltipData(
              getTooltipColor: (touchedSpot) =>
                  context.colors.surfaceContainerHighest,
              getTooltipItems: (touchedSpot) {
                // Find the PR session that matches this spot
                final pr = prSessions.firstWhere(
                  (pr) => pr.index.toDouble() == touchedSpot.x,
                );
                final date = DateFormat('MMM d, yyyy').format(pr.session.date);
                return ScatterTooltipItem(
                  '🏆 PR: ${touchedSpot.y.toStringAsFixed(1)} kg\n$date',
                  textStyle: context.textTheme.bodySmall!.copyWith(
                    color: context.colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
