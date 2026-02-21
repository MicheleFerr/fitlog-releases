import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/utils/one_rm_calculator.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_history_provider.dart';
import 'package:gymbro_flutter_new/features/workout/data/services/exercise_history_service.dart';
import 'package:gymbro_flutter_new/features/strength_standards/presentation/providers/strength_standards_providers.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/strength_standard.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/providers/hybrid_exercise_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';
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

  final List<ChartMetric> _selectedMultiMetrics = ChartMetric.values.toList();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(
          exerciseHistoryDataGroupedProvider(widget.exerciseName),
        );
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildExerciseNameCard(),
            const SizedBox(height: 24),
            _buildChartSection(),
            const SizedBox(height: 24),
            _buildMultiMetricChartSection(),
            const SizedBox(height: 24),
            _buildPersonalRecordsSection(),
            const SizedBox(height: 24),
            _buildStrengthLevelSection(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseNameCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.exerciseName,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.last3MonthsChart,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildMetricChip(ChartMetric.weight),
              const SizedBox(width: 8),
              _buildMetricChip(ChartMetric.reps),
              const SizedBox(width: 8),
              _buildMetricChip(ChartMetric.rpe),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildChart(),
      ],
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
          const SizedBox(width: 4),
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

  Widget _buildMultiMetricChartSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.multiMetricComparison,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        _buildMultiMetricChart(),
      ],
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
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: LoadingIndicator()),
      );
    }

    if (anyError) {
      return Container(
        height: 250,
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
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
              const SizedBox(height: 8),
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
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: LoadingIndicator()),
      ),
      error: (error, stack) {
        return Container(
          height: 200,
          decoration: BoxDecoration(
            color: context.colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
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
                const SizedBox(height: 8),
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

  Widget _buildPersonalRecordsSection() {
    final historyAsync = ref.watch(
      exerciseHistoryDataGroupedProvider(widget.exerciseName),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.personalRecords,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        historyAsync.when(
          data: (historyMap) {
            final allSets = <ExerciseHistoryData>[];
            historyMap.forEach((date, sets) {
              allSets.addAll(sets);
            });

            if (allSets.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
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
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
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
        ),
      ],
    );
  }

  Widget _buildInteractiveRecordCard(
    String label,
    String value,
    IconData icon,
    Color color,
    _RecordData recordData,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Semantics(
        label: '$label: $value',
        button: true,
        child: InkWell(
          onTap: () => _showRecordDetails(label, recordData),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.1),
                  color.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: AppIconSize.large),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colors.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                SemanticIcon(
                  icon: AppIcons.infoOutline,
                  semanticLabel: 'Info outline',
                  size: AppIconSize.tiny,
                  color: context.colors.onSurface.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _looksLikeUuid(String? id) {
    if (id == null) return false;
    return id.contains('-') && id.length >= 32;
  }

  Widget _buildStrengthLevelSection() {
    final hasValidDatabaseId =
        widget.exerciseId != null && !_looksLikeUuid(widget.exerciseId);

    if (hasValidDatabaseId) {
      return _buildStrengthLevelWithKey(widget.exerciseId!);
    }

    final databaseIdAsync = ref.watch(
      exerciseIdByNameProvider(widget.exerciseName),
    );

    return databaseIdAsync.when(
      data: (databaseId) {
        if (kDebugMode) {
          debugPrint('[STRENGTH LEVEL] Database ID lookup by name:');
          debugPrint('   Exercise name: ${widget.exerciseName}');
          debugPrint('   Found database ID: $databaseId');
        }

        if (databaseId == null) {
          return _buildStrengthLevelCardWrapper(
            _buildStrengthLevelPlaceholder(),
          );
        }

        return _buildStrengthLevelWithKey(databaseId);
      },
      loading: () => _buildStrengthLevelCardWrapper(const LoadingIndicator()),
      error: (error, stack) {
        if (kDebugMode) debugPrint('Error looking up database ID: $error');
        return _buildStrengthLevelCardWrapper(_buildStrengthLevelPlaceholder());
      },
    );
  }

  Widget _buildStrengthLevelCardWrapper(Widget child) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(AppIcons.emojiEvents, color: context.colors.primary),
                const SizedBox(width: 8),
                Text(
                  context.l10n.strengthLevel,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildStrengthLevelWithKey(String lookupKey) {
    final mappingAsync = ref.watch(exerciseMappingByIdProvider(lookupKey));
    final historyAsync = ref.watch(
      exerciseHistoryDataGroupedProvider(widget.exerciseName),
    );
    const standardBodyweight = 80.0;

    return _buildStrengthLevelCardWrapper(
      mappingAsync.when(
        data: (mapping) {
          if (kDebugMode) {
            debugPrint(
              '[STRENGTH LEVEL] Step 1 - Mapping received: $mapping',
            );
          }

          if (mapping == null) return _buildStrengthLevelPlaceholder();
          if (mapping.standardId == null) {
            return _buildStrengthLevelPlaceholder();
          }

          final standardAsync = ref.watch(
            strengthStandardByIdProvider(mapping.standardId!),
          );

          return standardAsync.when(
            data: (standard) {
              if (standard == null) return _buildStrengthLevelPlaceholder();

              return historyAsync.when(
                data: (historyMap) {
                  final allSets = <ExerciseHistoryData>[];
                  historyMap.forEach((date, sets) => allSets.addAll(sets));

                  if (allSets.isEmpty) return _buildStrengthLevelPlaceholder();

                  double best1RM = 0.0;
                  for (final set in allSets) {
                    if (set.weight != null &&
                        set.reps != null &&
                        set.reps! > 0) {
                      final calculated1RM = calculate1RM(
                        set.weight!,
                        set.reps!,
                      );
                      if (calculated1RM != null && calculated1RM > best1RM) {
                        best1RM = calculated1RM;
                      }
                    }
                  }

                  return _buildStrengthLevelContent(
                    standard: standard,
                    userBodyweight: standardBodyweight,
                    user1RM: best1RM,
                  );
                },
                loading: () => const LoadingIndicator(),
                error: (error, stack) => _buildStrengthLevelPlaceholder(),
              );
            },
            loading: () => const LoadingIndicator(),
            error: (error, stack) => _buildStrengthLevelPlaceholder(),
          );
        },
        loading: () => const LoadingIndicator(),
        error: (error, stack) => _buildStrengthLevelPlaceholder(),
      ),
    );
  }

  Widget _buildStrengthLevelPlaceholder() {
    return Column(
      children: [
        SemanticIcon(
          icon: AppIcons.infoOutline,
          semanticLabel: 'Info outline',
          size: AppIconSize.xxlarge,
          color: context.colors.onSurface.withValues(alpha: 0.3),
        ),
        const SizedBox(height: 12),
        Text(
          context.l10n.strengthLevelNoData,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          context.l10n.strengthLevelAvailableAfterWorkout,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurface.withValues(alpha: 0.5),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStrengthLevelContent({
    required StrengthStandard standard,
    required double userBodyweight,
    required double user1RM,
  }) {
    const levels = ExperienceLevel.values;
    final levelValues = <ExperienceLevel, double>{};

    for (final level in levels) {
      final value = standard.getOneRepMax(
        bodyweightKg: userBodyweight,
        level: level,
      );
      if (value != null) {
        levelValues[level] = value;
      }
    }

    ExperienceLevel currentLevel = ExperienceLevel.untrained;
    double progressToNext = 0.0;

    for (var i = 0; i < levels.length; i++) {
      final level = levels[i];
      final levelValue = levelValues[level];

      if (levelValue == null) continue;

      if (user1RM >= levelValue) {
        currentLevel = level;

        if (i < levels.length - 1) {
          final nextLevel = levels[i + 1];
          final nextValue = levelValues[nextLevel];

          if (nextValue != null && nextValue > levelValue) {
            progressToNext =
                ((user1RM - levelValue) / (nextValue - levelValue))
                    .clamp(0.0, 1.0);
          }
        }
      } else {
        break;
      }
    }

    final levelColor = _getLevelColor(currentLevel);
    final locale = Localizations.localeOf(context).languageCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: levelColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.your1RM,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colors.onSurface.withValues(alpha: 0.7),
                ),
              ),
              Text(
                '${user1RM.toStringAsFixed(1)} kg',
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.onSurface,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: levelColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                currentLevel.getLabel(locale).toUpperCase(),
                style: context.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.surface,
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (currentLevel != ExperienceLevel.elite && progressToNext > 0)
              Expanded(
                child: Text(
                  context.l10n.progressToNextLevel(
                    (progressToNext * 100).toStringAsFixed(0),
                    levels[levels.indexOf(currentLevel) + 1].getLabel(locale),
                  ),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (currentLevel != ExperienceLevel.elite) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progressToNext,
              minHeight: 8,
              backgroundColor: context.colors.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(levelColor),
            ),
          ),
          const SizedBox(height: 16),
        ],
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.colors.surfaceContainerHighest.withValues(
              alpha: 0.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              ...levels.map((level) {
                final value = levelValues[level];
                if (value == null) return const SizedBox.shrink();

                final isCurrentLevel = level == currentLevel;
                final color = _getLevelColor(level);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isCurrentLevel
                              ? color
                              : color.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          level.getLabel(locale),
                          style: context.textTheme.bodyMedium?.copyWith(
                            fontWeight: isCurrentLevel
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: context.colors.onSurface,
                          ),
                        ),
                      ),
                      Text(
                        '${value.toStringAsFixed(1)} kg',
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: isCurrentLevel
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isCurrentLevel
                              ? color
                              : context.colors.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Text(
                context.l10n.benchmarkBodyweight(
                  userBodyweight.toStringAsFixed(0),
                ),
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colors.onSurface.withValues(alpha: 0.5),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getLevelColor(ExperienceLevel level) {
    switch (level) {
      case ExperienceLevel.untrained:
        return context.colors.surfaceContainerHighest;
      case ExperienceLevel.novice:
        return context.colors.primary;
      case ExperienceLevel.intermediate:
        return context.colors.success;
      case ExperienceLevel.advanced:
        return context.colors.secondary;
      case ExperienceLevel.elite:
        return context.colors.tertiary;
    }
  }

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
        final calculated1RM = calculate1RM(set.weight!, set.reps!);
        if (calculated1RM != null && calculated1RM > best1RM) {
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
        padding: const EdgeInsets.all(24),
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
                const SizedBox(width: 12),
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
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
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
            const SizedBox(height: 16),
            if (recordData.date != null) ...[
              _buildDetailRow(
                AppIcons.calendarToday,
                context.l10n.dateLabel,
                dateFormatter.format(recordData.date!),
              ),
              const SizedBox(height: 12),
            ],
            if (recordData.workoutName != null) ...[
              _buildDetailRow(
                AppIcons.fitnessCenter,
                context.l10n.workout,
                recordData.workoutName!,
              ),
              const SizedBox(height: 12),
            ],
            if (recordData.weight != null && recordData.reps != null) ...[
              _buildDetailRow(
                AppIcons.info,
                context.l10n.setDetailLabel,
                '${recordData.weight!.toStringAsFixed(1)} kg x ${recordData.reps} reps',
              ),
              if (recordData.isCalculated)
                Padding(
                  padding: const EdgeInsets.only(left: 32, top: 4),
                  child: Text(
                    context.l10n.calculatedWithBrzycki,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colors.onSurface.withValues(alpha: 0.5),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
            ],
            if (recordData.sessionSets != null &&
                recordData.sessionSets!.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 8),
              Text(
                context.l10n.sessionSetsCount(
                  recordData.sessionSets!.length,
                ),
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              ...recordData.sessionSets!.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final set = entry.value;
                final setVolume = (set.weight ?? 0.0) * (set.reps ?? 0);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: context.colors.secondary.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(8),
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
                      const SizedBox(width: 12),
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
            const SizedBox(height: 24),
            Builder(
              builder: (modalContext) => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(modalContext).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    foregroundColor: context.colors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(width: 8),
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
