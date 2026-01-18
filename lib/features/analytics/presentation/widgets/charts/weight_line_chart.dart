/// Weight Line Chart - Syncfusion implementation
///
/// Beautiful line chart for weight progression with gradient fill.
/// Based on UX research: line charts are universally understood for trends.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_progress_metrics.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

class WeightLineChart extends StatelessWidget {
  const WeightLineChart({
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

    final maxWeight = sets.map((s) => s.weight).reduce((a, b) => a > b ? a : b);
    final minWeight = sets.map((s) => s.weight).reduce((a, b) => a < b ? a : b);
    final padding = (maxWeight - minWeight) * 0.1;

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
          intervalType: _getIntervalType(),
          majorTickLines: const MajorTickLines(size: 0),
        ),
        primaryYAxis: NumericAxis(
          minimum: (minWeight - padding).clamp(0, double.infinity),
          maximum: maxWeight + padding,
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
          majorTickLines: const MajorTickLines(size: 0),
        ),
        tooltipBehavior: showTooltip
            ? TooltipBehavior(
                enable: true,
                color: context.colors.inverseSurface,
                textStyle: context.textTheme.bodySmall!.copyWith(
                  color: context.colors.onInverseSurface,
                ),
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
                          '${setData.weight.toStringAsFixed(1)} kg',
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
            yValueMapper: (data, _) => data.weight,
            splineType: SplineType.natural,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                context.colors.primary.withValues(alpha: 0.4),
                context.colors.primary.withValues(alpha: 0.05),
              ],
            ),
            borderColor: context.colors.primary,
            borderWidth: 3,
            animationDuration: animate ? 1500 : 0,
          ),
          SplineSeries<ExerciseSetData, DateTime>(
            dataSource: sets,
            xValueMapper: (data, _) => data.date,
            yValueMapper: (data, _) => data.weight,
            splineType: SplineType.natural,
            color: context.colors.primary,
            width: 3,
            markerSettings: MarkerSettings(
              isVisible: sets.length <= 15,
              height: 8,
              width: 8,
              borderWidth: 2,
              borderColor: context.colors.surface,
              color: context.colors.primary,
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

  DateTimeIntervalType _getIntervalType() {
    if (sets.length <= 1) return DateTimeIntervalType.days;
    final range = sets.last.date.difference(sets.first.date);
    if (range.inDays > 365) return DateTimeIntervalType.months;
    if (range.inDays > 60) return DateTimeIntervalType.days;
    return DateTimeIntervalType.auto;
  }
}
