/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/widgets
/// 🎯 Feature: analytics
/// 🔧 Type: widget
///
/// ExerciseVolumeChart - Per-session volume chart for Exercise Detail Screen
///
/// **Purpose**: Display volume progression per workout session for a specific exercise
///
/// **Features**:
/// - Line chart showing total volume per workout session
/// - Interactive touch points with volume + date values
/// - Trend line visualization
/// - Theme-aware colors (primary gradient)
/// - Responsive design (adapts to screen width)
/// - Empty state handling
///
/// **Chart Data**:
/// - X-axis: Session date (chronological)
/// - Y-axis: Total volume (kg)
/// - Points: Each workout session for this exercise
/// - Line: Connects sessions chronologically
///
/// **Difference from VolumeProgressionChart**:
/// - VolumeProgressionChart: Weekly aggregated volume from ALL workouts
/// - ExerciseVolumeChart: Per-session volume for SINGLE exercise
///
/// **Usage**:
/// ```dart
/// ExerciseVolumeChart(history: exerciseHistory)
/// ```
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:intl/intl.dart';

/// Exercise Volume Chart Widget
///
/// **Displays**: Line chart of volume per workout session
/// **Height**: ~200px
class ExerciseVolumeChart extends StatelessWidget {
  const ExerciseVolumeChart({
    required this.history,
    super.key,
  });

  final ExerciseHistory history;

  @override
  Widget build(BuildContext context) {
    final sessions = history.sessionsSortedByDateAscending;

    // Handle empty state
    if (sessions.isEmpty) {
      return Container(
        height: 200,
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            context.l10n.noWorkoutDataYet,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    // Prepare chart data
    final spots = <FlSpot>[];
    double maxVolume = 0;
    double minVolume = double.infinity;

    for (int i = 0; i < sessions.length; i++) {
      final volume = sessions[i].totalVolume;
      spots.add(FlSpot(i.toDouble(), volume));

      if (volume > maxVolume) maxVolume = volume;
      if (volume < minVolume) minVolume = volume;
    }

    // Add 10% padding to y-axis for better visualization
    final yPadding = (maxVolume - minVolume) * 0.1;
    var yMax = maxVolume + yPadding;
    var yMin = (minVolume - yPadding).clamp(0.0, double.infinity).toDouble();

    // 🛡️ SAFETY: Ensure minimum range to prevent fl_chart horizontalInterval zero crash
    // When all volumes are identical, yMax == yMin, causing division by zero
    final yRange = yMax - yMin;
    if (yRange < 10) {
      // Add minimum 10kg range for single-value datasets
      final mid = (yMax + yMin) / 2;
      yMax = mid + 5;
      yMin = (mid - 5).clamp(0.0, double.infinity).toDouble();
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: context.colors.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart title
          Text(
            context.l10n.volumeProgression,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Chart
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (yMax - yMin) / 4,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: context.colors.outlineVariant.withValues(alpha: 0.3),
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
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}',
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
                      reservedSize: 30,
                      interval: sessions.length > 10 ? sessions.length / 5 : 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= sessions.length) {
                          return const SizedBox.shrink();
                        }

                        final date = sessions[index].date;
                        final formattedDate = DateFormat('M/d').format(date);

                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            formattedDate,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colors.onSurfaceVariant,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: context.colors.outlineVariant.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                minX: 0,
                maxX: (sessions.length - 1).toDouble(),
                minY: yMin,
                maxY: yMax,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
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
                      color: context.colors.primary.withValues(alpha: 0.1),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final index = spot.x.toInt();
                        final session = sessions[index];
                        final date = DateFormat('MMM d').format(session.date);
                        final volume = session.totalVolume;

                        return LineTooltipItem(
                          '$date\n${volume.toStringAsFixed(0)} kg',
                          context.textTheme.bodySmall!.copyWith(
                            color: context.colors.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
