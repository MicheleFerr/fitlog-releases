/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation/widgets
/// 🎯 Feature: workout
/// 🔧 Type: widget (Multi-Metric Chart Display)
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: Universal
///
/// Dependencies:
/// - fl_chart: Line chart rendering
/// - Chart Data Provider
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/chart_data_point.dart';

/// Widget per visualizzare grafico multi-metrica con overlay
///
/// Supporta simultaneamente: Peso, Reps, RPE, TUT
/// Features:
/// - Multiple line charts con colori diversi
/// - **Normalizzazione intelligente** per scale diverse (0-100)
/// - Tooltip con **valori reali** (non normalizzati)
/// - Legend interattiva
/// - Empty state quando nessun dato
/// - Responsive a dark/light theme
///
/// SOLUZIONE AL PROBLEMA SCALE:
/// - Peso 120 kg vs Reps 4 → normalizzati visivamente
/// - Tooltip mostra valori reali: "Peso: 120.0 kg", "Reps: 4"
class MultiMetricChart extends StatefulWidget {
  final Map<String, List<ChartDataPoint>> dataByMetric;
  final List<String> selectedMetrics;

  const MultiMetricChart({
    super.key,
    required this.dataByMetric,
    required this.selectedMetrics,
  });

  @override
  State<MultiMetricChart> createState() => _MultiMetricChartState();
}

class _MultiMetricChartState extends State<MultiMetricChart> {
  final Set<String> _hiddenMetrics = {};

  // ✅ Cache per valori originali (prima normalizzazione)
  // Map<metric, Map<dateIndex, realValue>>
  final Map<String, Map<int, double>> _originalValues = {};

