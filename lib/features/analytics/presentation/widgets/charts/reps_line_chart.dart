/// Reps Line Chart - Syncfusion implementation
///
/// Simplified line chart for reps progression with average overlay.
/// Based on UX research: maintains visual consistency with weight chart.
///
/// **Data Aggregation**: Sets are aggregated by session (day) to prevent
/// overlapping data points when multiple sets occur on the same day.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_progress_metrics.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/usecases/aggregate_sets_by_session.dart';
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

    // Aggregate sets by session to prevent overlapping points
    final sessions = aggregateSetsBySession(sets);

    if (sessions.isEmpty) {
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

    // Use max reps per session for the chart
    final maxReps = sessions.fold<int>(
      0,
      (max, s) => s.maxReps > max ? s.maxReps : max,
    );
    final minReps = sessions.fold<int>(
      999999,
      (min, s) => s.maxReps < min ? s.maxReps : min,
    );
    final avgReps = sessions.fold<double>(
          0,
          (sum, s) => sum + s.maxReps,
        ) /
        sessions.length;

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
          dateFormat: _getDateFormat(sessions),
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
                    text:
                        '${context.l10n.tooltipAvg}: ${avgReps.toStringAsFixed(1)}',
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
                  final session = data as SessionDataPoint;
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
                          DateFormat('d MMM').format(session.date),
                          style: context.textTheme.labelSmall?.copyWith(
                            color: context.colors.onInverseSurface
                                .withValues(alpha: 0.7),
                          ),
                        ),
                        Text(
                          '${session.maxReps} reps',
                          style: context.textTheme.titleSmall?.copyWith(
                            color: context.colors.onInverseSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${session.setCount} sets',
                          style: context.textTheme.labelSmall?.copyWith(
                            color: context.colors.onInverseSurface
                                .withValues(alpha: 0.7),
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
        series: <CartesianSeries<SessionDataPoint, DateTime>>[
          SplineAreaSeries<SessionDataPoint, DateTime>(
            dataSource: sessions,
            xValueMapper: (data, _) => data.date,
            yValueMapper: (data, _) => data.maxReps.toDouble(),
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
          SplineSeries<SessionDataPoint, DateTime>(
            dataSource: sessions,
            xValueMapper: (data, _) => data.date,
            yValueMapper: (data, _) => data.maxReps.toDouble(),
            splineType: SplineType.monotonic,
            color: context.colors.success,
            width: 2.5,
            markerSettings: MarkerSettings(
              isVisible: sessions.length <= 12,
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

  DateFormat _getDateFormat(List<SessionDataPoint> sessions) {
    if (sessions.length <= 1) return DateFormat('d MMM');
    final range = sessions.last.date.difference(sessions.first.date);
    if (range.inDays > 180) return DateFormat('MMM yy');
    if (range.inDays > 30) return DateFormat('d MMM');
    return DateFormat('d');
  }
}
