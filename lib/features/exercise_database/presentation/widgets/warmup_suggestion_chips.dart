/// Clickable chips for warmup exercise suggestions
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/warmup_suggestion.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Displays warmup suggestion chips that can be tapped to add exercises
class WarmupSuggestionChips extends StatelessWidget {
  const WarmupSuggestionChips({
    super.key,
    required this.suggestions,
    required this.addedExerciseIds,
    required this.onAdd,
    this.isLoading = false,
  });

  /// List of warmup suggestions to display
  final List<WarmupSuggestion> suggestions;

  /// Set of exercise IDs already added to workout
  final Set<String> addedExerciseIds;

  /// Callback when user taps to add an exercise
  final void Function(WarmupSuggestion) onAdd;

  /// Whether an add operation is in progress
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    // Group by type
    final mobilityExercises = suggestions
        .where((s) => s.type == WarmupType.mobility)
        .toList();
    final activationExercises = suggestions
        .where((s) => s.type == WarmupType.activation)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (mobilityExercises.isNotEmpty) ...[
          _buildTypeHeader(context, WarmupType.mobility),
          const SizedBox(height: 8),
          _buildChipsRow(context, mobilityExercises),
          const SizedBox(height: 16),
        ],
        if (activationExercises.isNotEmpty) ...[
          _buildTypeHeader(context, WarmupType.activation),
          const SizedBox(height: 8),
          _buildChipsRow(context, activationExercises),
        ],
      ],
    );
  }

  Widget _buildTypeHeader(BuildContext context, WarmupType type) {
    final (icon, label) = switch (type) {
      WarmupType.mobility => (
        '🔄',
        context.l10n.warmupPhase1Title.replaceAll('🔄 ', ''),
      ),
      WarmupType.activation => (
        '⚡',
        context.l10n.warmupPhase2Title.replaceAll('⚡ ', ''),
      ),
    };

    return Row(
      children: [
        Text(icon, style: context.textTheme.bodyMedium),
        const SizedBox(width: 6),
        Text(
          label,
          style: context.textTheme.labelMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildChipsRow(BuildContext context, List<WarmupSuggestion> items) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((suggestion) {
        final isAdded = addedExerciseIds.contains(suggestion.exerciseId);
        return _WarmupChip(
          suggestion: suggestion,
          isAdded: isAdded,
          isLoading: isLoading,
          onTap: isAdded ? null : () => onAdd(suggestion),
        );
      }).toList(),
    );
  }
}

class _WarmupChip extends StatelessWidget {
  const _WarmupChip({
    required this.suggestion,
    required this.isAdded,
    required this.isLoading,
    this.onTap,
  });

  final WarmupSuggestion suggestion;
  final bool isAdded;
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = isAdded ? context.colors.success : context.colors.primary;

    return Material(
      color: context.colors.surface.withValues(alpha: 0),
      child: InkWell(
        onTap: onTap != null
            ? () {
                HapticFeedback.lightImpact();
                onTap!();
              }
            : null,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isAdded ? 0.15 : 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: isAdded ? 0.4 : 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isAdded
                    ? Icon(
                        AppIcons.check,
                        key: const ValueKey('check'),
                        size: 16,
                        color: color,
                      )
                    : Icon(
                        AppIcons.add,
                        key: const ValueKey('add'),
                        size: 16,
                        color: color,
                      ),
              ),
              const SizedBox(width: 6),
              // Name and reps
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    suggestion.exerciseName,
                    style: context.textTheme.labelMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${suggestion.sets}×${suggestion.reps}',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: color.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
