/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/widgets/charts
/// 🎯 Feature: analytics
/// 🔧 Type: widget
///
/// Widget grafico trend volume settimanale
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/volume_chart_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/chart_data.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class VolumeTrendChart extends ConsumerWidget {
  const VolumeTrendChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartAsync = ref.watch(volumeChartProvider);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(AppIcons.trendUp, color: context.colors.primary),
                const SizedBox(width: 8),
                Text(
                  'Volume Trend', // TODO: Localize
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Ultimi 12 settimane', // TODO: Localize
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),

            // Chart
            SizedBox(
              height: 200,
              child: chartAsync.when(
                data: (series) => _buildChart(context, series),
                loading: () => Center(
                  child: CircularProgressIndicator(
                    color: context.colors.primary,
                  ),
                ),
                error: (error, stack) => Center(
                  child: Text(
                    'Errore caricamento grafico', // TODO: Localize
                    style: TextStyle(color: context.colors.error),
                  ),
                ),
              ),
            ),

            // Growth indicator
            if (chartAsync.hasValue) ...[
              const SizedBox(height: 16),
              _buildGrowthIndicator(context, chartAsync.value!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChart(BuildContext context, ChartSeries series) {
    if (series.dataPoints.isEmpty) {
      return Center(
        child: Text(
          'Nessun dato disponibile', // TODO: Localize
          style:
              TextStyle(color: context.colors.onSurface.withValues(alpha: 0.5)),
        ),
      );
    }

    // Prepara dati per fl_chart
    final spots = series.dataPoints.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();

    // Trendline spots
    final trendSpots = series.showTrendline
        ? series.trendline.asMap().entries.map((entry) {
            return FlSpot(entry.key.toDouble(), entry.value.value);
          }).toList()
        : <FlSpot>[];

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 5000,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: context.colors.onSurface.withValues(alpha: 0.1),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${(value / 1000).toStringAsFixed(0)}k',
                  style: context.textTheme.bodySmall,
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: series.dataPoints.length > 10 ? 2 : 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= series.dataPoints.length) {
                  return const SizedBox.shrink();
                }

                final date = series.dataPoints[index].date;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${date.day}/${date.month}',
                    style: context.textTheme.bodySmall,
                  ),
                );
              },
            ),
          ),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          // Main data line
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: series.color,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: series.color,
                  strokeWidth: 2,
                  strokeColor: context.colors.surface,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: series.color.withValues(alpha: 0.1),
            ),
          ),

          // Trendline
          if (trendSpots.isNotEmpty)
            LineChartBarData(
              spots: trendSpots,
              isCurved: false,
              color: series.color.withValues(alpha: 0.5),
              barWidth: 2,
              dashArray: [5, 5],
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                final date = series.dataPoints[index].date;
                return LineTooltipItem(
                  '${date.day}/${date.month}\n${spot.y.toStringAsFixed(0)} kg',
                  TextStyle(
                    color: context.colors.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGrowthIndicator(BuildContext context, ChartSeries series) {
    final growth = series.growthPercentage;
    final isPositive = growth >= 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color:
            (isPositive ? Colors.green : Colors.red).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? AppIcons.arrowUpward : AppIcons.arrowDownward,
            color: isPositive ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            '${growth.abs().toStringAsFixed(1)}%',
            style: context.textTheme.titleSmall?.copyWith(
              color: isPositive ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isPositive ? 'crescita' : 'calo', // TODO: Localize
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
