import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/one_rm_calculator.dart';
import 'package:gymbro_flutter_new/features/strength_standards/presentation/widgets/exercise_strength_level_section.dart';
import 'package:gymbro_flutter_new/features/workout/data/services/exercise_history_service.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_history_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_border_radius.dart';
import 'package:intl/intl.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_chart_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_metric_chart.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/multi_metric_chart.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/chart_data_point.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Metric types for exercise charts.
/// Internal [key] is used for data lookup; [label] for localized display.
enum ChartMetric {
  weight,
  reps,
  rpe;

  /// Internal key used by ChartDataParams and MultiMetricChart.
  String get key {
    switch (this) {
      case ChartMetric.weight:
        return 'Peso';
      case ChartMetric.reps:
        return 'Reps';
      case ChartMetric.rpe:
        return 'RPE';
    }
  }

  String label(BuildContext context) {
    switch (this) {
      case ChartMetric.weight:
        return context.l10n.weight;
      case ChartMetric.reps:
        return context.l10n.reps;
      case ChartMetric.rpe:
        return context.l10n.rpe;
    }
  }

  IconData get icon {
    switch (this) {
      case ChartMetric.weight:
        return AppIcons.fitnessCenter;
      case ChartMetric.reps:
        return AppIcons.repeat;
      case ChartMetric.rpe:
        return AppIcons.trendingUp;
    }
  }
}

/// Chart display mode for the unified chart section.
enum _ChartMode { single, comparison }

/// Tab Sommario: mostra stats, grafico, record personali e livello di forza
class ExerciseSummaryTab extends ConsumerStatefulWidget {
  const ExerciseSummaryTab({
    super.key,
    required this.exerciseName,
    this.exerciseId,
  });
  final String exerciseName;

  /// Optional exercise database ID for strength standards lookup.
  /// If provided, enables accurate mapping to strength standards.
  final String? exerciseId;

  @override
  ConsumerState<ExerciseSummaryTab> createState() => _ExerciseSummaryTabState();
}

class _ExerciseSummaryTabState extends ConsumerState<ExerciseSummaryTab> {
  ChartMetric _selectedChip = ChartMetric.weight;
  _ChartMode _chartMode = _ChartMode.single;

  final List<ChartMetric> _selectedMultiMetrics = ChartMetric.values.toList();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(exerciseHistoryDataGroupedProvider(widget.exerciseName));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md + context.tabBarInset,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUnifiedChartSection(),
            const SizedBox(height: AppSpacing.xl),
            _buildPerformanceSection(),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // CHANGE #2: Unified chart section with toggle
  // ==========================================================================

