import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/measurement.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/metric_type.dart';
import 'package:gymbro_flutter_new/features/body_measurements/data/repositories/measurement_repository_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:intl/intl.dart';

/// MeasurementChartsScreen - Progress charts with auto-selection and summary
class MeasurementChartsScreen extends ConsumerStatefulWidget {
  const MeasurementChartsScreen({super.key, required this.userId});

  final String userId;

  @override
  ConsumerState<MeasurementChartsScreen> createState() =>
      _MeasurementChartsScreenState();
}

/// Period for chart data filtering
enum ChartPeriod { week, month, year }

class _MeasurementChartsScreenState
    extends ConsumerState<MeasurementChartsScreen> {
  List<Measurement> _allMeasurements = [];
  List<Measurement> _filteredMeasurements = [];
  bool _isLoading = true;
  MetricType _selectedMetric = MetricType.weight;
  ChartPeriod _selectedPeriod = ChartPeriod.month;

  /// Metrics that have data (for chip display)
  Set<MetricType> _metricsWithData = {};

  @override
  void initState() {
    super.initState();
    _loadAllMeasurements();
  }

  /// Load all measurements once, then filter locally
  Future<void> _loadAllMeasurements() async {
    setState(() => _isLoading = true);

    final measurementRepo = ref.read(measurementRepositoryProvider);
    final result = await measurementRepo.getMeasurements(widget.userId);

    result.fold(
      (failure) {
        if (!mounted) return;
        SnackBarService.showError(
          context,
          context.l10n.errorLoadingData,
        );
        setState(() => _isLoading = false);
      },
      (measurements) {
        if (!mounted) return;
        _allMeasurements = measurements;

        // Discover which metrics have data
        _metricsWithData = measurements.map((m) => m.metricType).toSet();

        // Auto-select weight if available, otherwise first with data
        if (_metricsWithData.contains(MetricType.weight)) {
          _selectedMetric = MetricType.weight;
        } else if (_metricsWithData.isNotEmpty) {
          _selectedMetric = _metricsWithData.first;
        }

        _applyFilters();
        setState(() => _isLoading = false);
      },
    );
  }

  /// Apply metric and period filters to the loaded data
  void _applyFilters() {
    final now = DateTime.now();
    final DateTime dateFrom;

    switch (_selectedPeriod) {
      case ChartPeriod.week:
        dateFrom = now.subtract(const Duration(days: 7));
      case ChartPeriod.month:
        dateFrom = now.subtract(const Duration(days: 30));
      case ChartPeriod.year:
        dateFrom = now.subtract(const Duration(days: 365));
    }

    _filteredMeasurements =
        _allMeasurements
            .where(
              (m) =>
                  m.metricType == _selectedMetric &&
                  m.timestamp.isAfter(dateFrom),
            )
            .toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  void _onMetricChanged(MetricType newMetric) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedMetric = newMetric;
      _applyFilters();
    });
  }

  void _onPeriodChanged(ChartPeriod newPeriod) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedPeriod = newPeriod;
      _applyFilters();
    });
  }

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
        leading: IconButton(
          icon: const Icon(AppIcons.arrowBackIos, size: AppIconSize.medium),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        ),
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : SafeArea(
              bottom: false,
              child: Column(
                children: [
                // Period selector
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
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

                // Metric selector chips (only metrics with data)
                if (_metricsWithData.isNotEmpty)
                  SizedBox(
                    height: 48,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: _metricsWithData.map((metric) {
                        final isSelected = metric == _selectedMetric;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(_getMetricLabel(metric)),
                            selected: isSelected,
                            onSelected: (_) => _onMetricChanged(metric),
                            showCheckmark: false,
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                const SizedBox(height: 8),

                // Summary card
                if (_filteredMeasurements.isNotEmpty) _buildSummaryCard(),

                // Chart or empty state
                Expanded(
                  child: _filteredMeasurements.isEmpty
                      ? _buildEmptyState()
                      : _buildChart(),
                ),
              ],
            ),
          ),
    );
  }

  /// Summary card with current, min, max, trend
  Widget _buildSummaryCard() {
    final values = _filteredMeasurements.map((m) => m.value).toList();
    final current = _filteredMeasurements.last.value;
    final minVal = values.reduce((a, b) => a < b ? a : b);
    final maxVal = values.reduce((a, b) => a > b ? a : b);

    String? trendText;
    if (_filteredMeasurements.length >= 2) {
      final diff =
          _filteredMeasurements.last.value - _filteredMeasurements.first.value;
      final sign = diff > 0 ? '+' : '';
      trendText = '$sign${diff.toStringAsFixed(1)}';
    }

    final unit = _filteredMeasurements.last.unit;

    final items = [
      _SummaryData(
        context.l10n.bodyMeasurementsChartsSummaryCurrent,
        current.toStringAsFixed(1),
        unit,
      ),
      _SummaryData(
        context.l10n.bodyMeasurementsChartsSummaryMin,
        minVal.toStringAsFixed(1),
        unit,
      ),
      _SummaryData(
        context.l10n.bodyMeasurementsChartsSummaryMax,
        maxVal.toStringAsFixed(1),
        unit,
      ),
      if (trendText != null)
        _SummaryData(context.l10n.bodyMeasurementsChartsTrend, trendText, unit),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: items.map((item) {
            return Expanded(
              child: _buildSummaryItem(item.label, item.value, item.unit),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, String unit) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          unit,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

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

  Widget _buildChart() {
    final sortedMeasurements = _filteredMeasurements;

    final spots = sortedMeasurements.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();

    final values = sortedMeasurements.map((m) => m.value).toList();
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final range = maxValue - minValue;
    final padding = range > 0 ? range * 0.1 : 1.0;

    final bottomPadding = MediaQuery.of(context).padding.bottom + 16;

    return Padding(
      padding: EdgeInsets.fromLTRB(8, 16, 16, bottomPadding),
      child: Column(
        children: [
          // Line chart
          Expanded(
            child: RepaintBoundary(
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
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(1),
                            style: context.textTheme.labelSmall?.copyWith(
                              color: context.colors.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: spots.length > 10 ? spots.length / 5 : 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 ||
                              index >= sortedMeasurements.length) {
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
                              style: context.textTheme.labelSmall?.copyWith(
                                color: context.colors.onSurface
                                    .withValues(alpha: 0.6),
                              ),
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
                        color: context.colors.outline.withValues(alpha: 0.1),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (touchedSpot) =>
                          context.colors.primary,
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
                              color: context.colors.onPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          );
                        }).toList();
                      },
                    ),
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

/// Helper class for summary card data
class _SummaryData {
  const _SummaryData(this.label, this.value, this.unit);

  final String label;
  final String value;
  final String unit;
}
