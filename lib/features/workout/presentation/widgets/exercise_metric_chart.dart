/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation/widgets
/// 🎯 Feature: workout
/// 🔧 Type: widget (Chart Display)
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: Universal
///
/// Dependencies:
/// - fl_chart: Line chart rendering
/// - Chart Data Domain Entity
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/chart_data_point.dart';

/// Widget per visualizzare grafico metrica esercizio
///
/// Supporta: Peso, Reps, RPE, TUT
/// Features:
/// - Line chart con gradient fill
/// - Tooltip interattivi con data e valore
/// - Empty state quando nessun dato
/// - Responsive a dark/light theme
class ExerciseMetricChart extends StatelessWidget {

  const ExerciseMetricChart({
    super.key,
    required this.dataPoints,
    required this.metric,
  });
  final List<ChartDataPoint> dataPoints;
  final String metric;

  @override
  Widget build(BuildContext context) {
    if (dataPoints.isEmpty) {
      return _buildEmptyState(context);
    }

    return RepaintBoundary(
      child: Container(
        height: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: context.colors.outline.withValues(alpha: 0.2),
          ),
        ),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: _calculateInterval(),
              getDrawingHorizontalLine: (value) => FlLine(
                color: context.colors.outline.withValues(alpha: 0.1),
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) => Text(
                    value.toStringAsFixed(0),
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: _calculateDateInterval(),
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= dataPoints.length) {
                      return const SizedBox.shrink();
                    }
                    final date = dataPoints[index].date;
                    return Text(
                      DateFormat('dd/MM').format(date),
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.colors.onSurface.withValues(alpha: 0.6),
                      ),
                    );
                  },
                ),
              ),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: dataPoints
                    .asMap()
                    .entries
                    .map((e) => FlSpot(e.key.toDouble(), e.value.value))
                    .toList(),
                isCurved: true,
                color: context.colors.primary,
                barWidth: 3,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                    radius: 4,
                    color: context.colors.primary,
                    strokeWidth: 2,
                    strokeColor: context.colors.surface,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      context.colors.primary.withValues(alpha: 0.3),
                      context.colors.primary.withValues(alpha: 0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (touchedSpot) => context.colors.primary,
                getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
                  final index = spot.x.toInt();
                  if (index < 0 || index >= dataPoints.length) return null;

                  final date = dataPoints[index].date;
                  final value = spot.y;

                  return LineTooltipItem(
                    '${DateFormat('dd/MM').format(date)}\n${value.toStringAsFixed(1)}${_getUnit()}',
                    TextStyle(
                      color: context.colors.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Calcola intervallo ottimale per grid orizzontali
  double _calculateInterval() {
    if (dataPoints.isEmpty) return 10;
    final values = dataPoints.map((d) => d.value).toList();
    final max = values.reduce((a, b) => a > b ? a : b);
    final min = values.reduce((a, b) => a < b ? a : b);
    final range = max - min;
    return range > 0 ? range / 5 : 10;
  }

  /// Calcola intervallo ottimale per label date
  double _calculateDateInterval() {
    if (dataPoints.length <= 5) return 1;
    return (dataPoints.length / 5).ceilToDouble();
  }

  /// Ritorna unità di misura per metrica
  String _getUnit() {
    switch (metric) {
      case 'Peso':
        return ' kg';
      case 'Reps':
        return '';
      case 'RPE':
        return '/10';
      case 'TUT':
        return 's';
      default:
        return '';
    }
  }

  /// Widget empty state quando nessun dato disponibile
  Widget _buildEmptyState(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              size: 48,
              color: context.colors.onSurface.withValues(alpha: 0.3),
            ),
            SizedBox(height: 8),
            Text(
              context.l10n.noDataForChart,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