  @override
  Widget build(BuildContext context) {
    if (widget.dataByMetric.isEmpty || widget.selectedMetrics.isEmpty) {
      return _buildEmptyState(context);
    }

    // Filter out hidden metrics
    final visibleMetrics = widget.selectedMetrics
        .where((metric) => !_hiddenMetrics.contains(metric))
        .toList();

    if (visibleMetrics.isEmpty) {
      return _buildEmptyState(context);
    }

    return RepaintBoundary(
      child: Column(
        children: [
          // Legend
          _buildLegend(context),

          // ✅ Hint: Valori normalizzati + tooltip
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 14,
                  color: context.colors.onSurface.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 4),
                Text(
                  context.l10n.chartTapToSeeRealValues,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colors.onSurface.withValues(alpha: 0.5),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),

          // Chart
          Container(
            height: 250,
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
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: context.colors.outline.withValues(alpha: 0.1),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  // ✅ Hide Y-axis labels (valori normalizzati non significativi)
                  // Valori reali mostrati nei tooltip
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: _calculateDateInterval(),
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        final allDates = _getAllUniqueDates();
                        if (index < 0 || index >= allDates.length) {
                          return const SizedBox.shrink();
                        }
                        final date = allDates[index];
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
                lineBarsData: _buildLineBarsData(context, visibleMetrics),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => context.colors.surface,
                    getTooltipItems: (touchedSpots) => _buildTooltipItems(context, touchedSpots),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build legend con toggle per nascondere metriche
  Widget _buildLegend(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: widget.selectedMetrics.map((metric) {
        final color = _getMetricColor(context, metric);
        final isHidden = _hiddenMetrics.contains(metric);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isHidden) {
                _hiddenMetrics.remove(metric);
              } else {
                _hiddenMetrics.add(metric);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isHidden
                  ? context.colors.surfaceContainerHighest
                  : color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isHidden
                    ? context.colors.outline.withValues(alpha: 0.3)
                    : color,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isHidden ? context.colors.outline : color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  metric,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: isHidden
                        ? context.colors.onSurface.withValues(alpha: 0.5)
                        : context.colors.onSurface,
                    decoration: isHidden ? TextDecoration.lineThrough : null,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Build line bars per ogni metrica visibile con **normalizzazione intelligente**
  ///
  /// ✅ SOLUZIONE PROBLEMA SCALE:
  /// - Calcola min/max per ogni metrica
  /// - Normalizza valori a scala 0-100
  /// - Salva valori originali in _originalValues per tooltip
  /// - Tutte le metriche ora visibili (Peso 120 kg e Reps 4 entrambi visibili)
  List<LineChartBarData> _buildLineBarsData(BuildContext context, List<String> visibleMetrics) {
    final allDates = _getAllUniqueDates();
    final bars = <LineChartBarData>[];

    // ✅ Clear cache valori originali
    _originalValues.clear();

    for (final metric in visibleMetrics) {
      final dataPoints = widget.dataByMetric[metric] ?? [];
      if (dataPoints.isEmpty) continue;

      final color = _getMetricColor(context, metric);

      // ✅ Calcola min/max per questa metrica
      final values = dataPoints.map((p) => p.value).toList();
      final minValue = values.reduce((a, b) => a < b ? a : b);
      final maxValue = values.reduce((a, b) => a > b ? a : b);
      final range = maxValue - minValue;

      // Inizializza cache per questa metrica
      _originalValues[metric] = {};

      // ✅ Map data points to spots con normalizzazione
      final spots = <FlSpot>[];
      for (final point in dataPoints) {
        final dateIndex = allDates.indexWhere(
          (d) => d.year == point.date.year &&
                 d.month == point.date.month &&
                 d.day == point.date.day,
        );
        if (dateIndex != -1) {
          // Salva valore originale
          _originalValues[metric]![dateIndex] = point.value;

          // Normalizza a 0-100
          final normalizedValue = range > 0
              ? ((point.value - minValue) / range) * 100
              : 50.0; // Se tutti i valori sono uguali, metti a 50

          spots.add(FlSpot(dateIndex.toDouble(), normalizedValue));
        }
      }

      bars.add(
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: color,
          barWidth: 2.5,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
              radius: 3,
              color: color,
              strokeWidth: 1.5,
              strokeColor: context.colors.surface,
            ),
          ),
          belowBarData: BarAreaData(show: false),
        ),
      );
    }

    return bars;
  }

  /// Build tooltip items mostrando **valori reali** (non normalizzati)
  ///
  /// ✅ FIX TOOLTIP:
  /// - Usa _originalValues per recuperare valori reali
  /// - Mappa correttamente touchedSpots a visibleMetrics
  /// - Mostra "Peso: 120.0 kg" invece di valore normalizzato "85.3"
  List<LineTooltipItem?> _buildTooltipItems(BuildContext context, List<LineBarSpot> touchedSpots) {
    final items = <LineTooltipItem>[];

    if (touchedSpots.isEmpty) return items;

    final dateIndex = touchedSpots.first.x.toInt();
    final allDates = _getAllUniqueDates();

    if (dateIndex < 0 || dateIndex >= allDates.length) return items;

    final date = allDates[dateIndex];

    // ✅ Get visible metrics (excluding hidden ones)
    final visibleMetrics = widget.selectedMetrics
        .where((metric) => !_hiddenMetrics.contains(metric))
        .toList();

    // Header con data
    items.add(
      LineTooltipItem(
        '${DateFormat('dd/MM').format(date)}\n',
        TextStyle(
          color: context.colors.onSurface,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );

    // ✅ Valori per ogni metrica VISIBILE con valori REALI
    for (int i = 0; i < touchedSpots.length && i < visibleMetrics.length; i++) {
      final metric = visibleMetrics[i]; // ✅ Correct mapping
      final color = _getMetricColor(context, metric);
      final unit = _getUnit(metric);

      // ✅ Recupera valore REALE (non normalizzato)
      final realValue = _originalValues[metric]?[dateIndex];

      if (realValue != null) {
        items.add(
          LineTooltipItem(
            '$metric: ${realValue.toStringAsFixed(1)}$unit\n',
            TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 10,
            ),
          ),
        );
      }
    }

    return items;
  }

  /// Get all unique dates from all metrics
  List<DateTime> _getAllUniqueDates() {
    final dates = <DateTime>{};

    for (final dataPoints in widget.dataByMetric.values) {
      for (final point in dataPoints) {
        // Normalize to day precision
        dates.add(DateTime(point.date.year, point.date.month, point.date.day));
      }
    }

    final sortedDates = dates.toList()..sort();
    return sortedDates;
  }

  /// Calcola intervallo ottimale per label date
  double _calculateDateInterval() {
    final allDates = _getAllUniqueDates();
    if (allDates.length <= 5) return 1;
    return (allDates.length / 5).ceilToDouble();
  }

  /// Get color for metric
  Color _getMetricColor(BuildContext context, String metric) {
    switch (metric) {
      case 'Peso':
        return context.colors.primary;
      case 'Reps':
        return context.colors.tertiary;
      case 'RPE':
        return context.colors.error;
      case 'TUT':
        return context.colors.secondary;
      default:
        return context.colors.onSurface;
    }
  }

  /// Ritorna unità di misura per metrica
  String _getUnit(String metric) {
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
            const SizedBox(height: 8),
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
