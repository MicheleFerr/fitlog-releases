import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_progress_metrics.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/exercise_progress_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/analytics_providers.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/screens/landscape_graph_screen.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/enhanced_empty_state.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/exercise_correlations_sheet.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/training_pattern_card.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/training_pattern_provider.dart';

class ExerciseDetailScreen extends ConsumerStatefulWidget {
  const ExerciseDetailScreen({
    super.key,
    required this.exerciseName,
  });

  final String exerciseName;

  @override
  ConsumerState<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

/// Chart type enum for reorderable charts
enum ChartType { weight, volume, reps, rpe }

/// Trend data for a chart metric
class _TrendData {
  const _TrendData({
    required this.percentChange,
    required this.isPositive,
    required this.isStable,
    required this.insight,
  });

  final double percentChange;
  final bool isPositive;
  final bool isStable;
  final String insight;
}

class _ExerciseDetailScreenState extends ConsumerState<ExerciseDetailScreen> {
  TimePeriod _selectedPeriod = TimePeriod.month;

  /// Order of charts - can be reordered via drag & drop
  final List<ChartType> _chartOrder = [
    ChartType.weight,
    ChartType.volume,
    ChartType.reps,
    ChartType.rpe,
  ];

  /// Calculate trend data for a specific chart type
  _TrendData? _calculateTrendData(ChartType type, List<ExerciseSetData> sets) {
    if (sets.length < 3) return null;

    // Compare first half vs second half for trend
    final midpoint = sets.length ~/ 2;
    final firstHalf = sets.sublist(0, midpoint);
    final secondHalf = sets.sublist(midpoint);

    double firstAvg;
    double secondAvg;

    switch (type) {
      case ChartType.weight:
        firstAvg = firstHalf.fold<double>(0, (sum, s) => sum + s.weight) / firstHalf.length;
        secondAvg = secondHalf.fold<double>(0, (sum, s) => sum + s.weight) / secondHalf.length;
      case ChartType.volume:
        firstAvg = firstHalf.fold<double>(0, (sum, s) => sum + s.volume) / firstHalf.length;
        secondAvg = secondHalf.fold<double>(0, (sum, s) => sum + s.volume) / secondHalf.length;
      case ChartType.reps:
        firstAvg = firstHalf.fold<double>(0, (sum, s) => sum + s.reps) / firstHalf.length;
        secondAvg = secondHalf.fold<double>(0, (sum, s) => sum + s.reps) / secondHalf.length;
      case ChartType.rpe:
        final firstWithRpe = firstHalf.where((s) => s.rpe != null).toList();
        final secondWithRpe = secondHalf.where((s) => s.rpe != null).toList();
        if (firstWithRpe.isEmpty || secondWithRpe.isEmpty) return null;
        firstAvg = firstWithRpe.fold<double>(0, (sum, s) => sum + (s.rpe ?? 0)) / firstWithRpe.length;
        secondAvg = secondWithRpe.fold<double>(0, (sum, s) => sum + (s.rpe ?? 0)) / secondWithRpe.length;
    }

    if (firstAvg == 0) return null;

    final percentChange = ((secondAvg - firstAvg) / firstAvg) * 100;
    final absChange = percentChange.abs();
    final isStable = absChange < 2.0;
    final isPositive = percentChange > 0;
    final percentStr = absChange.toStringAsFixed(0);

    // Generate insight text based on type and trend
    String insight;
    if (isStable) {
      insight = context.l10n.analyticsInsightStable;
    } else if (type == ChartType.rpe) {
      // For RPE, interpret high/low differently
      insight = secondAvg >= 8 ? context.l10n.analyticsInsightRpeHigh :
                secondAvg <= 6 ? context.l10n.analyticsInsightRpeLow :
                context.l10n.analyticsInsightStable;
    } else {
      // Use parameterized localization functions
      insight = switch (type) {
        ChartType.weight => isPositive
            ? context.l10n.analyticsInsightWeightUp(percentStr)
            : context.l10n.analyticsInsightWeightDown(percentStr),
        ChartType.volume => isPositive
            ? context.l10n.analyticsInsightVolumeUp(percentStr)
            : context.l10n.analyticsInsightVolumeDown(percentStr),
        ChartType.reps => isPositive
            ? context.l10n.analyticsInsightRepsUp(percentStr)
            : context.l10n.analyticsInsightRepsDown(percentStr),
        ChartType.rpe => context.l10n.analyticsInsightStable, // handled above
      };
    }

    return _TrendData(
      percentChange: percentChange,
      isPositive: isPositive,
      isStable: isStable,
      insight: insight,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get userId for Firebase analytics fallback and landscape screen navigation
    final userId = ref.watch(currentUserIdProvider);

    // Try workout-based metrics first
    var metrics = ref.watch(exerciseMetricsProvider(widget.exerciseName));

    // Get Firebase analytics history (used for fallback and landscape screen)
    final historyAsync = userId != null
        ? ref.watch(exerciseHistoryByNameProvider((userId, widget.exerciseName)))
        : null;

    // If workout metrics not found, try Firebase analytics as fallback
    if (metrics == null && historyAsync != null) {
      metrics = historyAsync.whenOrNull(
        data: (history) => convertHistoryToMetrics(history),
      );
    }

    if (metrics == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.exerciseName),
        ),
        body: EnhancedEmptyState(
          type: EmptyStateType.error,
          icon: AppIcons.error,
          title: context.l10n.noDataAvailable,
          description: context.l10n.noDataForExercise,
        ),
      );
    }

