import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_progress_metrics.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/exercise_progress_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/analytics_providers.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/screens/landscape_graph_screen.dart';
import 'package:gymbro_flutter_new/shared/auth/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/enhanced_empty_state.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_border_radius.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/exercise_correlations_sheet.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/training_pattern_card.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/training_pattern_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/user_exercise_preferences_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/terminology_tooltip.dart';
// Syncfusion charts (2026-01-18 redesign)
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/charts/weight_line_chart.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/charts/volume_bar_chart.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/charts/reps_line_chart.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/charts/rpe_gauge_widget.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';

class ExerciseDetailScreen extends ConsumerStatefulWidget {
  const ExerciseDetailScreen({
    super.key,
    required this.exerciseName,
    this.exerciseId,
  });

  final String exerciseName;
  final String? exerciseId;

  @override
  ConsumerState<ExerciseDetailScreen> createState() =>
      _ExerciseDetailScreenState();
}

/// Chart type enum for segmented button
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
  ChartType _selectedChartType = ChartType.weight;

  /// Calculate trend data for a specific chart type
  _TrendData? _calculateTrendData(ChartType type, List<ExerciseSetData> sets) {
    if (sets.length < 3) return null;

    final midpoint = sets.length ~/ 2;
    final firstHalf = sets.sublist(0, midpoint);
    final secondHalf = sets.sublist(midpoint);

    double firstAvg;
    double secondAvg;

    switch (type) {
      case ChartType.weight:
        firstAvg =
            firstHalf.fold<double>(0, (sum, s) => sum + s.weight) /
            firstHalf.length;
        secondAvg =
            secondHalf.fold<double>(0, (sum, s) => sum + s.weight) /
            secondHalf.length;
      case ChartType.volume:
        firstAvg =
            firstHalf.fold<double>(0, (sum, s) => sum + s.volume) /
            firstHalf.length;
        secondAvg =
            secondHalf.fold<double>(0, (sum, s) => sum + s.volume) /
            secondHalf.length;
      case ChartType.reps:
        firstAvg =
            firstHalf.fold<double>(0, (sum, s) => sum + s.reps) /
            firstHalf.length;
        secondAvg =
            secondHalf.fold<double>(0, (sum, s) => sum + s.reps) /
            secondHalf.length;
      case ChartType.rpe:
        final firstWithRpe = firstHalf.where((s) => s.rpe != null).toList();
        final secondWithRpe = secondHalf.where((s) => s.rpe != null).toList();
        if (firstWithRpe.isEmpty || secondWithRpe.isEmpty) return null;
        firstAvg =
            firstWithRpe.fold<double>(0, (sum, s) => sum + (s.rpe ?? 0)) /
            firstWithRpe.length;
        secondAvg =
            secondWithRpe.fold<double>(0, (sum, s) => sum + (s.rpe ?? 0)) /
            secondWithRpe.length;
    }

    if (firstAvg == 0) return null;

    final percentChange = ((secondAvg - firstAvg) / firstAvg) * 100;
    final absChange = percentChange.abs();
    final isStable = absChange < 2.0;
    final isPositive = percentChange > 0;
    final percentStr = absChange.toStringAsFixed(0);

    String insight;
    if (isStable) {
      insight = context.l10n.analyticsInsightStable;
    } else if (type == ChartType.rpe) {
      insight = secondAvg >= 8
          ? context.l10n.analyticsInsightRpeHigh
          : secondAvg <= 6
          ? context.l10n.analyticsInsightRpeLow
          : context.l10n.analyticsInsightStable;
    } else {
      insight = switch (type) {
        ChartType.weight =>
          isPositive
              ? context.l10n.analyticsInsightWeightUp(percentStr)
              : context.l10n.analyticsInsightWeightDown(percentStr),
        ChartType.volume =>
          isPositive
              ? context.l10n.analyticsInsightVolumeUp(percentStr)
              : context.l10n.analyticsInsightVolumeDown(percentStr),
        ChartType.reps =>
          isPositive
              ? context.l10n.analyticsInsightRepsUp(percentStr)
              : context.l10n.analyticsInsightRepsDown(percentStr),
        ChartType.rpe => context.l10n.analyticsInsightStable,
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
    final userId = ref.watch(currentUserIdProvider);

    var metrics = ref.watch(exerciseMetricsProvider(widget.exerciseName));

    final historyAsync = userId != null
        ? ref.watch(
            exerciseHistoryByNameProvider((userId, widget.exerciseName)),
          )
        : null;

    if (metrics == null && historyAsync != null) {
      metrics = historyAsync.whenOrNull(
        data: (history) => convertHistoryToMetrics(history),
      );
    }

    if (metrics == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.exerciseName)),
        body: EnhancedEmptyState(
          type: EmptyStateType.error,
          icon: AppIcons.error,
          title: context.l10n.noDataAvailable,
          description: context.l10n.noDataForExercise,
        ),
      );
    }

    final filteredSets = metrics.getSetsInPeriod(_selectedPeriod);
    final hasRpeData = filteredSets.any((s) => s.rpe != null);

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        surfaceTintColor: context.colors.surface.withValues(alpha: 0),
        elevation: 0,
        title: Text(
          widget.exerciseName,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.md, AppSpacing.md, 0,
              ),
              child: Column(
                children: [
                  // Card 1: Trend
                  _buildTrendCard(filteredSets, hasRpeData),
                  const SizedBox(height: AppSpacing.md),

                  // Card 2: Performance
                  _buildPerformanceCard(metrics, filteredSets),
                  const SizedBox(height: AppSpacing.md),

                  // Card 3: History
                  _buildHistoryCard(filteredSets),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
          const SliverTabBarBottomPadding(),
        ],
      ),
    );
  }

  // ==========================================================================
  // CARD 1: Trend Card
  // ==========================================================================

  Widget _buildTrendCard(List<ExerciseSetData> filteredSets, bool hasRpeData) {
    final trendData = _calculateTrendData(_selectedChartType, filteredSets);
    final (_, _, chartColor, chart) = _getChartData(_selectedChartType, filteredSets);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.mdRadius),
      child: Padding(
        padding: AppSpacing.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(AppIcons.barChart, color: context.colors.primary),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  context.l10n.chartTrend,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.onSurface,
                  ),
                ),
                const Spacer(),
                if (trendData != null)
                  _buildTrendBadge(trendData, _selectedChartType),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Period selector
            _buildPeriodSelector(),
            const SizedBox(height: AppSpacing.md),

            // Quick Answer Banner
            _buildQuickAnswerBanner(filteredSets),

            // SegmentedButton for chart type
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<ChartType>(
                segments: [
                  ButtonSegment(
                    value: ChartType.weight,
                    label: Text(context.l10n.weight),
                  ),
                  ButtonSegment(
                    value: ChartType.volume,
                    label: Text(context.l10n.volume),
                  ),
                  ButtonSegment(
                    value: ChartType.reps,
                    label: Text(context.l10n.reps),
                  ),
                  if (hasRpeData)
                    ButtonSegment(
                      value: ChartType.rpe,
                      label: Text(context.l10n.rpe),
                    ),
                ],
                selected: {_selectedChartType},
                onSelectionChanged: (newSelection) {
                  setState(() => _selectedChartType = newSelection.first);
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Chart
            chart,

            // Insight row
            if (trendData != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _buildInsightRow(trendData, chartColor),
            ],
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // CARD 2: Performance Card (FIX OVERFLOW with GridView 2x2)
  // ==========================================================================

  Widget _buildPerformanceCard(
    ExerciseProgressMetrics metrics,
    List<ExerciseSetData> sets,
  ) {
    final periodMaxWeight = sets.isNotEmpty
        ? sets.fold<double>(
            0,
            (max, set) => set.weight > max ? set.weight : max,
          )
        : 0.0;

    final periodAvgWeight = sets.isNotEmpty
        ? sets.fold<double>(0, (sum, set) => sum + set.weight) / sets.length
        : 0.0;

    final periodAvgReps = sets.isNotEmpty
        ? sets.fold<double>(0, (sum, set) => sum + set.reps) / sets.length
        : 0.0;

    final setsWithRPE = sets.where((s) => s.rpe != null).toList();
    final periodAvgRPE = setsWithRPE.isNotEmpty
        ? setsWithRPE.fold<double>(0, (sum, set) => sum + (set.rpe ?? 0)) /
              setsWithRPE.length
        : 0.0;

    // Watch Form Cues
    final formCuesAsync = ref.watch(
      formCuesProvider((
        exerciseId: widget.exerciseId,
        exerciseName: widget.exerciseName,
      )),
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.mdRadius),
      child: Padding(
        padding: AppSpacing.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(AppIcons.achievement, color: context.colors.primary),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  context.l10n.exerciseStats,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Stats Grid 2x2 (fixes overflow)
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
              childAspectRatio: 1.5,
              children: [
                _buildGradientStatCard(
                  context.l10n.personalRecord,
                  '${periodMaxWeight.toStringAsFixed(1)} kg',
                  AppIcons.achievement,
                  context.colors.warning,
                  tooltipType: TerminologyType.pr,
                ),
                _buildGradientStatCard(
                  context.l10n.averageWeight,
                  '${periodAvgWeight.toStringAsFixed(1)} kg',
                  AppIcons.workout,
                  context.colors.primary,
                  tooltipType: TerminologyType.avg,
                ),
                _buildGradientStatCard(
                  context.l10n.avgReps,
                  periodAvgReps.toStringAsFixed(0),
                  AppIcons.repeat,
                  context.colors.success,
                  tooltipType: TerminologyType.reps,
                ),
                if (periodAvgRPE > 0)
                  _buildGradientStatCard(
                    context.l10n.averageRPE,
                    periodAvgRPE.toStringAsFixed(1),
                    AppIcons.speed,
                    context.colors.secondary,
                    tooltipType: TerminologyType.rpe,
                  ),
              ],
            ),

            // Training Patterns
            _buildPatternCardsInline(),

            // Form Cues
            formCuesAsync.when(
              data: (formCues) => formCues != null && formCues.isNotEmpty
                  ? _buildFormCuesInline(formCues)
                  : const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  /// Gradient stat card matching ExerciseSummaryTab pattern
  Widget _buildGradientStatCard(
    String label,
    String value,
    IconData icon,
    Color color, {
    TerminologyType? tooltipType,
  }) {
    return InkWell(
      onTap: tooltipType != null
          ? () => _showTerminologyExplanation(tooltipType)
          : null,
      borderRadius: AppBorderRadius.smRadius,
      splashColor: color.withValues(alpha: 0.15),
      highlightColor: color.withValues(alpha: 0.08),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          borderRadius: AppBorderRadius.smRadius,
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.15),
              color.withValues(alpha: 0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: AppIconSize.xlarge),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              value,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Training pattern cards inline within performance card
  Widget _buildPatternCardsInline() {
    final patternsAsync = ref.watch(
      trainingPatternProvider(widget.exerciseName),
    );

    return patternsAsync.when(
      data: (results) {
        if (!results.hasPatterns) return const SizedBox.shrink();

        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Divider(),
            ),
            TrainingPatternsList(
              results: results,
              maxPatterns: 2,
              warningsOnly: false,
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  /// Form Cues inline within performance card
  Widget _buildFormCuesInline(String formCues) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Divider(),
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: context.colors.primaryContainer,
                borderRadius: AppBorderRadius.xsRadius,
              ),
              child: Icon(
                AppIcons.editNoteRounded,
                color: context.colors.onPrimaryContainer,
                size: AppIconSize.small,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              context.l10n.formCues,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colors.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          formCues,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.onSurface,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // CARD 3: History Card
  // ==========================================================================

  Widget _buildHistoryCard(List<ExerciseSetData> sets) {
    if (sets.isEmpty) return const SizedBox.shrink();

    // Group by date
    final Map<String, List<ExerciseSetData>> sessionsByDate = {};
    for (final set in sets) {
      final dateKey = DateFormat('yyyy-MM-dd').format(set.date);
      sessionsByDate.putIfAbsent(dateKey, () => []).add(set);
    }

    final sortedDates = sessionsByDate.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.mdRadius),
      child: Padding(
        padding: AppSpacing.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(AppIcons.calendar, color: context.colors.primary),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  context.l10n.sessionHistory,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
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

  // ==========================================================================
  // Shared Components
  // ==========================================================================

  Widget _buildPeriodSelector() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: context.colors.surfaceContainer,
        borderRadius: AppBorderRadius.smRadius,
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
          margin: const EdgeInsets.all(AppSpacing.xxs),
          decoration: BoxDecoration(
            color: isSelected
                ? context.colors.primary
                : context.colors.surface.withValues(alpha: 0),
            borderRadius: AppBorderRadius.xsRadius,
          ),
          child: Center(
            child: Text(
              label,
              style: context.textTheme.labelLarge?.copyWith(
                color: isSelected
                    ? context.colors.onPrimary
                    : context.colors.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build trend badge showing percentage change
  Widget _buildTrendBadge(_TrendData trend, ChartType type) {
    final bool isGood;
    if (type == ChartType.rpe) {
      isGood = !trend.isPositive || trend.isStable;
    } else {
      isGood = trend.isPositive || trend.isStable;
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
        ? context.l10n.analyticsTrendBadgeUp(
            trend.percentChange.abs().toStringAsFixed(1),
          )
        : context.l10n.analyticsTrendBadgeDown(
            trend.percentChange.toStringAsFixed(1),
          );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppBorderRadius.smRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: textColor),
          const SizedBox(width: AppSpacing.xxs),
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: chartColor.withValues(alpha: 0.08),
        borderRadius: AppBorderRadius.xsRadius,
        border: Border.all(color: chartColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(AppIcons.lightbulb, size: AppIconSize.small, color: chartColor),
          const SizedBox(width: AppSpacing.xs),
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
  (String, IconData, Color, Widget) _getChartData(
    ChartType type,
    List<ExerciseSetData> sets,
  ) {
    switch (type) {
      case ChartType.weight:
        return (
          context.l10n.weightProgression,
          AppIcons.workout,
          context.colors.primary,
          WeightLineChart(sets: sets),
        );
      case ChartType.volume:
        return (
          context.l10n.volumeProgression,
          AppIcons.analytics,
          context.colors.warning,
          VolumeBarChart(sets: sets),
        );
      case ChartType.reps:
        return (
          context.l10n.repsProgression,
          AppIcons.repeat,
          context.colors.success,
          RepsLineChart(sets: sets),
        );
      case ChartType.rpe:
        return (
          context.l10n.effortProgression,
          AppIcons.speed,
          context.colors.error,
          RpeGaugeWidget(sets: sets),
        );
    }
  }

  Widget _buildSessionItem(DateTime date, List<ExerciseSetData> sets) {
    final maxWeight = sets.fold<double>(
      0,
      (max, set) => set.weight > max ? set.weight : max,
    );
    final totalVolume = sets.fold<double>(0, (sum, set) => sum + set.volume);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: context.colors.surfaceContainer,
          borderRadius: AppBorderRadius.smRadius,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: context.colors.primaryContainer,
                borderRadius: AppBorderRadius.xsRadius,
              ),
              child: Icon(
                AppIcons.calendar,
                color: context.colors.primary,
                size: AppIconSize.small,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
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

  /// Show terminology explanation bottom sheet
  void _showTerminologyExplanation(TerminologyType type) {
    final (term, explanation) = switch (type) {
      TerminologyType.pr => (
        context.l10n.tooltipPR,
        context.l10n.tooltipPRExplanation,
      ),
      TerminologyType.rpe => (
        context.l10n.tooltipRPE,
        context.l10n.tooltipRPEExplanation,
      ),
      TerminologyType.volume => (
        context.l10n.tooltipVolume,
        context.l10n.tooltipVolumeExplanation,
      ),
      TerminologyType.reps => (
        context.l10n.tooltipReps,
        context.l10n.tooltipRepsExplanation,
      ),
      TerminologyType.avg => (
        context.l10n.tooltipAvg,
        context.l10n.tooltipAvgExplanation,
      ),
    };

    ModalService.showSheet(context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppBorderRadius.onlyTop(AppBorderRadius.lg),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.xl,
          right: AppSpacing.xl,
          top: AppSpacing.md,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: AppBorderRadius.xxsRadius,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Icon and title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: context.colors.primaryContainer,
                    borderRadius: AppBorderRadius.smRadius,
                  ),
                  child: Icon(
                    AppIcons.lightbulb,
                    color: context.colors.primary,
                    size: AppIconSize.medium,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    term,
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colors.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Explanation
            Text(
              explanation,
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.85),
                height: 1.6,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Close button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(context.l10n.ok),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build Quick Answer Banner - "Am I improving?"
  Widget _buildQuickAnswerBanner(List<ExerciseSetData> sets) {
    if (sets.length < 3) return const SizedBox.shrink();

    final midpoint = sets.length ~/ 2;
    final firstHalf = sets.sublist(0, midpoint);
    final secondHalf = sets.sublist(midpoint);

    final firstAvg =
        firstHalf.fold<double>(0, (sum, s) => sum + s.weight) /
        firstHalf.length;
    final secondAvg =
        secondHalf.fold<double>(0, (sum, s) => sum + s.weight) /
        secondHalf.length;

    if (firstAvg == 0) return const SizedBox.shrink();

    final percentChange = ((secondAvg - firstAvg) / firstAvg) * 100;
    final absChange = percentChange.abs();
    final isImproving = percentChange > 2.0;
    final isStable = absChange <= 2.0;

    final daysDiff = sets.last.date.difference(sets.first.date).inDays;
    String periodLabel;
    if (daysDiff <= 14) {
      periodLabel = context.l10n.periodWeeks(2);
    } else if (daysDiff <= 30) {
      periodLabel = context.l10n.periodWeeks(4);
    } else if (daysDiff <= 60) {
      periodLabel = context.l10n.periodMonths(2);
    } else {
      periodLabel = context.l10n.periodMonths(3);
    }

    final currentPR = sets.fold<double>(
      0,
      (max, s) => s.weight > max ? s.weight : max,
    );
    final nextGoal = (currentPR + 2.5).ceilToDouble();

    String title;
    String subtitle;
    IconData icon;
    Color bgColor;
    Color iconColor;

    if (isImproving) {
      title = context.l10n.quickAnswerImproving;
      subtitle = context.l10n.quickAnswerWeightUp(
        absChange.toStringAsFixed(0),
        periodLabel,
      );
      icon = AppIcons.trendUp;
      bgColor = context.colors.success.withValues(alpha: 0.12);
      iconColor = context.colors.success;
    } else if (isStable) {
      title = context.l10n.quickAnswerStable;
      subtitle = context.l10n.quickAnswerStableMessage(periodLabel);
      icon = AppIcons.trendFlat;
      bgColor = context.colors.primary.withValues(alpha: 0.1);
      iconColor = context.colors.primary;
    } else {
      title = context.l10n.quickAnswerDeclining;
      subtitle = context.l10n.quickAnswerWeightDown(
        absChange.toStringAsFixed(0),
        periodLabel,
      );
      icon = AppIcons.trendDown;
      bgColor = context.colors.warning.withValues(alpha: 0.12);
      iconColor = context.colors.warning;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppBorderRadius.mdRadius,
        border: Border.all(color: iconColor.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: AppBorderRadius.xsRadius,
                ),
                child: Icon(icon, color: iconColor, size: AppIconSize.medium),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: iconColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colors.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Next goal suggestion
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: AppBorderRadius.xsRadius,
            ),
            child: Row(
              children: [
                Icon(
                  AppIcons.flagCircle,
                  size: AppIconSize.small,
                  color: context.colors.primary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    context.l10n.quickAnswerNextGoal(
                      currentPR.toStringAsFixed(1),
                      nextGoal.toStringAsFixed(1),
                    ),
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurface.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
