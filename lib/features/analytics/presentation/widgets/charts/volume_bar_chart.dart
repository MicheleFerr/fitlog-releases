/// Volume Bar Chart - Syncfusion implementation
///
/// Vertical bar chart for volume progression.
/// Based on UX research: bar charts are more intuitive for "quantity/amount".
///
/// **Data Aggregation**: Sets are aggregated by session (day) to prevent
/// overlapping bars when multiple sets occur on the same day.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_progress_metrics.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/usecases/aggregate_sets_by_session.dart';
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

    // Aggregate sets by session to prevent overlapping bars
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

    final maxVolume = sessions.fold<double>(
      0,
      (max, s) => s.totalVolume > max ? s.totalVolume : max,
    );

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
                            color: context.colors.onInverseSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                        Text(
                          '${_formatVolume(session.totalVolume)} kg',
                          style: context.textTheme.titleSmall?.copyWith(
                            color: context.colors.onInverseSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${session.setCount} sets',
                          style: context.textTheme.labelSmall?.copyWith(
                            color: context.colors.onInverseSurface.withValues(
                              alpha: 0.7,
                            ),
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
          ColumnSeries<SessionDataPoint, DateTime>(
            dataSource: sessions,
            xValueMapper: (data, _) => data.date,
            yValueMapper: (data, _) => data.totalVolume,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                context.colors.warning,
                context.colors.warning.withValues(alpha: 0.6),
              ],
            ),
            width: _calculateBarWidth(sessions),
            animationDuration: animate ? 1200 : 0,
            // Highlight max volume bar
            pointColorMapper: (data, index) {
              if (data.totalVolume == maxVolume) {
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

  DateFormat _getDateFormat(List<SessionDataPoint> sessions) {
    if (sessions.length <= 1) return DateFormat('d MMM');
    final range = sessions.last.date.difference(sessions.first.date);
    if (range.inDays > 180) return DateFormat('MMM');
    if (range.inDays > 30) return DateFormat('d MMM');
    return DateFormat('d');
  }

  double _calculateBarWidth(List<SessionDataPoint> sessions) {
    if (sessions.length <= 5) return 0.7;
    if (sessions.length <= 10) return 0.6;
    if (sessions.length <= 20) return 0.5;
    return 0.4;
  }
}
