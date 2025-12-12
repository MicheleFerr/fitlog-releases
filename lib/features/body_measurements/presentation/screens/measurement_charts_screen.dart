import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/measurement.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/metric_type.dart';
import 'package:gymbro_flutter_new/features/body_measurements/data/repositories/measurement_repository_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:intl/intl.dart';

/// MeasurementChartsScreen - Display progress charts for body measurements
///
/// **Features**:
/// - Line charts showing measurement trends over time
/// - Period selector (week/month/year)
/// - Metric selector dropdown (weight, body fat, circumferences, etc.)
/// - Empty state when no data for selected metric
/// - Theme-aware chart colors
/// - Fully localized (EN/IT)
///
/// **Usage**:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (_) => MeasurementChartsScreen(userId: currentUser.uid),
///   ),
/// );
/// ```
class MeasurementChartsScreen extends ConsumerStatefulWidget {
  const MeasurementChartsScreen({
    super.key,
    required this.userId,
  });

  final String userId;

  @override
  ConsumerState<MeasurementChartsScreen> createState() =>
      _MeasurementChartsScreenState();
}

/// Period for chart data filtering
enum ChartPeriod {
  week,
  month,
  year;
}

class _MeasurementChartsScreenState
    extends ConsumerState<MeasurementChartsScreen> {
  List<Measurement> _measurements = [];
  bool _isLoading = true;
  MetricType? _selectedMetric;
  ChartPeriod _selectedPeriod = ChartPeriod.month;

  @override
  void initState() {
    super.initState();
    _loadMeasurements();
  }

  /// Load measurements from repository
  Future<void> _loadMeasurements() async {
    setState(() {
      _isLoading = true;
    });

    final measurementRepo = ref.read(measurementRepositoryProvider);

    // Calculate date range based on selected period
    final now = DateTime.now();
    DateTime dateFrom;

    switch (_selectedPeriod) {
      case ChartPeriod.week:
        dateFrom = now.subtract(const Duration(days: 7));
        break;
      case ChartPeriod.month:
        dateFrom = now.subtract(const Duration(days: 30));
        break;
      case ChartPeriod.year:
        dateFrom = now.subtract(const Duration(days: 365));
        break;
    }

    final result = await measurementRepo.getMeasurements(
      widget.userId,
      filterByType: _selectedMetric,
      dateFrom: dateFrom,
    );

    result.fold(
      (failure) {
        if (!mounted) return;
        SnackBarService.showError(
          context,
          'Failed to load measurements: $failure',
        );
        setState(() {
          _isLoading = false;
        });
      },
      (measurements) {
        if (!mounted) return;
        setState(() {
          _measurements = measurements;
          _isLoading = false;
        });
      },
    );
  }

  /// Handle metric selection change
  void _onMetricChanged(MetricType? newMetric) {
    setState(() {
      _selectedMetric = newMetric;
    });
    _loadMeasurements();
  }

  /// Handle period selection change
  void _onPeriodChanged(ChartPeriod newPeriod) {
    setState(() {
      _selectedPeriod = newPeriod;
    });
    _loadMeasurements();
  }

  /// Get localized label for metric type
  String _getMetricLabel(MetricType metric) {
    switch (metric) {
      case MetricType.weight:
        return context.l10n.bodyMeasurementsMetricWeight;
      case MetricType.height:
        return context.l10n.bodyMeasurementsMetricHeight;
      case MetricType.bodyFatPercentage:
        return context.l10n.bodyMeasurementsMetricBodyFat;
      case MetricType.leanMass:
        return context.l10n.bodyMeasurementsMetricLeanMass;
      case MetricType.bmi:
        return context.l10n.bodyMeasurementsMetricBMI;
      case MetricType.bmr:
        return context.l10n.bodyMeasurementsMetricBMR;
      case MetricType.neckCircumference:
        return context.l10n.bodyMeasurementsMetricNeckCircumference;
      case MetricType.shoulderCircumference:
        return context.l10n.bodyMeasurementsMetricShoulderCircumference;
      case MetricType.chestCircumference:
        return context.l10n.bodyMeasurementsMetricChestCircumference;
      case MetricType.waistCircumference:
        return context.l10n.bodyMeasurementsMetricWaistCircumference;
      case MetricType.abdomenCircumference:
        return context.l10n.bodyMeasurementsMetricAbdomenCircumference;
      case MetricType.hipCircumference:
        return context.l10n.bodyMeasurementsMetricHipCircumference;
      case MetricType.bicepLeftCircumference:
        return context.l10n.bodyMeasurementsMetricBicepLeftCircumference;
      case MetricType.bicepRightCircumference:
        return context.l10n.bodyMeasurementsMetricBicepRightCircumference;
      case MetricType.forearmLeftCircumference:
        return context.l10n.bodyMeasurementsMetricForearmLeftCircumference;
      case MetricType.forearmRightCircumference:
        return context.l10n.bodyMeasurementsMetricForearmRightCircumference;
      case MetricType.thighLeftCircumference:
        return context.l10n.bodyMeasurementsMetricThighLeftCircumference;
      case MetricType.thighRightCircumference:
        return context.l10n.bodyMeasurementsMetricThighRightCircumference;
      case MetricType.calfLeftCircumference:
        return context.l10n.bodyMeasurementsMetricCalfLeftCircumference;
      case MetricType.calfRightCircumference:
        return context.l10n.bodyMeasurementsMetricCalfRightCircumference;
      case MetricType.bodyTemperature:
        return context.l10n.bodyMeasurementsMetricBodyTemperature;
      case MetricType.waterMass:
        return context.l10n.bodyMeasurementsMetricWaterMass;
      case MetricType.boneMass:
        return context.l10n.bodyMeasurementsMetricBoneMass;
    }
  }

  /// Get localized label for period
  String _getPeriodLabel(ChartPeriod period) {
    switch (period) {
      case ChartPeriod.week:
        return context.l10n.bodyMeasurementsChartsPeriodWeek;
      case ChartPeriod.month:
        return context.l10n.bodyMeasurementsChartsPeriodMonth;
      case ChartPeriod.year:
        return context.l10n.bodyMeasurementsChartsPeriodYear;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.bodyMeasurementsChartsTitle),
        actions: [
          // Metric selector dropdown
          PopupMenuButton<MetricType?>(
            icon: const Icon(AppIcons.straighten),
            tooltip: context.l10n.bodyMeasurementsListFilterByMetric,
            onSelected: _onMetricChanged,
            itemBuilder: (context) {
              return MetricType.values.map((metric) {
                return PopupMenuItem<MetricType?>(
                  value: metric,
                  child: Row(
                    children: [
                      if (_selectedMetric == metric)
                        Icon(
                          AppIcons.check,
                          color: context.colors.primary,
                          size: 20,
                        ),
                      if (_selectedMetric == metric) const SizedBox(width: 8),
                      Expanded(
                        child: Text(_getMetricLabel(metric)),
                      ),
                    ],
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Period selector
          Container(
            padding: const EdgeInsets.all(16),
            child: SegmentedButton<ChartPeriod>(
              segments: [
                ButtonSegment(
                  value: ChartPeriod.week,
                  label: Text(_getPeriodLabel(ChartPeriod.week)),
                ),
                ButtonSegment(
                  value: ChartPeriod.month,
                  label: Text(_getPeriodLabel(ChartPeriod.month)),
                ),
                ButtonSegment(
                  value: ChartPeriod.year,
                  label: Text(_getPeriodLabel(ChartPeriod.year)),
                ),
              ],
              selected: {_selectedPeriod},
              onSelectionChanged: (Set<ChartPeriod> newSelection) {
                _onPeriodChanged(newSelection.first);
              },
            ),
          ),

          // Chart or empty state
          Expanded(
            child: _isLoading
                ? const Center(child: LoadingIndicator())
                : _selectedMetric == null
                    ? _buildSelectMetricState()
                    : _measurements.isEmpty
                        ? _buildEmptyState()
                        : _buildChart(),
          ),
        ],
      ),
    );
  }

  /// Build "select metric" state
  Widget _buildSelectMetricState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.straighten,
              size: 80,
              color: context.colors.onSurfaceVariant,
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.bodyMeasurementsChartsSelectMetric,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build empty state when no measurements for selected metric
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.lineChart,
              size: 80,
              color: context.colors.onSurfaceVariant,
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.bodyMeasurementsChartsEmpty,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build line chart
  Widget _buildChart() {
    // Sort measurements by date ascending
    final sortedMeasurements = List<Measurement>.from(_measurements)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Create data points for chart
    final spots = sortedMeasurements.asMap().entries.map((entry) {
      final index = entry.key;
      final measurement = entry.value;
      return FlSpot(index.toDouble(), measurement.value);
    }).toList();

    // Calculate min/max values for Y axis
    final values = sortedMeasurements.map((m) => m.value).toList();
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final padding = (maxValue - minValue) * 0.1;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Chart title with current metric and unit
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _selectedMetric != null
                      ? _getMetricLabel(_selectedMetric!)
                      : '',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_selectedMetric != null) const SizedBox(width: 8),
                if (_selectedMetric != null)
                  Text(
                    '(${_selectedMetric!.defaultUnit})',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),

          // Line chart
          Expanded(
            child: LineChart(
              LineChartData(
                minY: minValue - padding,
                maxY: maxValue + padding,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: context.colors.primary,
                    barWidth: 3,
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
                      color: context.colors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                ],
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    axisNameWidget: Text(
                      context.l10n.bodyMeasurementsChartsAxisValue,
                      style: context.textTheme.bodySmall,
                    ),
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(1),
                          style: context.textTheme.bodySmall,
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    axisNameWidget: Text(
                      context.l10n.bodyMeasurementsChartsAxisDate,
                      style: context.textTheme.bodySmall,
                    ),
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: spots.length > 10 ? spots.length / 5 : 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= sortedMeasurements.length) {
                          return const SizedBox.shrink();
                        }

                        final date = sortedMeasurements[index].timestamp;
                        final formatter = DateFormat.MMMd(
                          Localizations.localeOf(context).toString(),
                        );

                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            formatter.format(date),
                            style: context.textTheme.bodySmall,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: context.colors.outlineVariant,
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: context.colors.outlineVariant,
                    width: 1,
                  ),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) =>
                        context.colors.surfaceContainerHighest,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((LineBarSpot touchedSpot) {
                        final index = touchedSpot.x.toInt();
                        if (index < 0 ||
                            index >= sortedMeasurements.length) {
                          return null;
                        }

                        final measurement = sortedMeasurements[index];
                        final dateFormatter = DateFormat.yMd(
                          Localizations.localeOf(context).toString(),
                        );

                        return LineTooltipItem(
                          '${dateFormatter.format(measurement.timestamp)}\n${measurement.value.toStringAsFixed(1)} ${measurement.unit}',
                          TextStyle(
                            color: context.colors.onSurface,
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
