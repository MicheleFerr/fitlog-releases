/// Reps Line Chart - Syncfusion implementation
///
/// Simplified line chart for reps progression with average overlay.
/// Based on UX research: maintains visual consistency with weight chart.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_progress_metrics.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

class RepsLineChart extends StatelessWidget {
  const RepsLineChart({
    super.key,
    required this.sets,
    this.height = 220,
    this.showTooltip = true,
    this.showAverage = true,
    this.animate = true,
  });

  final List<ExerciseSetData> sets;
  final double height;
  final bool showTooltip;
  final bool showAverage;
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

    final maxReps = sets.map((s) => s.reps).reduce((a, b) => a > b ? a : b);
    final minReps = sets.map((s) => s.reps).reduce((a, b) => a < b ? a : b);
    final avgReps = sets.fold<int>(0, (sum, s) => sum + s.reps) / sets.length;

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
          minimum: (minReps - 2).clamp(0, double.infinity).toDouble(),
          maximum: maxReps + 2,
          majorGridLines: MajorGridLines(
            color: context.colors.outline.withValues(alpha: 0.15),
            dashArray: const <double>[4, 4],
          ),
          axisLine: const AxisLine(width: 0),
          labelStyle: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
            fontSize: 10,
          ),
          majorTickLines: const MajorTickLines(size: 0),
          plotBands: showAverage
              ? <PlotBand>[
                  PlotBand(
                    start: avgReps,
                    end: avgReps,
                    borderColor: context.colors.success.withValues(alpha: 0.5),
                    borderWidth: 2,
                    dashArray: const <double>[6, 4],
                    text: '${context.l10n.tooltipAvg}: ${avgReps.toStringAsFixed(1)}',
                    textStyle: context.textTheme.labelSmall!.copyWith(
                      color: context.colors.success,
                      fontSize: 9,
                    ),
                    horizontalTextAlignment: TextAnchor.end,
                    verticalTextAlignment: TextAnchor.start,
                  ),
                ]
              : <PlotBand>[],
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
                          '${setData.reps} reps',
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
          SplineAreaSeries<ExerciseSetData, DateTime>(
            dataSource: sets,
            xValueMapper: (data, _) => data.date,
            yValueMapper: (data, _) => data.reps.toDouble(),
            splineType: SplineType.monotonic,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                context.colors.success.withValues(alpha: 0.3),
                context.colors.success.withValues(alpha: 0.05),
              ],
            ),
            borderColor: context.colors.success,
            borderWidth: 2.5,
            animationDuration: animate ? 1500 : 0,
          ),
          SplineSeries<ExerciseSetData, DateTime>(
            dataSource: sets,
            xValueMapper: (data, _) => data.date,
            yValueMapper: (data, _) => data.reps.toDouble(),
            splineType: SplineType.monotonic,
            color: context.colors.success,
            width: 2.5,
            markerSettings: MarkerSettings(
              isVisible: sets.length <= 12,
              height: 7,
              width: 7,
              borderWidth: 2,
              borderColor: context.colors.surface,
              color: context.colors.success,
            ),
            animationDuration: animate ? 1500 : 0,
          ),
        ],
      ),
    );
  }

  DateFormat _getDateFormat() {
    if (sets.length <= 1) return DateFormat('d MMM');
    final range = sets.last.date.difference(sets.first.date);
    if (range.inDays > 180) return DateFormat('MMM yy');
    if (range.inDays > 30) return DateFormat('d MMM');
    return DateFormat('d');
  }
}
