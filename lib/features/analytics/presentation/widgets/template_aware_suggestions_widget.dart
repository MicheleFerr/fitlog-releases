/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/analytics/presentation/widgets
/// Feature: analytics
/// Type: widget
///
/// Template-Aware Exercise Suggestions Widget
///
/// Orchestrator widget that:
/// - Loads async data (coverage, adjusted muscles, suggestions, templates)
/// - Renders [MusclePriorityCard] for each neglected muscle
/// - Shows coverage summary header
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/template_coverage.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/exercise_suggestion_engine.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/neglected_muscle_detector.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/exercise_suggestion_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/template_coverage_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/muscle_priority_card.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

/// Template-Aware Exercise Suggestions Widget
///
/// Orchestrator that loads async data and renders [MusclePriorityCard]
/// for each neglected muscle group with inline template selector
/// and horizontal exercise grid.
///
/// **Features**:
/// - "Planned" badge for muscles covered by templates
/// - Adjusted severity based on template coverage
/// - Inline template selector per card
/// - Horizontal Netflix-style exercise grid
///
/// **Usage**:
/// ```dart
/// TemplateAwareSuggestionsWidget(
///   neglectedMuscles: detector.detectNeglectedMuscles(balance),
///   onExerciseAdded: () => ref.invalidate(templateCoverageProvider),
/// )
/// ```
class TemplateAwareSuggestionsWidget extends ConsumerWidget {
  const TemplateAwareSuggestionsWidget({
    required this.neglectedMuscles,
    this.onExerciseAdded,
    super.key,
  });

  final List<NeglectedMuscle> neglectedMuscles;
  final VoidCallback? onExerciseAdded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    // Watch all async data
    final coverageAsync = ref.watch(templateCoverageProvider);
    final adjustedAsync = ref.watch(
      adjustedNeglectedMusclesProvider(
        AdjustedNeglectedParams(neglectedMuscles: neglectedMuscles),
      ),
    );
    final suggestionsAsync = ref.watch(
      exerciseSuggestionsGroupedProvider(
        ExerciseSuggestionParams(neglectedMuscles: neglectedMuscles),
      ),
    );
    final templatesAsync = ref.watch(customWorkoutTemplatesProvider);

    // Error handling (check first, before loading)
    if (coverageAsync.hasError) {
      return _buildError(context, theme, colorScheme, l10n, coverageAsync.error!);
    }
    if (adjustedAsync.hasError) {
      return _buildError(context, theme, colorScheme, l10n, adjustedAsync.error!);
    }
    if (suggestionsAsync.hasError) {
      return _buildError(context, theme, colorScheme, l10n, suggestionsAsync.error!);
    }
    if (templatesAsync.hasError) {
      return _buildError(context, theme, colorScheme, l10n, templatesAsync.error!);
    }

    // Loading state (any provider still loading without data)
    if (!coverageAsync.hasValue ||
        !adjustedAsync.hasValue ||
        !suggestionsAsync.hasValue ||
        !templatesAsync.hasValue) {
      return _buildLoading(colorScheme);
    }

    // All data available
    return _buildContent(
      context,
      theme,
      colorScheme,
      l10n,
      coverageAsync.value!,
      adjustedAsync.value!,
      suggestionsAsync.value!,
      templatesAsync.value!,
    );
  }

  Widget _buildLoading(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(child: LoadingIndicator()),
    );
  }

  Widget _buildError(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    dynamic l10n,
    Object error,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            AppIcons.error,
            color: colorScheme.error,
            size: AppIconSize.large,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.errorLoadingExercises,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    dynamic l10n,
    TemplateCoverageResult coverage,
    List<AdjustedNeglectedMuscle> adjustedMuscles,
    Map<String, List<ExerciseSuggestion>> suggestionsByMuscle,
    List<WorkoutTemplate> userTemplates,
  ) {
    if (adjustedMuscles.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              AppIcons.checkCircle,
              color: context.colors.success,
              size: AppIconSize.large,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.noNeglectedMuscles,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final coveredCount =
        adjustedMuscles.where((m) => m.hasPlannedExercises).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with coverage summary
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.neglectedMuscles,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (coveredCount > 0)
              Chip(
                avatar: Icon(
                  AppIcons.schedule,
                  size: AppIconSize.tiny,
                  color: colorScheme.onSecondaryContainer,
                ),
                label: Text('$coveredCount ${l10n.planned}'),
                backgroundColor: colorScheme.secondaryContainer,
                side: BorderSide.none,
                visualDensity: VisualDensity.compact,
                labelStyle: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Muscle priority cards (new redesigned layout)
        ...adjustedMuscles.map((adjusted) {
          final suggestions =
              suggestionsByMuscle[adjusted.muscleName] ?? [];

          return MusclePriorityCard(
            adjustedMuscle: adjusted,
            suggestions: suggestions,
            coverage: coverage,
            userTemplates: userTemplates,
            onExerciseAdded: onExerciseAdded,
          );
        }),
      ],
    );
  }
}