    final filteredSets = metrics.getSetsInPeriod(_selectedPeriod);

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.exerciseName,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Correlations insights button
          IconButton(
            icon: SemanticIcon.button(
              icon: AppIcons.insights,
              semanticLabel: context.l10n.analyticsCorrelationsTitle,
            ),
            onPressed: () {
              ExerciseCorrelationsSheet.show(
                context,
                exerciseId: widget.exerciseName,
                exerciseName: widget.exerciseName,
              );
            },
            tooltip: context.l10n.analyticsCorrelationsTitle,
          ),
          // Fullscreen landscape button in AppBar
          if (historyAsync != null)
            historyAsync.when(
              data: (history) => IconButton(
                icon: SemanticIcon.button(
                  icon: AppIcons.fullscreen,
                  semanticLabel: context.l10n.fullscreen,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LandscapeGraphScreen(
                        exerciseName: widget.exerciseName,
                        history: history,
                      ),
                    ),
                  );
                },
                tooltip: context.l10n.fullscreen,
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Fixed header content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                children: [
                  // Period selector
                  _buildPeriodSelector(),
                  const SizedBox(height: 16),

                  // Stats summary
                  _buildStatsSummary(metrics, filteredSets),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // Training Pattern Cards (Decision Narrative - above charts)
          // Based on UX research 2024-2025: Insights prominently visible BEFORE detailed data
          SliverToBoxAdapter(
            child: _buildPatternCards(),
          ),

          // Drag hint and charts header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                children: [
                  // Drag hint
                  Row(
                    children: [
                      Icon(
                        AppIcons.dragHandle,
                        size: AppIconSize.small,
                        color: context.colors.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        context.l10n.dragToReorder,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant.withValues(alpha: 0.7),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // Reorderable charts
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverReorderableList(
              itemBuilder: (context, index) {
                final chartType = _chartOrder[index];
                // Skip RPE if no data
                if (chartType == ChartType.rpe && !filteredSets.any((s) => s.rpe != null)) {
                  return const SizedBox.shrink(key: ValueKey('rpe_empty'));
                }
                return _buildReorderableChartCard(
                  key: ValueKey(chartType),
                  index: index,
                  chartType: chartType,
                  sets: filteredSets,
                );
              },
              itemCount: _chartOrder.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final item = _chartOrder.removeAt(oldIndex);
                  _chartOrder.insert(newIndex, item);
                });
              },
            ),
          ),

