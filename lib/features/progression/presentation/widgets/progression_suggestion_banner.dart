import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/progression/domain/entities/progression_suggestion.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Banner widget to display progressive overload suggestions
///
/// Shows exercise progression advice with visual confidence indicators
/// Part of P2 retention features (+25-30% long-term retention)
class ProgressionSuggestionBanner extends StatelessWidget {
  const ProgressionSuggestionBanner({
    required this.suggestion,
    this.onDismiss,
    super.key,
  });

  final ProgressionSuggestion suggestion;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getBorderColor(context),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: context.colors.onSurface.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with exercise name and dismiss button
            Row(
              children: [
                _buildConfidenceIcon(context),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    suggestion.exerciseName,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colors.onSurface,
                    ),
                  ),
                ),
                if (onDismiss != null)
                  IconButton(
                    icon: const Icon(AppIcons.close, size: AppIconSize.small),
                    onPressed: onDismiss,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    color: context.colors.onSurfaceVariant,
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Weight progression
            Row(
              children: [
                Text(
                  '${_formatWeight(suggestion.currentWeight)}kg → ${_formatWeight(suggestion.suggestedWeight)}kg',
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getProgressionColor(context),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.colors.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${suggestion.targetReps} reps',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Reason
            Text(
              suggestion.reason,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),

            // Additional notes (if provided)
            if (suggestion.additionalNotes != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      AppIcons.info,
                      size: AppIconSize.tiny,
                      color: context.colors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        suggestion.additionalNotes!,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Get confidence icon based on suggestion confidence level
  Widget _buildConfidenceIcon(BuildContext context) {
    IconData icon;
    Color color;

    switch (suggestion.confidence) {
      case ProgressionConfidence.high:
        icon = AppIcons.trendUp;
        color = context.colors.success;
      case ProgressionConfidence.medium:
        icon = AppIcons.trendFlat;
        color = context.colors.warning;
      case ProgressionConfidence.low:
        icon = AppIcons.info;
        color = context.colors.onSurfaceVariant;
    }

    return Icon(icon, size: AppIconSize.medium, color: color);
  }

  /// Get border color based on confidence level
  Color _getBorderColor(BuildContext context) {
    switch (suggestion.confidence) {
      case ProgressionConfidence.high:
        return context.colors.success.withValues(alpha: 0.5);
      case ProgressionConfidence.medium:
        return context.colors.warning.withValues(alpha: 0.5);
      case ProgressionConfidence.low:
        return context.colors.onSurfaceVariant.withValues(alpha: 0.3);
    }
  }

  /// Get color for weight progression text
  Color _getProgressionColor(BuildContext context) {
    if (suggestion.suggestedWeight > suggestion.currentWeight) {
      return context.colors.success; // Weight increase
    } else if (suggestion.suggestedWeight < suggestion.currentWeight) {
      return context.colors.warning; // Weight decrease
    } else {
      return context.colors.onSurface; // No change
    }
  }

  /// Format weight to show clean numbers (80 instead of 80.0, but keep 82.5)
  String _formatWeight(double weight) {
    if (weight == weight.roundToDouble()) {
      return weight.toInt().toString();
    }
    return weight.toString();
  }
}
