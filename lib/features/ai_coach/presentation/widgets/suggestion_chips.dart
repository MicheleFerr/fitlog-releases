/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/presentation/widgets
/// 🎯 Feature: ai_coach
/// 🔧 Type: widget
///
/// Suggestion Chips - Quick query suggestions for AI Coach
///
/// **Purpose**: Display clickable chips with common query examples
///
/// **Features**:
/// - Common queries: PR, volume analysis, workout review
/// - Localized suggestions
/// - Design system compliant
/// - Auto-send message on tap
///
/// **Usage**:
/// ```dart
/// SuggestionChips(
///   onSuggestionTap: (query) {
///     _sendMessage(query);
///   },
/// )
/// ```
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Suggestion chip data model
class SuggestionChip {
  final String label;
  final String query;
  final IconData icon;

  const SuggestionChip({
    required this.label,
    required this.query,
    required this.icon,
  });
}

/// Suggestion chips widget
class SuggestionChips extends StatelessWidget {
  final Function(String query) onSuggestionTap;

  const SuggestionChips({
    super.key,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    final suggestions = _buildSuggestions(context);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: suggestions.map((suggestion) {
        return _SuggestionChipButton(
          suggestion: suggestion,
          onTap: () => onSuggestionTap(suggestion.query),
        );
      }).toList(),
    );
  }

  /// Build localized suggestions
  List<SuggestionChip> _buildSuggestions(BuildContext context) {
    return [
      SuggestionChip(
        label: context.l10n.showPR,
        query: context.l10n.showPR,
        icon: AppIcons.stars,
      ),
      SuggestionChip(
        label: context.l10n.analyzeVolume,
        query: context.l10n.analyzeVolume,
        icon: AppIcons.analytics,
      ),
      SuggestionChip(
        label: context.l10n.howIsTraining,
        query: context.l10n.howIsTraining,
        icon: AppIcons.workout,
      ),
      SuggestionChip(
        label: context.l10n.needRest,
        query: context.l10n.needRest,
        icon: AppIcons.bedtime,
      ),
    ];
  }
}

/// Single suggestion chip button
class _SuggestionChipButton extends StatelessWidget {
  final SuggestionChip suggestion;
  final VoidCallback onTap;

  const _SuggestionChipButton({
    required this.suggestion,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SemanticIcon(
                icon: suggestion.icon,
                semanticLabel: suggestion.label,
                size: AppIconSize.small,
                color: context.colors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                suggestion.label,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
