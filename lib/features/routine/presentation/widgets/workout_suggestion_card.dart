import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/suggestion_level.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_suggestion.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Workout suggestion card widget
///
/// Displays the predicted next workout with confidence level, reasoning,
/// and action buttons. Uses the 4-level fallback hierarchy from
/// RoutinePredictionEngine.
///
/// Example:
/// ```dart
/// WorkoutSuggestionCard(
///   suggestion: WorkoutSuggestion(...),
///   onStartWorkout: (name) => _startWorkout(name),
///   onShowAlternatives: () => _showAlternativesDialog(),
/// )
/// ```
class WorkoutSuggestionCard extends StatelessWidget {

  const WorkoutSuggestionCard({
    super.key,
    required this.suggestion,
    this.onStartWorkout,
    this.onShowAlternatives,
    this.onWhyThisSuggestion,
  });
  final WorkoutSuggestion suggestion;
  final void Function(String workoutName)? onStartWorkout;
  final VoidCallback? onShowAlternatives;
  final VoidCallback? onWhyThisSuggestion;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Title + Level Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    context.l10n.suggestedNextWorkout,
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildLevelBadge(context),
              ],
            ),
            const SizedBox(height: 16),

            // Main suggestion: Workout Name
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  SemanticIcon(
  icon: AppIcons.workout,
  semanticLabel: 'Workout',
  size: AppIconSize.xlarge,
  color: context.colors.onPrimaryContainer,
),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatWorkoutName(suggestion.workoutName),
                          style: context.textTheme.headlineMedium?.copyWith(
                            color: context.colors.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // ✅ NEW: Show scheduled date if available
                        if (suggestion.scheduledDate != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            _formatScheduledDate(suggestion.scheduledDate!),
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colors.onPrimaryContainer.withValues(alpha: 0.8),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Confidence indicator
            _buildConfidenceBar(context),
            const SizedBox(height: 12),

            // Reason text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SemanticIcon(
  icon: AppIcons.infoOutlined,
  semanticLabel: 'Info outlined',
  size: AppIconSize.small,
  color: context.colors.onSurfaceVariant,
),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      suggestion.reason,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Pattern info (if available)
            if (suggestion.patternInfo != null) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 28),
                child: Text(
                  suggestion.patternInfo!,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: onStartWorkout != null
                        ? () => onStartWorkout!(suggestion.workoutName)
                        : null,
                    icon: const SemanticIcon(
  icon: AppIcons.play,
  semanticLabel: 'Play',
),
                    label: Text(context.l10n.startThisWorkout),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onShowAlternatives,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(context.l10n.alternatives)
                  ),
                ),
              ],
            ),

            // "Why this?" link
            if (onWhyThisSuggestion != null)
              Center(
                child: TextButton.icon(
                  onPressed: onWhyThisSuggestion,
                  icon: const SemanticIcon(
  icon: AppIcons.help,
  semanticLabel: 'Help',
  size: AppIconSize.small,
),
                  label: Text(context.l10n.whyThisSuggestion),
                  style: TextButton.styleFrom(
                    textStyle: context.textTheme.bodySmall,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Build level badge (Pattern/Routine/Frequency/DayBased)
  Widget _buildLevelBadge(BuildContext context) {
    final Color badgeColor;
    final Color textColor;
    final IconData icon;

    switch (suggestion.level) {
      case SuggestionLevel.pattern:
        badgeColor = context.colors.tertiary;
        textColor = context.colors.onTertiary;
        icon = AppIcons.autoAwesome;
      case SuggestionLevel.routine:
        badgeColor = context.colors.primary;
        textColor = context.colors.onPrimary;
        icon = AppIcons.calendar;
      case SuggestionLevel.frequency:
        badgeColor = context.colors.secondary;
        textColor = context.colors.onSecondary;
        icon = AppIcons.trendUp;
      case SuggestionLevel.dayBased:
        badgeColor = context.colors.surfaceContainerHighest;
        textColor = context.colors.onSurfaceVariant;
        icon = AppIcons.today;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            _getLevelDisplayName(context, suggestion.level),
            style: context.textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Build confidence progress bar
  Widget _buildConfidenceBar(BuildContext context) {
    final Color barColor;
    switch (suggestion.level) {
      case SuggestionLevel.pattern:
        barColor = context.colors.tertiary;
      case SuggestionLevel.routine:
        barColor = context.colors.primary;
      case SuggestionLevel.frequency:
        barColor = context.colors.secondary;
      case SuggestionLevel.dayBased:
        barColor = context.colors.surfaceContainerHighest;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.confidence,
              style: context.textTheme.labelMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            Text(
              suggestion.displayConfidence,
              style: context.textTheme.labelMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: suggestion.confidence,
            minHeight: 8,
            backgroundColor: context.colors.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(barColor),
          ),
        ),
      ],
    );
  }

  /// Format workout name (capitalize first letter)
  String _formatWorkoutName(String name) {
    if (name.isEmpty) return name;
    return name[0].toUpperCase() + name.substring(1);
  }

  /// Get level display name
  String _getLevelDisplayName(BuildContext context, SuggestionLevel level) {
    switch (level) {
      case SuggestionLevel.pattern:
        return context.l10n.levelPattern;
      case SuggestionLevel.routine:
        return context.l10n.levelRoutine;
      case SuggestionLevel.frequency:
        return context.l10n.levelFrequent;
      case SuggestionLevel.dayBased:
        return context.l10n.levelDefault;
    }
  }

  /// Format scheduled date for display
  ///
  /// Returns: "Questo è l'allenamento che dovresti fare il dd/mm/yyyy"
  String _formatScheduledDate(DateTime date) {
    final formatter = DateFormat('dd/MM/yyyy');
    final formattedDate = formatter.format(date);
    return 'Questo è l\'allenamento che dovresti fare il $formattedDate';
  }
}

/// Empty state widget when no suggestion available
class WorkoutSuggestionEmptyState extends StatelessWidget {

  const WorkoutSuggestionEmptyState({
    super.key,
    this.onCreateWorkout,
  });
  final VoidCallback? onCreateWorkout;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SemanticIcon(
  icon: AppIcons.autoAwesomeOutlined,
  semanticLabel: 'Auto awesome outlined',
  size: AppIconSize.medium,
  color: context.colors.onSurfaceVariant.withValues(alpha: 0.5,
),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.notEnoughWorkoutData,
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.completeWorkoutsForSuggestions,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (onCreateWorkout != null) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onCreateWorkout,
                icon: const SemanticIcon(
  icon: AppIcons.add,
  semanticLabel: 'Add',
),
                label: Text(context.l10n.createWorkout),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Loading state widget
class WorkoutSuggestionLoadingState extends StatelessWidget {
  const WorkoutSuggestionLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const LoadingIndicator(),
              const SizedBox(height: 16),
              Text(context.l10n.analyzingWorkoutPattern),
            ],
          ),
        ),
      ),
    );
  }
}
