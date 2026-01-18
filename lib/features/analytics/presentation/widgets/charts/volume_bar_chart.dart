/// Volume Bar Chart - Syncfusion implementation
///
/// Vertical bar chart for volume progression.
/// Based on UX research: bar charts are more intuitive for "quantity/amount".
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_progress_metrics.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

class VolumeBarChart extends StatelessWidget {
  const VolumeBarChart({
    super.key,
    required this.sets,
    this.height = 220,
    this.showTooltip = true,
    this.animate = true,
  });

  final List<ExerciseSetData> sets;
  final double height;
  final bool showTooltip;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    if (sets.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            context.l10n.noDataForChart,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    final maxVolume = sets.map((s) => s.volume).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: height,
      child: SfCartesianChart(
        plotAreaBorderWidth: 0,
        margin: const EdgeInsets.only(top: 10, right: 10),
        primaryXAxis: DateTimeAxis(
          majorGridLines: const MajorGridLines(width: 0),
          axisLine: const AxisLine(width: 0),
          labelStyle: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
            fontSize: 10,
          ),
          dateFormat: _getDateFormat(),
          majorTickLines: const MajorTickLines(size: 0),
        ),
        primaryYAxis: NumericAxis(
          minimum: 0,
          maximum: maxVolume * 1.15,
          majorGridLines: MajorGridLines(
            color: context.colors.outline.withValues(alpha: 0.15),
            dashArray: const <double>[4, 4],
          ),
          axisLine: const AxisLine(width: 0),
          labelStyle: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
            fontSize: 10,
          ),
          labelFormat: '{value}',
          numberFormat: NumberFormat.compact(),
          majorTickLines: const MajorTickLines(size: 0),
        ),
        tooltipBehavior: showTooltip
            ? TooltipBehavior(
                enable: true,
                color: context.colors.inverseSurface,
                builder: (data, point, series, pointIndex, seriesIndex) {
                  final setData = data as ExerciseSetData;
                  return Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: context.colors.inverseSurface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('d MMM').format(setData.date),
                          style: context.textTheme.labelSmall?.copyWith(
                            color: context.colors.onInverseSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        Text(
                          '${_formatVolume(setData.volume)} kg',
                          style: context.textTheme.titleSmall?.copyWith(
                            color: context.colors.onInverseSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )
            : null,
        zoomPanBehavior: ZoomPanBehavior(
          enablePinching: true,
          enablePanning: true,
          zoomMode: ZoomMode.x,
        ),
        series: <CartesianSeries<ExerciseSetData, DateTime>>[
          ColumnSeries<ExerciseSetData, DateTime>(
            dataSource: sets,
            xValueMapper: (data, _) => data.date,
            yValueMapper: (data, _) => data.volume,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                context.colors.warning,
                context.colors.warning.withValues(alpha: 0.6),
              ],
            ),
            width: _calculateBarWidth(),
            animationDuration: animate ? 1200 : 0,
            // Highlight max volume bar
            pointColorMapper: (data, index) {
              if (data.volume == maxVolume) {
                return context.colors.warning;
              }
              return context.colors.warning.withValues(alpha: 0.7);
            },
          ),
        ],
      ),
    );
  }

  String _formatVolume(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toInt().toString();
  }

  DateFormat _getDateFormat() {
    if (sets.length <= 1) return DateFormat('d MMM');
    final range = sets.last.date.difference(sets.first.date);
    if (range.inDays > 180) return DateFormat('MMM');
    if (range.inDays > 30) return DateFormat('d MMM');
    return DateFormat('d');
  }

  double _calculateBarWidth() {
    if (sets.length <= 5) return 0.7;
    if (sets.length <= 10) return 0.6;
    if (sets.length <= 20) return 0.5;
    return 0.4;
  }
}
