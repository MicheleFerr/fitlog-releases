/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/analytics/presentation/widgets
/// Feature: analytics
/// Type: widget
///
/// Rep Zone Optimization Sheet v2 - Modal for optimizing training variety
///
/// **v2 Changes**:
/// - Removed mode selector (swipe vs list) - goes directly to swipe
/// - Shows analysis summary at top
/// - More suggestions with detailed scoring
///
/// **Trigger**:
/// - Shows when variety < 80% (one zone is dominant)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/rep_zone_suggestion.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/rep_zone_suggestion_deck.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Rep Zone Optimization Sheet v2 - Modal for training variety optimization
class RepZoneOptimizationSheet extends ConsumerStatefulWidget {
  const RepZoneOptimizationSheet({
    required this.suggestions,
    required this.analysis,
    super.key,
  });

  /// Pre-loaded suggestions
  final List<RepZoneSuggestion> suggestions;

  /// Current rep zone analysis
  final RepZoneAnalysis analysis;

  @override
  ConsumerState<RepZoneOptimizationSheet> createState() =>
      _RepZoneOptimizationSheetState();
}

class _RepZoneOptimizationSheetState
    extends ConsumerState<RepZoneOptimizationSheet> {
  bool _isComplete = false;
  final Set<String> _addedExerciseIds = {};

  /// Get filtered suggestions (excluding already added exercises)
  List<RepZoneSuggestion> get _filteredSuggestions => widget.suggestions
      .where((s) => !_addedExerciseIds.contains(s.exerciseId))
      .toList();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;
    final l10n = context.l10n;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    AppIcons.autoAwesome,
                    color: colorScheme.primary,
                    size: AppIconSize.medium,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.optimizeTraining,
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        l10n.optimizeTrainingDirect,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    AppIcons.close,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Analysis summary (compact)
          _buildCompactAnalysis(context),

          const Divider(height: 1),

          // Suggestion deck or completion state
          Flexible(
            child: _isComplete
                ? _buildCompletionState(context)
                : _buildSuggestionView(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactAnalysis(BuildContext context) {
    final colorScheme = context.colors;
    final l10n = context.l10n;
    final analysis = widget.analysis;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            AppIcons.warning,
            color: colorScheme.error,
            size: AppIconSize.small,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.lowVarietyDetected,
                  style: context.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.error,
                  ),
                ),
                const SizedBox(height: 4),
                // Compact distribution
                Row(
                  children: [
                    _CompactZoneBadge(
                      zone: RepZone.strength,
                      percentage: analysis.strengthPercentage,
                      isDominant: analysis.dominantZone == RepZone.strength,
                    ),
                    const SizedBox(width: 8),
                    _CompactZoneBadge(
                      zone: RepZone.hypertrophy,
                      percentage: analysis.hypertrophyPercentage,
                      isDominant: analysis.dominantZone == RepZone.hypertrophy,
                    ),
                    const SizedBox(width: 8),
                    _CompactZoneBadge(
                      zone: RepZone.endurance,
                      percentage: analysis.endurancePercentage,
                      isDominant: analysis.dominantZone == RepZone.endurance,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Suggestions count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${widget.suggestions.length}',
              style: context.textTheme.labelLarge?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionView(BuildContext context) {
    final suggestions = _filteredSuggestions;

    // Check if all suggestions have been added
    if (suggestions.isEmpty) {
      return _buildCompletionState(context);
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: RepZoneSuggestionDeck(
        key: ValueKey('deck_${suggestions.length}'),
        suggestions: suggestions,
        onComplete: () {
          setState(() => _isComplete = true);
        },
        onSuggestionAdded: () {
          // Track will be done via onExerciseAdded
        },
        onExerciseAdded: (exerciseId) {
          setState(() {
            _addedExerciseIds.add(exerciseId);
          });
        },
      ),
    );
  }

  Widget _buildCompletionState(BuildContext context) {
    final colorScheme = context.colors;
    final l10n = context.l10n;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                AppIcons.checkCircle,
                size: 64,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.optimizationComplete,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.optimizationCompleteSubtitle,
              style: context.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (_addedExerciseIds.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l10n.exercisesAddedCount(_addedExerciseIds.length),
                  style: context.textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(AppIcons.check),
              label: Text(l10n.done),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact zone badge showing percentage
class _CompactZoneBadge extends StatelessWidget {
  const _CompactZoneBadge({
    required this.zone,
    required this.percentage,
    required this.isDominant,
  });

  final RepZone zone;
  final double percentage;
  final bool isDominant;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;
    final zoneColor = _getZoneColor(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDominant
            ? colorScheme.error.withValues(alpha: 0.2)
            : zoneColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: isDominant
            ? Border.all(color: colorScheme.error.withValues(alpha: 0.5))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getZoneInitial(),
            style: context.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDominant ? colorScheme.error : zoneColor,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '${percentage.toStringAsFixed(0)}%',
            style: context.textTheme.labelSmall?.copyWith(
              fontWeight: isDominant ? FontWeight.bold : FontWeight.normal,
              color: isDominant ? colorScheme.error : colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  String _getZoneInitial() {
    switch (zone) {
      case RepZone.strength:
        return 'F'; // Forza
      case RepZone.hypertrophy:
        return 'I'; // Ipertrofia
      case RepZone.endurance:
        return 'R'; // Resistenza
    }
  }

  Color _getZoneColor(BuildContext context) {
    final colorScheme = context.colors;
    switch (zone) {
      case RepZone.strength:
        return colorScheme.error;
      case RepZone.hypertrophy:
        return colorScheme.primary;
      case RepZone.endurance:
        return colorScheme.tertiary;
    }
  }
}
