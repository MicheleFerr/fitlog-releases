import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/one_rm_calculator.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/providers/hybrid_exercise_provider.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/strength_standard.dart';
import 'package:gymbro_flutter_new/features/strength_standards/presentation/providers/strength_standards_providers.dart';
import 'package:gymbro_flutter_new/features/workout/data/services/exercise_history_service.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_history_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/user_bodyweight_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_border_radius.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Shared strength standards section for exercise detail surfaces.
class ExerciseStrengthLevelSection extends ConsumerWidget {
  const ExerciseStrengthLevelSection({
    super.key,
    required this.exerciseName,
    this.exerciseId,
    this.userOneRepMax,
  });

  final String exerciseName;
  final String? exerciseId;
  final double? userOneRepMax;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasValidDatabaseId =
        exerciseId != null && !_looksLikeUuid(exerciseId);

    if (hasValidDatabaseId) {
      return _ExerciseStrengthLevelLookup(
        exerciseName: exerciseName,
        lookupKey: exerciseId!,
        userOneRepMax: userOneRepMax,
      );
    }

    final databaseIdAsync = ref.watch(exerciseIdByNameProvider(exerciseName));

    return databaseIdAsync.when(
      data: (databaseId) {
        if (databaseId == null) {
          return const _StrengthLevelPlaceholder();
        }

        return _ExerciseStrengthLevelLookup(
          exerciseName: exerciseName,
          lookupKey: databaseId,
          userOneRepMax: userOneRepMax,
        );
      },
      loading: () => const LoadingIndicator(),
      error: (_, __) => const _StrengthLevelPlaceholder(),
    );
  }

  bool _looksLikeUuid(String? id) {
    if (id == null) return false;
    return id.contains('-') && id.length >= 32;
  }
}

class _ExerciseStrengthLevelLookup extends ConsumerWidget {
  const _ExerciseStrengthLevelLookup({
    required this.exerciseName,
    required this.lookupKey,
    this.userOneRepMax,
  });

  final String exerciseName;
  final String lookupKey;
  final double? userOneRepMax;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mappingAsync = ref.watch(exerciseMappingByIdProvider(lookupKey));
    final userBodyweight = ref.watch(userBodyweightProvider).value ?? 80.0;

    if (mappingAsync.isLoading) {
      return const LoadingIndicator();
    }

    if (mappingAsync.hasError || !mappingAsync.hasValue) {
      return const _StrengthLevelPlaceholder();
    }

    final mapping = mappingAsync.value;
    if (mapping == null || mapping.standardId == null) {
      return const _StrengthLevelPlaceholder();
    }

    final standardAsync = ref.watch(
      strengthStandardByIdProvider(mapping.standardId!),
    );

    if (standardAsync.isLoading) {
      return const LoadingIndicator();
    }

    if (standardAsync.hasError || !standardAsync.hasValue) {
      return const _StrengthLevelPlaceholder();
    }

    final standard = standardAsync.value;
    if (standard == null) {
      return const _StrengthLevelPlaceholder();
    }

    double? resolvedUserOneRepMax;
    if (userOneRepMax != null && userOneRepMax! > 0) {
      resolvedUserOneRepMax = userOneRepMax!;
    } else {
      final historyAsync = ref.watch(
        exerciseHistoryDataGroupedProvider(exerciseName),
      );

      if (historyAsync.isLoading) {
        return const LoadingIndicator();
      }

      if (historyAsync.hasError || !historyAsync.hasValue) {
        return const _StrengthLevelPlaceholder();
      }

      final allSets = <ExerciseHistoryData>[];
      historyAsync.value!.forEach((_, sets) => allSets.addAll(sets));
      resolvedUserOneRepMax = _calculateBestOneRepMax(allSets);
    }

    if (resolvedUserOneRepMax <= 0) {
      return const _StrengthLevelPlaceholder();
    }

    return _StrengthLevelContent(
      standard: standard,
      userBodyweight: userBodyweight,
      userOneRepMax: resolvedUserOneRepMax,
    );
  }

  double _calculateBestOneRepMax(List<ExerciseHistoryData> allSets) {
    double bestOneRepMax = 0.0;
    for (final set in allSets) {
      if (set.weight == null || set.reps == null || set.reps! <= 0) {
        continue;
      }

      final calculated = OneRMCalculator.calculateBrzycki(
        set.weight!,
        set.reps!,
      );
      if (calculated > bestOneRepMax) {
        bestOneRepMax = calculated;
      }
    }

    return bestOneRepMax;
  }
}

class _StrengthLevelContent extends StatelessWidget {
  const _StrengthLevelContent({
    required this.standard,
    required this.userBodyweight,
    required this.userOneRepMax,
  });

  final StrengthStandard standard;
  final double userBodyweight;
  final double userOneRepMax;

  @override
  Widget build(BuildContext context) {
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

      if (userOneRepMax >= levelValue) {
        currentLevel = level;

        if (i < levels.length - 1) {
          final nextLevel = levels[i + 1];
          final nextValue = levelValues[nextLevel];

          if (nextValue != null && nextValue > levelValue) {
            progressToNext =
                ((userOneRepMax - levelValue) / (nextValue - levelValue)).clamp(
                  0.0,
                  1.0,
                );
          }
        }
      } else {
        break;
      }
    }

    final levelColor = _getLevelColor(context, currentLevel);
    final locale = Localizations.localeOf(context).languageCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: levelColor.withValues(alpha: 0.1),
            borderRadius: AppBorderRadius.smRadius,
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
                '${userOneRepMax.toStringAsFixed(1)} kg',
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.onSurface,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: levelColor,
                borderRadius: AppBorderRadius.xsRadius,
              ),
              child: Text(
                currentLevel.getLabel(locale).toUpperCase(),
                style: context.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.surface,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
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
        const SizedBox(height: AppSpacing.sm),
        if (currentLevel != ExperienceLevel.elite) ...[
          ClipRRect(
            borderRadius: AppBorderRadius.xsRadius,
            child: LinearProgressIndicator(
              value: progressToNext,
              minHeight: 8,
              backgroundColor: context.colors.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(levelColor),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: context.colors.surfaceContainerHighest.withValues(
              alpha: 0.5,
            ),
            borderRadius: AppBorderRadius.smRadius,
          ),
          child: Column(
            children: [
              ...levels.map((level) {
                final value = levelValues[level];
                if (value == null) return const SizedBox.shrink();

                final isCurrentLevel = level == currentLevel;
                final color = _getLevelColor(context, level);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
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
                      const SizedBox(width: AppSpacing.sm),
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
              const SizedBox(height: AppSpacing.xs),
              const Divider(height: 1),
              const SizedBox(height: AppSpacing.xs),
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

  Color _getLevelColor(BuildContext context, ExperienceLevel level) {
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
}

class _StrengthLevelPlaceholder extends StatelessWidget {
  const _StrengthLevelPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SemanticIcon(
          icon: AppIcons.infoOutline,
          semanticLabel: 'Info outline',
          size: AppIconSize.xxlarge,
          color: context.colors.onSurface.withValues(alpha: 0.3),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          context.l10n.strengthLevelNoData,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xxs),
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
}
