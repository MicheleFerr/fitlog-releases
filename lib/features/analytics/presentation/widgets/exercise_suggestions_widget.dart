/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/widgets
/// 🎯 Feature: analytics
/// 🔧 Type: widget
///
/// Exercise Suggestions Widget - Actionable UI for neglected muscle suggestions
///
/// **Features**:
/// - Uses real exercise database (1500+ exercises)
/// - Lists neglected muscles with severity badges
/// - Exercise recommendations with difficulty labels
/// - "Add to Template" buttons that open template selector
/// - Priority-based sorting
/// - Correct countingMode from database
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/exercise_suggestion_engine.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/neglected_muscle_detector.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/exercise_suggestion_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/add_exercise_to_template_sheet.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/priority_explanation_sheet.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';

/// Exercise Suggestions Widget - Shows neglected muscles with exercise suggestions
///
/// Automatically filters out exercises that are already in user's templates.
///
/// **Usage**:
/// ```dart
/// ExerciseSuggestionsWidget(
///   neglectedMuscles: detector.detectNeglectedMuscles(balance),
///   onExerciseAdded: () {
///     // Called when exercise is added to a template
///   },
/// )
/// ```
class ExerciseSuggestionsWidget extends ConsumerWidget {
  const ExerciseSuggestionsWidget({
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

    // Watch the async provider for suggestions from real database
    final suggestionsAsync = ref.watch(
      exerciseSuggestionsGroupedProvider(
        ExerciseSuggestionParams(neglectedMuscles: neglectedMuscles),
      ),
    );

    return suggestionsAsync.when(
      loading: () => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: LoadingIndicator()),
      ),
      error: (error, _) => Container(
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
      ),
      data: (suggestionsByMuscle) {
        if (suggestionsByMuscle.isEmpty) {
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

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.neglectedMuscles,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...suggestionsByMuscle.entries.map((entry) {
              final muscleName = entry.key;
              final suggestions = entry.value;
              final neglectedMuscle = neglectedMuscles.firstWhere(
                (m) => m.muscleName == muscleName,
              );

              return _MuscleGroupCard(
                neglectedMuscle: neglectedMuscle,
                suggestions: suggestions,
                onExerciseAdded: onExerciseAdded,
              );
            }),
          ],
        );
      },
    );
  }
}

/// Muscle Group Card - Shows one neglected muscle with its exercise suggestions
class _MuscleGroupCard extends StatelessWidget {
  const _MuscleGroupCard({
    required this.neglectedMuscle,
    required this.suggestions,
    this.onExerciseAdded,
  });

  final NeglectedMuscle neglectedMuscle;
  final List<ExerciseSuggestion> suggestions;
  final VoidCallback? onExerciseAdded;

