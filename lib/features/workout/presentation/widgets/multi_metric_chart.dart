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
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

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

  const MultiMetricChart({
    super.key,
    required this.dataByMetric,
    required this.selectedMetrics,
  });
  final Map<String, List<ChartDataPoint>> dataByMetric;
  final List<String> selectedMetrics;

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

    // ✅ NEW: Generate insights
    final insight = _generateInsight(context);

    return RepaintBoundary(
      child: Column(
        children: [
          // Legend
          _buildLegend(context),

          // ✅ NEW: Insights Card
          if (insight != null) ...[
            const SizedBox(height: 12),
            _buildInsightCard(context, insight),
          ],

          // ✅ Hint: Valori normalizzati + tooltip
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SemanticIcon(
  icon: AppIcons.infoOutline,
  semanticLabel: 'Info outline',
  size: AppIconSize.tiny,
  color: context.colors.onSurface.withValues(alpha: 0.5,
),
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
  /// - Ritorna esattamente touchedSpots.length items (richiesto da fl_chart)
  /// - Primo item contiene data + tutti i valori metriche
  /// - Restanti items sono null
  /// - Usa _originalValues per recuperare valori reali
  List<LineTooltipItem?> _buildTooltipItems(BuildContext context, List<LineBarSpot> touchedSpots) {
    if (touchedSpots.isEmpty) return [];

    final dateIndex = touchedSpots.first.x.toInt();
    final allDates = _getAllUniqueDates();

    if (dateIndex < 0 || dateIndex >= allDates.length) {
      // Return list of nulls matching touchedSpots length
      return List.filled(touchedSpots.length, null);
    }

    final date = allDates[dateIndex];

    // ✅ Get visible metrics (excluding hidden ones)
    final visibleMetrics = widget.selectedMetrics
        .where((metric) => !_hiddenMetrics.contains(metric))
        .toList();

    // ✅ Build single tooltip text with all metrics
    final buffer = StringBuffer();
    buffer.write(DateFormat('dd/MM').format(date));

    // Collect metric values with their colors for TextSpan
    final metricLines = <({String text, Color color})>[];

    for (int i = 0; i < touchedSpots.length && i < visibleMetrics.length; i++) {
      final metric = visibleMetrics[i];
      final color = _getMetricColor(context, metric);
      final unit = _getUnit(metric);
      final realValue = _originalValues[metric]?[dateIndex];

      if (realValue != null) {
        metricLines.add((
          text: '$metric: ${realValue.toStringAsFixed(1)}$unit',
          color: color,
        ));
      }
    }

    // ✅ Create list with exactly touchedSpots.length items
    // First item has all content, rest are null
    final result = <LineTooltipItem?>[];

    for (int i = 0; i < touchedSpots.length; i++) {
      if (i == 0) {
        // First item contains all tooltip content
        final children = <TextSpan>[];

        for (final line in metricLines) {
          children.add(TextSpan(
            text: '\n${line.text}',
            style: TextStyle(
              color: line.color,
              fontWeight: FontWeight.w500,
              fontSize: 10,
            ),
          ));
        }

        result.add(LineTooltipItem(
          DateFormat('dd/MM').format(date),
          TextStyle(
            color: context.colors.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
          children: children,
        ));
      } else {
        // Remaining items are null (fl_chart requires exactly touchedSpots.length)
        result.add(null);
      }
    }

    return result;
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

  /// ✅ NEW: Genera insight intelligente analizzando trend ultimo vs precedente workout
  ///
  /// Pattern riconosciuti:
  /// - Peso ↑, Reps ↓ → Progressive overload
  /// - Peso ↑, Reps ↓↓ (>30%) → Warning: riduci peso
  /// - Peso =, Reps ↑ → Volume increase (buono)
  /// - RPE sempre alto (>9) → Suggerimento recupero
  _InsightData? _generateInsight(BuildContext context) {
    final allDates = _getAllUniqueDates();
    if (allDates.length < 2) return null; // Serve almeno 2 workout

    final lastDate = allDates.last;
    final prevDate = allDates[allDates.length - 2];

    // Get data for Peso e Reps
    final pesoData = widget.dataByMetric['Peso'] ?? [];
    final repsData = widget.dataByMetric['Reps'] ?? [];
    final rpeData = widget.dataByMetric['RPE'] ?? [];

    final lastPeso = pesoData.firstWhere(
      (p) => _sameDay(p.date, lastDate),
      orElse: () => pesoData.last,
    ).value;
    final prevPeso = pesoData.firstWhere(
      (p) => _sameDay(p.date, prevDate),
      orElse: () => pesoData.first,
    ).value;

    final lastReps = repsData.firstWhere(
      (p) => _sameDay(p.date, lastDate),
      orElse: () => repsData.last,
    ).value;
    final prevReps = repsData.firstWhere(
      (p) => _sameDay(p.date, prevDate),
      orElse: () => repsData.first,
    ).value;

    final pesoDiff = lastPeso - prevPeso;
    final repsDiff = lastReps - prevReps;
    final repsChangePercent = prevReps > 0 ? (repsDiff / prevReps) * 100 : 0;

    // ✅ Pattern 1: Peso ↑, Reps ↓↓ (>30%) → Warning
    if (pesoDiff > 0 && repsChangePercent < -30) {
      return _InsightData(
        icon: AppIcons.warning,
        color: context.colors.error,
        title: 'Peso troppo alto',
        message:
            'Hai aumentato il peso di ${pesoDiff.toStringAsFixed(1)}kg ma le reps sono calate del ${repsChangePercent.abs().toStringAsFixed(0)}%. Considera di ridurre il peso e mantenere le reps.',
      );
    }

    // ✅ Pattern 2: Peso ↑, Reps ↓ (10-30%) → Progressive overload
    if (pesoDiff > 0 && repsDiff < 0 && repsChangePercent >= -30) {
      return _InsightData(
        icon: AppIcons.trendUp,
        color: context.colors.success,
        title: 'Progressive Overload',
        message:
            'Peso +${pesoDiff.toStringAsFixed(1)}kg, Reps ${repsDiff.toStringAsFixed(0)}. Ottimo! Prossimo step: mantieni questo peso e recupera le reps.',
      );
    }

    // ✅ Pattern 3: Peso =, Reps ↑ → Volume increase
    if (pesoDiff.abs() < 2.5 && repsDiff > 0) {
      return _InsightData(
        icon: AppIcons.trendUp,
        color: context.colors.tertiary,
        title: 'Aumento Volume',
        message:
            'Reps +${repsDiff.toStringAsFixed(0)} mantenendo il peso. Ottimo! Quando raggiungi +3 reps, considera di aumentare il peso.',
      );
    }

    // ✅ Pattern 4: RPE sempre alto (media >9) → Recupero
    if (rpeData.length >= 3) {
      final lastThreeRPE = rpeData.reversed.take(3).map((p) => p.value).toList();
      final avgRPE = lastThreeRPE.reduce((a, b) => a + b) / lastThreeRPE.length;
      if (avgRPE > 9) {
        return _InsightData(
          icon: AppIcons.warning,
          color: context.colors.error,
          title: 'RPE Troppo Alto',
          message:
              'Media RPE ultimi 3 workout: ${avgRPE.toStringAsFixed(1)}/10. Considera un deload (riduzione peso 10-20%) per recuperare.',
        );
      }
    }

    return null;
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// ✅ NEW: Widget card per visualizzare insight
  Widget _buildInsightCard(BuildContext context, _InsightData insight) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            insight.color.withValues(alpha: 0.15),
            insight.color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: insight.color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: insight.color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              insight.icon,
              size: 20,
              color: insight.color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: insight.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  insight.message,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurface.withValues(alpha: 0.7),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
            SemanticIcon(
  icon: AppIcons.showChart,
  semanticLabel: 'Show chart',
  size: AppIconSize.xxlarge,
  color: context.colors.onSurface.withValues(alpha: 0.3,
),
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

/// ✅ NEW: Data class per insight
class _InsightData {
  const _InsightData({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String message;
}