          // Session history
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildSessionHistory(filteredSets),
            ),
          ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  /// Build a reorderable chart card with drag handle, trend badge, and insight
  Widget _buildReorderableChartCard({
    required Key key,
    required int index,
    required ChartType chartType,
    required List<ExerciseSetData> sets,
  }) {
    final (title, icon, color, chart) = _getChartData(chartType, sets);
    final trendData = _calculateTrendData(chartType, sets);

    return ReorderableDelayedDragStartListener(
      key: key,
      index: index,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title and trend badge
                Row(
                  children: [
                    // Drag handle
                    Icon(
                      AppIcons.dragHandle,
                      color: context.colors.onSurfaceVariant.withValues(alpha: 0.4),
                      size: AppIconSize.medium,
                    ),
                    const SizedBox(width: 8),
                    Icon(icon, color: color, size: AppIconSize.medium),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Trend badge
                    if (trendData != null) _buildTrendBadge(trendData, chartType),
                  ],
                ),
                const SizedBox(height: 16),
                // Chart
                chart,
                // Dynamic insight
                if (trendData != null) ...[
                  const SizedBox(height: 12),
                  _buildInsightRow(trendData, color),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build trend badge showing percentage change
  Widget _buildTrendBadge(_TrendData trend, ChartType type) {
    // For RPE, interpret trend differently (lower can be good)
    final bool isGood;
    if (type == ChartType.rpe) {
      isGood = !trend.isPositive || trend.isStable; // Lower RPE or stable is good
    } else {
      isGood = trend.isPositive || trend.isStable; // Higher or stable is good
    }

    final bgColor = trend.isStable
        ? context.colors.surfaceContainerHighest
        : isGood
            ? context.colors.success.withValues(alpha: 0.15)
            : context.colors.error.withValues(alpha: 0.15);

    final textColor = trend.isStable
        ? context.colors.onSurfaceVariant
        : isGood
            ? context.colors.success
            : context.colors.error;

    final icon = trend.isStable
        ? AppIcons.trendFlat
        : trend.isPositive
            ? AppIcons.trendUp
            : AppIcons.trendDown;

    final text = trend.isStable
        ? context.l10n.analyticsTrendBadgeStable
        : trend.isPositive
            ? context.l10n.analyticsTrendBadgeUp(trend.percentChange.abs().toStringAsFixed(1))
            : context.l10n.analyticsTrendBadgeDown(trend.percentChange.toStringAsFixed(1));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: context.textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Build insight row with icon and text
  Widget _buildInsightRow(_TrendData trend, Color chartColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: chartColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: chartColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            AppIcons.lightbulb,
            size: AppIconSize.small,
            color: chartColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              trend.insight,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.8),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Get chart data (title, icon, color, widget) for a chart type
  (String, IconData, Color, Widget) _getChartData(ChartType type, List<ExerciseSetData> sets) {
    switch (type) {
      case ChartType.weight:
        return (
          context.l10n.weightProgression,
          AppIcons.workout,
          context.colors.primary,
          _buildWeightChart(sets),
        );
      case ChartType.volume:
        return (
          context.l10n.volumeProgression,
          AppIcons.analytics,
          context.colors.warning,
          _buildVolumeChart(sets),
        );
      case ChartType.reps:
        return (
          context.l10n.repsProgression,
          AppIcons.repeat,
          context.colors.success,
          _buildRepsChart(sets),
        );
      case ChartType.rpe:
        return (
          context.l10n.effortProgression,
          AppIcons.speed,
          context.colors.error,
          _buildRPEChart(sets),
        );
    }
  }

  Widget _buildPeriodSelector() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: context.colors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildPeriodButton(context.l10n.week, TimePeriod.week),
          _buildPeriodButton(context.l10n.month, TimePeriod.month),
          _buildPeriodButton('3M', TimePeriod.threeMonths),
          _buildPeriodButton(context.l10n.year, TimePeriod.year),
          _buildPeriodButton(context.l10n.all, TimePeriod.all),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String label, TimePeriod period) {
    final isSelected = _selectedPeriod == period;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriod = period),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? context.colors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: context.textTheme.labelLarge?.copyWith(
                color: isSelected ? context.colors.onPrimary : context.colors.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Helper to format date for X-axis labels based on data range
  String _formatDateLabel(DateTime date, Duration range) {
    if (range.inDays > 180) {
      // More than 6 months: show month/year
      return DateFormat('MMM yy').format(date);
    } else if (range.inDays > 30) {
      // More than a month: show day/month
      return DateFormat('d MMM').format(date);
    } else {
      // Less than a month: show day
      return DateFormat('d').format(date);
    }
  }

  /// Get date range from sets
  Duration _getDateRange(List<ExerciseSetData> sets) {
    if (sets.isEmpty) return Duration.zero;
    return sets.last.date.difference(sets.first.date);
  }

  /// Calculate X-axis interval based on number of data points
  int _calculateLabelInterval(int dataLength) {
    if (dataLength <= 5) return 1;
    if (dataLength <= 10) return 2;
    if (dataLength <= 20) return 4;
    return (dataLength / 5).ceil();
  }

  Widget _buildStatsSummary(ExerciseProgressMetrics metrics, List<ExerciseSetData> sets) {
    final periodMaxWeight = sets.isNotEmpty
        ? sets.fold<double>(0, (max, set) => set.weight > max ? set.weight : max)
        : 0.0;

    final periodAvgWeight = sets.isNotEmpty
        ? sets.fold<double>(0, (sum, set) => sum + set.weight) / sets.length
        : 0.0;

    final periodAvgReps = sets.isNotEmpty
        ? sets.fold<double>(0, (sum, set) => sum + set.reps) / sets.length
        : 0.0;

    final setsWithRPE = sets.where((s) => s.rpe != null).toList();
    final periodAvgRPE = setsWithRPE.isNotEmpty
        ? setsWithRPE.fold<double>(0, (sum, set) => sum + (set.rpe ?? 0)) / setsWithRPE.length
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.colors.primary.withValues(alpha: 0.1),
            context.colors.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.exerciseStats,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                context.l10n.personalRecord,
                '${periodMaxWeight.toStringAsFixed(1)} kg',
                AppIcons.achievement,
                context.colors.warning,
              ),
              _buildStatItem(
                context.l10n.averageWeight,
                '${periodAvgWeight.toStringAsFixed(1)} kg',
                AppIcons.workout,
                context.colors.primary,
              ),
              _buildStatItem(
                context.l10n.avgReps,
                periodAvgReps.toStringAsFixed(0),
                AppIcons.repeat,
                context.colors.success,
              ),
              if (periodAvgRPE > 0)
                _buildStatItem(
                  context.l10n.averageRPE,
                  periodAvgRPE.toStringAsFixed(1),
                  AppIcons.speed,
                  context.colors.secondary,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: AppIconSize.medium),
        const SizedBox(height: 4),
        Text(
          value,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildWeightChart(List<ExerciseSetData> sets) {
    if (sets.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(child: Text(context.l10n.noDataForChart)),
      );
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < sets.length; i++) {
      spots.add(FlSpot(i.toDouble(), sets[i].weight));
    }

    final maxWeight = sets.map((s) => s.weight).reduce((a, b) => a > b ? a : b);
    final minWeight = sets.map((s) => s.weight).reduce((a, b) => a < b ? a : b);
    final dateRange = _getDateRange(sets);
    final labelInterval = _calculateLabelInterval(sets.length);

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          minY: (minWeight * 0.9).floorToDouble(),
          maxY: (maxWeight * 1.1).ceilToDouble(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: ((maxWeight - minWeight) / 4).clamp(5, 50),
            getDrawingHorizontalLine: (value) => FlLine(
              color: context.colors.outline.withValues(alpha: 0.15),
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 45,
                getTitlesWidget: (value, meta) {
                  if (value == meta.min || value == meta.max) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(
                      '${value.toInt()} kg',
                      style: context.textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: context.colors.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: labelInterval.toDouble(),
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= sets.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      _formatDateLabel(sets[index].date, dateRange),
                      style: context.textTheme.bodySmall?.copyWith(
                        fontSize: 9,
                        color: context.colors.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipMargin: 50,
              showOnTopOfTheChartBoxArea: true,
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipItems: (spots) {
                return spots.map((spot) {
                  final index = spot.x.toInt();
                  final date = index < sets.length
                      ? DateFormat('d MMM').format(sets[index].date)
                      : '';
                  return LineTooltipItem(
                    '$date\n${spot.y.toStringAsFixed(1)} kg',
                    TextStyle(
                      color: context.colors.onPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.3,
              preventCurveOverShooting: true,
              color: context.colors.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 4,
                  color: context.colors.primary,
                  strokeWidth: 2,
                  strokeColor: context.colors.surface,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    context.colors.primary.withValues(alpha: 0.3),
                    context.colors.primary.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
        transformationConfig: const FlTransformationConfig(
          scaleAxis: FlScaleAxis.horizontal,
          minScale: 1.0,
          maxScale: 5.0,
          panEnabled: true,
          scaleEnabled: true,
        ),
      ),
    );
  }

  Widget _buildVolumeChart(List<ExerciseSetData> sets) {
    if (sets.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(child: Text(context.l10n.noDataForChart)),
      );
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < sets.length; i++) {
      spots.add(FlSpot(i.toDouble(), sets[i].volume));
    }

    final maxVolume = sets.map((s) => s.volume).reduce((a, b) => a > b ? a : b);
    final minVolume = sets.map((s) => s.volume).reduce((a, b) => a < b ? a : b);
    final dateRange = _getDateRange(sets);
    final labelInterval = _calculateLabelInterval(sets.length);

    // Format volume (e.g., 1500 -> 1.5k)
    String formatVolume(double value) {
      if (value >= 1000) {
        return '${(value / 1000).toStringAsFixed(1)}k';
      }
      return value.toInt().toString();
    }

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          minY: (minVolume * 0.9).floorToDouble(),
          maxY: (maxVolume * 1.1).ceilToDouble(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: ((maxVolume - minVolume) / 4).clamp(100, 5000),
            getDrawingHorizontalLine: (value) => FlLine(
              color: context.colors.outline.withValues(alpha: 0.15),
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 45,
                getTitlesWidget: (value, meta) {
                  if (value == meta.min || value == meta.max) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(
                      formatVolume(value),
                      style: context.textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: context.colors.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: labelInterval.toDouble(),
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= sets.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      _formatDateLabel(sets[index].date, dateRange),
                      style: context.textTheme.bodySmall?.copyWith(
                        fontSize: 9,
                        color: context.colors.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipMargin: 50,
              showOnTopOfTheChartBoxArea: true,
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipItems: (spots) {
                return spots.map((spot) {
                  final index = spot.x.toInt();
                  final date = index < sets.length
                      ? DateFormat('d MMM').format(sets[index].date)
                      : '';
                  return LineTooltipItem(
                    '$date\n${formatVolume(spot.y)}',
                    TextStyle(
                      color: context.colors.onSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.3,
              preventCurveOverShooting: true,
              color: context.colors.secondary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 4,
                  color: context.colors.secondary,
                  strokeWidth: 2,
                  strokeColor: context.colors.surface,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    context.colors.secondary.withValues(alpha: 0.3),
                    context.colors.secondary.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
        transformationConfig: const FlTransformationConfig(
          scaleAxis: FlScaleAxis.horizontal,
          minScale: 1.0,
          maxScale: 5.0,
          panEnabled: true,
          scaleEnabled: true,
        ),
      ),
    );
  }

  Widget _buildRepsChart(List<ExerciseSetData> sets) {
    if (sets.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(child: Text(context.l10n.noDataForChart)),
      );
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < sets.length; i++) {
      spots.add(FlSpot(i.toDouble(), sets[i].reps.toDouble()));
    }

    final maxReps = sets.map((s) => s.reps.toDouble()).reduce((a, b) => a > b ? a : b);
    final minReps = sets.map((s) => s.reps.toDouble()).reduce((a, b) => a < b ? a : b);
    final dateRange = _getDateRange(sets);
    final labelInterval = _calculateLabelInterval(sets.length);

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          minY: (minReps - 2).clamp(0, double.infinity),
          maxY: maxReps + 2,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: ((maxReps - minReps) / 4).clamp(1, 10),
            getDrawingHorizontalLine: (value) => FlLine(
              color: context.colors.outline.withValues(alpha: 0.15),
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 35,
                getTitlesWidget: (value, meta) {
                  if (value == meta.min || value == meta.max) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(
                      '${value.toInt()}',
                      style: context.textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: context.colors.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: labelInterval.toDouble(),
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= sets.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      _formatDateLabel(sets[index].date, dateRange),
                      style: context.textTheme.bodySmall?.copyWith(
                        fontSize: 9,
                        color: context.colors.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipMargin: 50,
              showOnTopOfTheChartBoxArea: true,
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipItems: (spots) {
                return spots.map((spot) {
                  final index = spot.x.toInt();
                  final date = index < sets.length
                      ? DateFormat('d MMM').format(sets[index].date)
                      : '';
                  return LineTooltipItem(
                    '$date\n${spot.y.toInt()} reps',
                    TextStyle(
                      color: context.colors.onPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.3,
              preventCurveOverShooting: true,
              color: context.colors.success,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 4,
                  color: context.colors.success,
                  strokeWidth: 2,
                  strokeColor: context.colors.surface,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    context.colors.success.withValues(alpha: 0.3),
                    context.colors.success.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
        transformationConfig: const FlTransformationConfig(
          scaleAxis: FlScaleAxis.horizontal,
          minScale: 1.0,
          maxScale: 5.0,
          panEnabled: true,
          scaleEnabled: true,
        ),
      ),
    );
  }

  Widget _buildRPEChart(List<ExerciseSetData> sets) {
    final setsWithRPE = sets.where((s) => s.rpe != null).toList();

    if (setsWithRPE.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(child: Text(context.l10n.noDataForChart)),
      );
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < setsWithRPE.length; i++) {
      spots.add(FlSpot(i.toDouble(), setsWithRPE[i].rpe!.toDouble()));
    }

    final dateRange = _getDateRange(setsWithRPE);
    final labelInterval = _calculateLabelInterval(setsWithRPE.length);

    // Get RPE label based on value
    String getRpeLabel(int rpe) {
      if (rpe >= 10) return 'Max';
      if (rpe >= 9) return 'Hard';
      if (rpe >= 7) return 'Mod';
      return 'Easy';
    }

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 10,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 2,
            getDrawingHorizontalLine: (value) => FlLine(
              color: context.colors.outline.withValues(alpha: 0.15),
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 2,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  if (value == 0 || value == 10) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(
                      value.toInt().toString(),
                      style: context.textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: context.colors.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: labelInterval.toDouble(),
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= setsWithRPE.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      _formatDateLabel(setsWithRPE[index].date, dateRange),
                      style: context.textTheme.bodySmall?.copyWith(
                        fontSize: 9,
                        color: context.colors.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipMargin: 50,
              showOnTopOfTheChartBoxArea: true,
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipItems: (spots) {
                return spots.map((spot) {
                  final index = spot.x.toInt();
                  final date = index < setsWithRPE.length
                      ? DateFormat('d MMM').format(setsWithRPE[index].date)
                      : '';
                  final rpeValue = spot.y.toInt();
                  return LineTooltipItem(
                    '$date\nRPE $rpeValue (${getRpeLabel(rpeValue)})',
                    TextStyle(
                      color: context.colors.onPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.3,
              preventCurveOverShooting: true,
              gradient: LinearGradient(
                colors: [context.colors.success, context.colors.secondary, context.colors.error],
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  final rpe = spot.y;
                  final color = rpe >= 9
                      ? context.colors.error
                      : rpe >= 7
                          ? context.colors.secondary
                          : context.colors.success;
                  return FlDotCirclePainter(
                    radius: 4,
                    color: color,
                    strokeWidth: 2,
                    strokeColor: context.colors.surface,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    context.colors.tertiary.withValues(alpha: 0.2),
                    context.colors.tertiary.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
        transformationConfig: const FlTransformationConfig(
          scaleAxis: FlScaleAxis.horizontal,
          minScale: 1.0,
          maxScale: 5.0,
          panEnabled: true,
          scaleEnabled: true,
        ),
      ),
    );
  }

  Widget _buildSessionHistory(List<ExerciseSetData> sets) {
    if (sets.isEmpty) return const SizedBox.shrink();

    // Group by date
    final Map<String, List<ExerciseSetData>> sessionsByDate = {};
    for (final set in sets) {
      final dateKey = DateFormat('yyyy-MM-dd').format(set.date);
      sessionsByDate.putIfAbsent(dateKey, () => []).add(set);
    }

    // Sort by date descending
    final sortedDates = sessionsByDate.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.sessionHistory,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...sortedDates.take(5).map((dateKey) {
              final sessionSets = sessionsByDate[dateKey]!;
              final date = DateTime.parse(dateKey);

              return _buildSessionItem(date, sessionSets);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionItem(DateTime date, List<ExerciseSetData> sets) {
    final maxWeight = sets.fold<double>(0, (max, set) => set.weight > max ? set.weight : max);
    final totalVolume = sets.fold<double>(0, (sum, set) => sum + set.volume);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.colors.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.colors.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                AppIcons.calendar,
                color: context.colors.primary,
                size: AppIconSize.small,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEEE, MMM d, yyyy').format(date),
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${sets.length} sets • ${maxWeight.toStringAsFixed(1)} kg max',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${(totalVolume / 1000).toStringAsFixed(1)}k kg',
              style: context.textTheme.titleSmall?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build training pattern cards section
  ///
  /// Shows detected training patterns prominently ABOVE charts,
  /// following the "Decision Narrative" UX pattern from Nielsen Norman 2024.
  Widget _buildPatternCards() {
    // Watch the pattern provider for this exercise
    final patternsAsync = ref.watch(trainingPatternProvider(widget.exerciseName));

    return patternsAsync.when(
      data: (results) {
        // Don't show anything if no patterns detected
        if (!results.hasPatterns) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
          child: TrainingPatternsList(
            results: results,
            maxPatterns: 2, // Show max 2 patterns to avoid overwhelming
            warningsOnly: false, // Show all high-priority patterns
          ),
        );
      },
      loading: () => const SizedBox.shrink(), // Don't show loading indicator
      error: (_, __) => const SizedBox.shrink(), // Fail silently
    );
  }
}