  void _showPriorityExplanation(BuildContext context, NeglectedMuscle muscle) {
    HapticFeedback.selectionClick();
    ModalService.showSheet<void>(context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => PriorityExplanationSheet(neglectedMuscle: muscle),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getSeverityColor(context, neglectedMuscle.severity),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Muscle name + severity badge
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getSeverityColor(
                context,
                neglectedMuscle.severity,
              ).withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    neglectedMuscle.muscleName.toUpperCase(),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _SeverityBadge(severity: neglectedMuscle.severity),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () =>
                      _showPriorityExplanation(context, neglectedMuscle),
                  child: Chip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${l10n.priority}: ${neglectedMuscle.priority.toStringAsFixed(1)}',
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          AppIcons.info,
                          size: AppIconSize.tiny,
                          color: colorScheme.onTertiaryContainer,
                        ),
                      ],
                    ),
                    backgroundColor: colorScheme.tertiaryContainer,
                    side: BorderSide.none,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ),

          // Exercise suggestions
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.exerciseSuggestions,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...suggestions.map((suggestion) {
                  return _ExerciseSuggestionTile(
                    suggestion: suggestion,
                    onExerciseAdded: onExerciseAdded,
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(BuildContext context, NeglectSeverity severity) {
    switch (severity) {
      case NeglectSeverity.critical:
        return context.colors.error;
      case NeglectSeverity.high:
        return context.colors.warning;
      case NeglectSeverity.medium:
        return context.colors.tertiary;
    }
  }
}

/// Severity Badge - Shows severity level with color
class _SeverityBadge extends StatelessWidget {
  const _SeverityBadge({required this.severity});

  final NeglectSeverity severity;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final label = _getSeverityLabel(l10n, severity);
    final color = _getSeverityColor(context, severity);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: context.textTheme.labelSmall!.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getSeverityLabel(dynamic l10n, NeglectSeverity severity) {
    switch (severity) {
      case NeglectSeverity.critical:
        return l10n.severityCritical;
      case NeglectSeverity.high:
        return l10n.severityHigh;
      case NeglectSeverity.medium:
        return l10n.severityMedium;
    }
  }

  Color _getSeverityColor(BuildContext context, NeglectSeverity severity) {
    switch (severity) {
      case NeglectSeverity.critical:
        return context.colors.error;
      case NeglectSeverity.high:
        return context.colors.warning;
      case NeglectSeverity.medium:
        return context.colors.tertiary;
    }
  }
}

/// Exercise Suggestion Tile - Shows one exercise with "Add to Template" button
class _ExerciseSuggestionTile extends StatelessWidget {
  const _ExerciseSuggestionTile({
    required this.suggestion,
    this.onExerciseAdded,
  });

  final ExerciseSuggestion suggestion;
  final VoidCallback? onExerciseAdded;

  void _openTemplateSelector(BuildContext context) {
    HapticFeedback.selectionClick();
    ModalService.showSheet<void>(context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => AddExerciseToTemplateSheet(
        suggestion: suggestion,
        onExerciseAdded: () {
          onExerciseAdded?.call();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          // Exercise GIF thumbnail
          if (suggestion.imageUrl != null && suggestion.imageUrl!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: suggestion.imageUrl!,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 56,
                    height: 56,
                    color: colorScheme.surfaceContainerHighest,
                    child: Center(
                      child: Icon(
                        AppIcons.workout,
                        size: AppIconSize.medium,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 56,
                    height: 56,
                    color: colorScheme.surfaceContainerHighest,
                    child: Center(
                      child: Icon(
                        AppIcons.workout,
                        size: AppIconSize.medium,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          // Exercise info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        suggestion.exerciseName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _DifficultyChip(difficulty: suggestion.difficulty),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  suggestion.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Add to template button
          IconButton(
            onPressed: () => _openTemplateSelector(context),
            icon: const Icon(AppIcons.add, size: AppIconSize.medium),
            style: IconButton.styleFrom(
              backgroundColor: colorScheme.primaryContainer,
              foregroundColor: colorScheme.onPrimaryContainer,
            ),
            tooltip: l10n.addToTemplate,
          ),
        ],
      ),
    );
  }
}

/// Difficulty Chip - Shows exercise difficulty level
class _DifficultyChip extends StatelessWidget {
  const _DifficultyChip({required this.difficulty});

  final ExerciseDifficulty difficulty;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final label = _getDifficultyLabel(l10n, difficulty);
    final color = _getDifficultyColor(context, difficulty);

    return Chip(
      label: Text(label),
      backgroundColor: color.withValues(alpha: 0.2),
      side: BorderSide(color: color),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      labelStyle: context.textTheme.labelSmall!.copyWith(
        color: color,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  String _getDifficultyLabel(dynamic l10n, ExerciseDifficulty difficulty) {
    switch (difficulty) {
      case ExerciseDifficulty.beginner:
        return l10n.difficultyBeginner;
      case ExerciseDifficulty.intermediate:
        return l10n.difficultyIntermediate;
      case ExerciseDifficulty.advanced:
        return l10n.difficultyAdvanced;
    }
  }

  Color _getDifficultyColor(
    BuildContext context,
    ExerciseDifficulty difficulty,
  ) {
    switch (difficulty) {
      case ExerciseDifficulty.beginner:
        return context.colors.success;
      case ExerciseDifficulty.intermediate:
        return context.colors.warning;
      case ExerciseDifficulty.advanced:
        return context.colors.error;
    }
  }
}
