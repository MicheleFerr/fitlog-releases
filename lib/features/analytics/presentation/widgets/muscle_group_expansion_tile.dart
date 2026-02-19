/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/widgets
/// 🎯 Feature: analytics
/// 🔧 Type: widget
///
/// MuscleGroupExpansionTile - Accordion tile for muscle group exercises
///
/// **Purpose**: Display a collapsible/expandable tile for a muscle group with its exercises
///
/// **Layout**:
/// ```
/// ┌─────────────────────────────────┐
/// │  💪 Chest               ▼       │ ← Collapsed state
/// └─────────────────────────────────┘
///
/// ┌─────────────────────────────────┐
/// │  💪 Chest               ▲       │ ← Expanded state
/// ├─────────────────────────────────┤
/// │    Exercise Card 1              │
/// │    Exercise Card 2              │
/// │    Exercise Card 3              │
/// └─────────────────────────────────┘
/// ```
///
/// **Features**:
/// - Smooth expand/collapse animation (Material Design)
/// - Theme-aware colors (context.colors)
/// - Localized muscle group names (context.l10n)
/// - No emoji in title (clean UI)
/// - Haptic feedback on expand/collapse
/// - State managed by MuscleGroupExpansionProvider
///
/// **Usage**:
/// ```dart
/// MuscleGroupExpansionTile(
///   muscleGroup: 'Chest',
///   exerciseCount: 5,
///   children: [
///     ExerciseHistoryCard(...),
///     ExerciseHistoryCard(...),
///   ],
/// )
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/muscle_group_expansion_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/mappers/muscle_abbreviation_mapper.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Accordion tile for displaying a muscle group with expandable exercises
///
/// **State Management**: Uses MuscleGroupExpansionProvider for expansion state
class MuscleGroupExpansionTile extends ConsumerWidget {
  const MuscleGroupExpansionTile({
    required this.muscleGroup,
    required this.exerciseCount,
    required this.children,
    super.key,
  });

  /// Muscle group name (e.g., "Chest", "Back", "Legs")
  final String muscleGroup;

  /// Number of exercises in this muscle group
  ///
  /// Displayed in subtitle for quick overview
  final int exerciseCount;

  /// List of exercise widgets (typically ExerciseHistoryCard)
  ///
  /// These are displayed when the tile is expanded
  final List<Widget> children;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch expansion state from provider
    final isExpanded = ref.watch(
      muscleGroupExpansionProvider.select(
        (state) => state[muscleGroup] ?? false,
      ),
    );

    return ExpansionTile(
      // Title: Localized muscle group name (NO emoji)
      title: Text(
        _getLocalizedMuscleGroupName(context, muscleGroup),
        style: context.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: context.colors.onSurface,
        ),
      ),

      // Subtitle: Exercise count
      subtitle: Text(
        _getExerciseCountText(context),
        style: context.textTheme.bodySmall?.copyWith(
          color: context.colors.onSurfaceVariant,
        ),
      ),

      // Trailing icon: Arrow down/up based on expansion state
      trailing: SemanticIcon(
        icon: isExpanded
            ? AppIcons.keyboardArrowUp
            : AppIcons.keyboardArrowDown,
        semanticLabel: isExpanded ? 'Collapse' : 'Expand',
        size: AppIconSize.medium,
        color: context.colors.primary,
      ),

      // Initial expansion state from provider
      initiallyExpanded: isExpanded,

      // Expansion callback: Toggle state in provider + haptic feedback
      onExpansionChanged: (expanded) {
        // Haptic feedback for tactile confirmation
        HapticFeedback.lightImpact();

        // Toggle expansion state in provider
        // OK: read - Using ref.read() in callback is correct pattern for calling notifier methods
        ref
            .read(muscleGroupExpansionProvider.notifier)
            .toggleExpansion(muscleGroup);
      },

      // Theme customization
      backgroundColor: context.colors.surface,
      collapsedBackgroundColor: context.colors.surface,
      iconColor: context.colors.primary,
      collapsedIconColor: context.colors.onSurfaceVariant,
      textColor: context.colors.onSurface,
      collapsedTextColor: context.colors.onSurface,

      // Shape: Rounded corners
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),

      // Children: Exercise cards
      children: children,
    );
  }

  /// Get localized muscle group name
  ///
  /// **SINGLE SOURCE OF TRUTH**: Uses [MuscleAbbreviationMapper.normalizeToCategory]
  /// to normalize various input formats (EN, IT) to canonical categories,
  /// then maps to localized strings from context.l10n.
  String _getLocalizedMuscleGroupName(BuildContext context, String group) {
    // Use mapper to normalize to canonical category (SSOT)
    final category = MuscleAbbreviationMapper.normalizeToCategory(group);

    if (category == null) {
      // Fallback: capitalize first letter
      return group.isEmpty
          ? group
          : group[0].toUpperCase() + group.substring(1).toLowerCase();
    }

    // Map category to localized string
    return switch (category) {
      MuscleCategory.chest => context.l10n.muscleGroupChest,
      MuscleCategory.back => context.l10n.muscleGroupBack,
      MuscleCategory.shoulders => context.l10n.muscleGroupShoulders,
      MuscleCategory.arms => context.l10n.muscleGroupArms,
      MuscleCategory.legs => context.l10n.muscleGroupLegs,
      MuscleCategory.core => context.l10n.muscleGroupCore,
    };
  }

  /// Get exercise count text
  ///
  /// Formats exercise count with proper pluralization
  String _getExerciseCountText(BuildContext context) {
    if (exerciseCount == 1) {
      return '1 ${context.l10n.exercise}';
    }
    return '$exerciseCount ${context.l10n.exercises}';
  }
}
