/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/widgets
/// 🎯 Feature: analytics
/// 🔧 Type: widget
///
/// Template-Aware Exercise Suggestions Widget
///
/// Enhanced version of ExerciseSuggestionsWidget that:
/// - Shows "Planned" badge for muscles covered by templates
/// - Lists covering templates below muscle name
/// - Shows which template contains each exercise
/// - Allows toggle to show/hide planned exercises
/// - Adjusts severity based on template coverage
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/template_coverage.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/exercise_suggestion_engine.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/neglected_muscle_detector.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/exercise_suggestion_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/template_coverage_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/add_exercise_to_template_sheet.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/priority_explanation_sheet.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

/// Template-Aware Exercise Suggestions Widget
///
/// Shows neglected muscles with exercise suggestions, enhanced with
/// template coverage information.
///
/// **Features**:
/// - "Planned" badge for muscles covered by templates
/// - Adjusted severity based on template coverage
/// - Toggle to show/hide exercises already in templates
/// - Template names displayed for covered muscles/exercises
///
/// **Usage**:
/// ```dart
/// TemplateAwareSuggestionsWidget(
///   neglectedMuscles: detector.detectNeglectedMuscles(balance),
///   onExerciseAdded: () => ref.invalidate(templateCoverageProvider),
/// )
/// ```
class TemplateAwareSuggestionsWidget extends ConsumerStatefulWidget {
  const TemplateAwareSuggestionsWidget({
    required this.neglectedMuscles,
    this.onExerciseAdded,
    super.key,
  });

  final List<NeglectedMuscle> neglectedMuscles;
  final VoidCallback? onExerciseAdded;

  @override
  ConsumerState<TemplateAwareSuggestionsWidget> createState() =>
      _TemplateAwareSuggestionsWidgetState();
}

class _TemplateAwareSuggestionsWidgetState
    extends ConsumerState<TemplateAwareSuggestionsWidget> {
  bool _showPlannedExercises = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    // Watch template coverage
    final coverageAsync = ref.watch(templateCoverageProvider);

    // Watch adjusted neglected muscles
    final adjustedAsync = ref.watch(
      adjustedNeglectedMusclesProvider(
        AdjustedNeglectedParams(neglectedMuscles: widget.neglectedMuscles),
      ),
    );

    // Watch suggestions
    final suggestionsAsync = ref.watch(
      exerciseSuggestionsGroupedProvider(
        ExerciseSuggestionParams(neglectedMuscles: widget.neglectedMuscles),
      ),
    );

    // Combine all async data
    return coverageAsync.when(
      loading: () => _buildLoading(colorScheme),
      error: (e, _) => _buildError(context, theme, colorScheme, l10n, e),
      data: (coverage) => adjustedAsync.when(
        loading: () => _buildLoading(colorScheme),
        error: (e, _) => _buildError(context, theme, colorScheme, l10n, e),
        data: (adjustedMuscles) => suggestionsAsync.when(
          loading: () => _buildLoading(colorScheme),
          error: (e, _) => _buildError(context, theme, colorScheme, l10n, e),
          data: (suggestionsByMuscle) => _buildContent(
            context,
            theme,
            colorScheme,
            l10n,
            coverage,
            adjustedMuscles,
            suggestionsByMuscle,
          ),
        ),
      ),
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

    // Count how many muscles are covered
    final coveredCount = adjustedMuscles
        .where((m) => m.hasPlannedExercises)
        .length;

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

        // Toggle for showing planned exercises
        if (_hasPlannedExercises(suggestionsByMuscle, coverage))
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Switch.adaptive(
                  value: _showPlannedExercises,
                  onChanged: (value) {
                    setState(() => _showPlannedExercises = value);
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.showPlannedExercises,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 12),

        // Muscle group cards
        ...adjustedMuscles.map((adjusted) {
          final suggestions = suggestionsByMuscle[adjusted.muscleName] ?? [];

          return _TemplateAwareMuscleCard(
            adjustedMuscle: adjusted,
            suggestions: suggestions,
            coverage: coverage,
            showPlannedExercises: _showPlannedExercises,
            onExerciseAdded: widget.onExerciseAdded,
          );
        }),
      ],
    );
  }

  bool _hasPlannedExercises(
    Map<String, List<ExerciseSuggestion>> suggestions,
    TemplateCoverageResult coverage,
  ) {
    for (final list in suggestions.values) {
      for (final s in list) {
        if (coverage.isExercisePlanned(s.exerciseName)) {
          return true;
        }
      }
    }
    return false;
  }
}

/// Template-Aware Muscle Card
///
/// Shows one adjusted neglected muscle with:
/// - Adjusted severity badge
/// - "Planned" badge if covered by templates
/// - List of covering templates
/// - Exercise suggestions with template info
class _TemplateAwareMuscleCard extends StatelessWidget {
  const _TemplateAwareMuscleCard({
    required this.adjustedMuscle,
    required this.suggestions,
    required this.coverage,
    required this.showPlannedExercises,
    this.onExerciseAdded,
  });