  Widget _buildUnifiedChartSection() {
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
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Toggle
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<_ChartMode>(
                segments: [
                  ButtonSegment(
                    value: _ChartMode.single,
                    label: Text(context.l10n.chartModeSingle),
                  ),
                  ButtonSegment(
                    value: _ChartMode.comparison,
                    label: Text(context.l10n.chartModeComparison),
                  ),
                ],
                selected: {_chartMode},
                onSelectionChanged: (newSelection) {
                  setState(() => _chartMode = newSelection.first);
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Content based on mode
            if (_chartMode == _ChartMode.single) ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildMetricChip(ChartMetric.weight),
                    const SizedBox(width: AppSpacing.xs),
                    _buildMetricChip(ChartMetric.reps),
                    const SizedBox(width: AppSpacing.xs),
                    _buildMetricChip(ChartMetric.rpe),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _buildChart(),
            ] else
              _buildMultiMetricChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricChip(ChartMetric metric) {
    final isSelected = _selectedChip == metric;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            metric.icon,
            size: AppIconSize.tiny,
            color: isSelected
                ? context.colors.onPrimary
                : context.colors.onSurface,
          ),
          const SizedBox(width: AppSpacing.xxs),
          Text(metric.label(context)),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedChip = metric);
      },
      backgroundColor: context.colors.surfaceContainerHighest,
      selectedColor: context.colors.primary,
      labelStyle: context.textTheme.labelMedium?.copyWith(
        color: isSelected ? context.colors.onPrimary : context.colors.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildMultiMetricChart() {
    final Map<String, AsyncValue<List<ChartDataPoint>>> metricDataMap = {};

    for (final metric in _selectedMultiMetrics) {
      final params = ChartDataParams(
        exerciseName: widget.exerciseName,
        metric: metric.key,
        days: 90,
      );
      metricDataMap[metric.key] = ref.watch(exerciseChartCleanProvider(params));
    }

    final allLoaded = metricDataMap.values.every(
      (asyncValue) => asyncValue.hasValue,
    );
    final anyError = metricDataMap.values.any(
      (asyncValue) => asyncValue.hasError,
    );
    final anyLoading = metricDataMap.values.any(
      (asyncValue) => asyncValue.isLoading,
    );

    if (anyLoading) {
      return Container(
        height: 250,
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerHighest,
          borderRadius: AppBorderRadius.smRadius,
        ),
        child: const Center(child: LoadingIndicator()),
      );
    }

    if (anyError) {
      return Container(
        height: 250,
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerHighest,
          borderRadius: AppBorderRadius.smRadius,
          border: Border.all(
            color: context.colors.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SemanticIcon(
                icon: AppIcons.errorOutline,
                semanticLabel: 'Error outline',
                size: AppIconSize.xxlarge,
                color: context.colors.error.withValues(alpha: 0.5),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                context.l10n.errorLoadingData,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.error,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (allLoaded) {
      final Map<String, List<ChartDataPoint>> dataByMetric = {};
      metricDataMap.forEach((metric, asyncValue) {
        dataByMetric[metric] = asyncValue.value ?? [];
      });

      return MultiMetricChart(
        dataByMetric: dataByMetric,
        selectedMetrics: _selectedMultiMetrics.map((m) => m.key).toList(),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildChart() {
    final params = ChartDataParams(
      exerciseName: widget.exerciseName,
      metric: _selectedChip.key,
      days: 90,
    );

    final chartDataAsync = ref.watch(exerciseChartCleanProvider(params));

    return chartDataAsync.when(
      data: (dataPoints) {
        return ExerciseMetricChart(
          dataPoints: dataPoints,
          metric: _selectedChip.key,
        );
      },
      loading: () => Container(
        height: 200,
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerHighest,
          borderRadius: AppBorderRadius.smRadius,
        ),
        child: const Center(child: LoadingIndicator()),
      ),
      error: (error, stack) {
        return Container(
          height: 200,
          decoration: BoxDecoration(
            color: context.colors.surfaceContainerHighest,
            borderRadius: AppBorderRadius.smRadius,
            border: Border.all(
              color: context.colors.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SemanticIcon(
                  icon: AppIcons.errorOutline,
                  semanticLabel: 'Error outline',
                  size: AppIconSize.xxlarge,
                  color: context.colors.error.withValues(alpha: 0.5),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  context.l10n.errorLoadingData,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.error,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================================================
  // CHANGE #4: Unified Performance section (Records + Strength Level)
  // ==========================================================================

  Widget _buildPerformanceSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.mdRadius),
      child: Padding(
        padding: AppSpacing.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Records sub-header
            Row(
              children: [
                Icon(AppIcons.emojiEvents, color: context.colors.primary),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  context.l10n.personalRecords,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            // Records grid
            _buildPersonalRecordsContent(),
            // Divider
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Divider(),
            ),
            // Strength Level sub-header
            Row(
              children: [
                Icon(AppIcons.emojiEvents, color: context.colors.secondary),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  context.l10n.strengthLevel,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Strength Level content
            ExerciseStrengthLevelSection(
              exerciseName: widget.exerciseName,
              exerciseId: widget.exerciseId,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalRecordsContent() {
    final historyAsync = ref.watch(
      exerciseHistoryDataGroupedProvider(widget.exerciseName),
    );

    return historyAsync.when(
      data: (historyMap) {
        final allSets = <ExerciseHistoryData>[];
        historyMap.forEach((date, sets) {
          allSets.addAll(sets);
        });

        if (allSets.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Text(
                context.l10n.noHistoryYet,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
          );
        }

        final records = _calculateRecords(allSets);

        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          childAspectRatio: 1.5,
          children: [
            _buildInteractiveRecordCard(
              context.l10n.maxWeight,
              '${records.maxWeight.value.toStringAsFixed(1)} kg',
              AppIcons.fitnessCenter,
              context.colors.primary,
              records.maxWeight,
            ),
            _buildInteractiveRecordCard(
              context.l10n.best1RM,
              '${records.best1RM.value.toStringAsFixed(1)} kg',
              AppIcons.star,
              context.colors.secondary,
              records.best1RM,
            ),
            _buildInteractiveRecordCard(
              context.l10n.bestSetVolume,
              '${records.bestSetVolume.value.toStringAsFixed(0)} kg',
              AppIcons.trendingUp,
              context.colors.tertiary,
              records.bestSetVolume,
            ),
            _buildInteractiveRecordCard(
              context.l10n.bestSessionVolume,
              '${records.bestSessionVolume.value.toStringAsFixed(0)} kg',
              AppIcons.workspaces,
              context.colors.secondary,
              records.bestSessionVolume,
            ),
          ],
        );
      },
      loading: () => const LoadingIndicator(),
      error: (error, stack) => Center(
        child: Text(
          context.l10n.errorLoadingData,
          style: TextStyle(color: context.colors.error),
        ),
      ),
    );
  }

  // ==========================================================================
  // CHANGE #3: Enhanced record cards with pronounced colors
  // ==========================================================================

  Widget _buildInteractiveRecordCard(
    String label,
    String value,
    IconData icon,
    Color color,
    _RecordData recordData,
  ) {
    return Semantics(
      label: '$label: $value',
      button: true,
      child: InkWell(
        onTap: () => _showRecordDetails(label, recordData),
        borderRadius: AppBorderRadius.smRadius,
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
            border: Border.all(color: color.withValues(alpha: 0.2)),
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
      ),
    );
  }

  // ==========================================================================
  // Strength Level (inner content for unified performance section)
  // ==========================================================================

  // ==========================================================================
  // Record calculation + details bottom sheet
  // ==========================================================================

  _Records _calculateRecords(List<ExerciseHistoryData> allSets) {
    ExerciseHistoryData? maxWeightSet;
    double maxWeight = 0.0;
    for (final set in allSets) {
      if ((set.weight ?? 0.0) > maxWeight) {
        maxWeight = set.weight!;
        maxWeightSet = set;
      }
    }

    ExerciseHistoryData? best1RMSet;
    double best1RM = 0.0;
    for (final set in allSets) {
      if (set.weight != null && set.reps != null && set.reps! > 0) {
        final calculated1RM = OneRMCalculator.calculateBrzycki(
          set.weight!,
          set.reps!,
        );
        if (calculated1RM > best1RM) {
          best1RM = calculated1RM;
          best1RMSet = set;
        }
      }
    }

    ExerciseHistoryData? bestSetVolumeSet;
    double bestSetVolume = 0.0;
    for (final set in allSets) {
      if (set.weight != null && set.reps != null) {
        final volume = set.weight! * set.reps!;
        if (volume > bestSetVolume) {
          bestSetVolume = volume;
          bestSetVolumeSet = set;
        }
      }
    }

    final Map<String, double> sessionVolumes = {};
    final Map<String, DateTime> sessionDates = {};
    final Map<String, List<ExerciseHistoryData>> sessionSets = {};
    final Map<String, String> sessionWorkoutNames = {};

    for (final set in allSets) {
      if (set.weight != null && set.reps != null) {
        final sessionKey =
            '${set.workoutName}_${set.date.toIso8601String().split('T')[0]}';
        final volume = set.weight! * set.reps!;
        sessionVolumes[sessionKey] =
            (sessionVolumes[sessionKey] ?? 0.0) + volume;
        sessionDates[sessionKey] = set.date;
        sessionSets[sessionKey] = [...(sessionSets[sessionKey] ?? []), set];
        sessionWorkoutNames[sessionKey] = set.workoutName;
      }
    }

    String? bestSessionKey;
    double bestSessionVolume = 0.0;
    sessionVolumes.forEach((key, volume) {
      if (volume > bestSessionVolume) {
        bestSessionVolume = volume;
        bestSessionKey = key;
      }
    });

    return _Records(
      maxWeight: _RecordData(
        value: maxWeight,
        date: maxWeightSet?.date,
        weight: maxWeightSet?.weight,
        reps: maxWeightSet?.reps,
        workoutName: maxWeightSet?.workoutName,
      ),
      best1RM: _RecordData(
        value: best1RM,
        date: best1RMSet?.date,
        weight: best1RMSet?.weight,
        reps: best1RMSet?.reps,
        workoutName: best1RMSet?.workoutName,
        isCalculated: true,
      ),
      bestSetVolume: _RecordData(
        value: bestSetVolume,
        date: bestSetVolumeSet?.date,
        weight: bestSetVolumeSet?.weight,
        reps: bestSetVolumeSet?.reps,
        workoutName: bestSetVolumeSet?.workoutName,
      ),
      bestSessionVolume: _RecordData(
        value: bestSessionVolume,
        date: bestSessionKey != null ? sessionDates[bestSessionKey] : null,
        workoutName: bestSessionKey != null
            ? sessionWorkoutNames[bestSessionKey]
            : null,
        sessionSets: bestSessionKey != null
            ? sessionSets[bestSessionKey]
            : null,
      ),
    );
  }

  void _showRecordDetails(String recordLabel, _RecordData recordData) {
    final locale = Localizations.localeOf(context).toString();
    final dateFormatter = DateFormat('EEEE, dd MMMM yyyy', locale);

    ModalService.showBottomSheet(
      context,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  AppIcons.emojiEvents,
                  color: context.colors.primary,
                  size: AppIconSize.xlarge,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    recordLabel,
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colors.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Container(
              padding: AppSpacing.card,
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.1),
                borderRadius: AppBorderRadius.smRadius,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.recordLabel,
                    style: context.textTheme.titleMedium?.copyWith(
                      color: context.colors.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  Text(
                    '${recordData.value.toStringAsFixed(1)} kg',
                    style: context.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (recordData.date != null) ...[
              _buildDetailRow(
                AppIcons.calendarToday,
                context.l10n.dateLabel,
                dateFormatter.format(recordData.date!),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            if (recordData.workoutName != null) ...[
              _buildDetailRow(
                AppIcons.fitnessCenter,
                context.l10n.workout,
                recordData.workoutName!,
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            if (recordData.weight != null && recordData.reps != null) ...[
              _buildDetailRow(
                AppIcons.info,
                context.l10n.setDetailLabel,
                '${recordData.weight!.toStringAsFixed(1)} kg x ${recordData.reps} reps',
              ),
              if (recordData.isCalculated)
                Padding(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.xxl,
                    top: AppSpacing.xxs,
                  ),
                  child: Text(
                    context.l10n.calculatedWithBrzycki,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colors.onSurface.withValues(alpha: 0.5),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.sm),
            ],
            if (recordData.sessionSets != null &&
                recordData.sessionSets!.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: AppSpacing.xs),
              Text(
                context.l10n.sessionSetsCount(recordData.sessionSets!.length),
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ...recordData.sessionSets!.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final set = entry.value;
                final setVolume = (set.weight ?? 0.0) * (set.reps ?? 0);
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: context.colors.secondary.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: AppBorderRadius.xsRadius,
                        ),
                        child: Center(
                          child: Text(
                            '$index',
                            style: context.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.colors.secondary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          '${set.weight?.toStringAsFixed(1) ?? '0'} kg x ${set.reps ?? 0} reps',
                          style: context.textTheme.bodyMedium,
                        ),
                      ),
                      Text(
                        '${setVolume.toStringAsFixed(0)} kg',
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.colors.primary,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
            const SizedBox(height: AppSpacing.xl),
            Builder(
              builder: (modalContext) => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(modalContext).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    foregroundColor: context.colors.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppBorderRadius.smRadius,
                    ),
                  ),
                  child: Text(context.l10n.closeButton),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: AppIconSize.small, color: context.colors.primary),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '$label:',
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            value,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colors.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _RecordData {
  _RecordData({
    required this.value,
    this.date,
    this.weight,
    this.reps,
    this.workoutName,
    this.isCalculated = false,
    this.sessionSets,
  });
  final double value;
  final DateTime? date;
  final double? weight;
  final int? reps;
  final String? workoutName;
  final bool isCalculated;
  final List<ExerciseHistoryData>? sessionSets;
}

class _Records {
  _Records({
    required this.maxWeight,
    required this.best1RM,
    required this.bestSetVolume,
    required this.bestSessionVolume,
  });
  final _RecordData maxWeight;
  final _RecordData best1RM;
  final _RecordData bestSetVolume;
  final _RecordData bestSessionVolume;
}