  final AdjustedNeglectedMuscle adjustedMuscle;
  final List<ExerciseSuggestion> suggestions;
  final TemplateCoverageResult coverage;
  final bool showPlannedExercises;
  final VoidCallback? onExerciseAdded;

  void _showPriorityExplanation(BuildContext context) {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: context.colors.surface.withValues(alpha: 0),
      builder: (context) =>
          PriorityExplanationSheet(neglectedMuscle: adjustedMuscle.original),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    final severityColor = _getSeverityColor(
      context,
      adjustedMuscle.adjustedSeverity,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: severityColor, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: severityColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Muscle name + badges row
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        adjustedMuscle.muscleName.toUpperCase(),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Severity badge (adjusted)
                    _SeverityBadge(
                      severity: adjustedMuscle.adjustedSeverity,
                      wasReduced: adjustedMuscle.wasSeverityReduced,
                    ),
                    const SizedBox(width: 8),
                    // Planned badge
                    if (adjustedMuscle.hasPlannedExercises)
                      _PlannedBadge(
                        templateCount: adjustedMuscle.coveringTemplates.length,
                      ),
                    const SizedBox(width: 8),
                    // Priority chip
                    GestureDetector(
                      onTap: () => _showPriorityExplanation(context),
                      child: Chip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${l10n.priority}: ${adjustedMuscle.adjustedPriority.toStringAsFixed(1)}',
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

                // Covering templates (if any)
                if (adjustedMuscle.hasPlannedExercises)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Icon(
                          AppIcons.schedule,
                          size: AppIconSize.small,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${l10n.inTemplates}: ${adjustedMuscle.coveringTemplates.join(", ")}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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
                  final isPlanned = coverage.isExercisePlanned(
                    suggestion.exerciseName,
                  );
                  final templates = coverage.getTemplatesForExercise(
                    suggestion.exerciseName,
                  );

                  // Skip planned exercises if toggle is off
                  if (isPlanned && !showPlannedExercises) {
                    return const SizedBox.shrink();
                  }

                  return _TemplateAwareExerciseTile(
                    suggestion: suggestion,
                    isInTemplate: isPlanned,
                    templateNames: templates,
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

/// Severity Badge with optional "reduced" indicator
class _SeverityBadge extends StatelessWidget {
  const _SeverityBadge({required this.severity, this.wasReduced = false});

  final NeglectSeverity severity;
  final bool wasReduced;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final color = _getSeverityColor(context, severity);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getSeverityLabel(l10n, severity),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (wasReduced) ...[
            const SizedBox(width: 4),
            Icon(AppIcons.arrowDropDown, size: AppIconSize.tiny, color: color),
          ],
        ],
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

/// Planned Badge - Shows that muscle is covered by templates
class _PlannedBadge extends StatelessWidget {
  const _PlannedBadge({required this.templateCount});

  final int templateCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            AppIcons.schedule,
            size: AppIconSize.tiny,
            color: colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            l10n.planned,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Template-Aware Exercise Tile
///
/// Shows exercise with template info:
/// - If in template: shows template name with checkmark
/// - If not in template: shows "Add to Template" button
class _TemplateAwareExerciseTile extends StatelessWidget {
  const _TemplateAwareExerciseTile({
    required this.suggestion,
    required this.isInTemplate,
    required this.templateNames,
    this.onExerciseAdded,
  });

  final ExerciseSuggestion suggestion;
  final bool isInTemplate;
  final List<String> templateNames;
  final VoidCallback? onExerciseAdded;

  void _openTemplateSelector(BuildContext context) {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: context.colors.surface.withValues(alpha: 0),
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
        color: isInTemplate
            ? colorScheme.secondaryContainer.withValues(alpha: 0.3)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isInTemplate
              ? colorScheme.secondary.withValues(alpha: 0.3)
              : colorScheme.outline.withValues(alpha: 0.2),
        ),
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
                // Show template name if in template
                if (isInTemplate && templateNames.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(
                          AppIcons.checkCircle,
                          size: AppIconSize.small,
                          color: context.colors.success,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${l10n.inTemplatePrefix}${templateNames.first}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: context.colors.success,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Action button
          if (isInTemplate)
            // Checkmark for exercises already in templates
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.colors.success.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                AppIcons.checkCircle,
                color: context.colors.success,
                size: AppIconSize.medium,
              ),
            )
          else
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

/// Difficulty Chip
class _DifficultyChip extends StatelessWidget {
  const _DifficultyChip({required this.difficulty});

  final ExerciseDifficulty difficulty;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final color = _getDifficultyColor(context, difficulty);

    return Chip(
      label: Text(_getDifficultyLabel(l10n, difficulty)),
      backgroundColor: color.withValues(alpha: 0.2),
      side: BorderSide(color: color),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
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
