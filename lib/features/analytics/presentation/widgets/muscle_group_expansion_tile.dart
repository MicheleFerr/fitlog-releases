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
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';

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
      trailing: Icon(
        isExpanded ? AppIcons.keyboardArrowUp : AppIcons.keyboardArrowDown,
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
        ref.read(muscleGroupExpansionProvider.notifier).toggleExpansion(
              muscleGroup,
            );
      },

      // Theme customization
      backgroundColor: context.colors.surface,
      collapsedBackgroundColor: context.colors.surface,
      iconColor: context.colors.primary,
      collapsedIconColor: context.colors.onSurfaceVariant,
      textColor: context.colors.onSurface,
      collapsedTextColor: context.colors.onSurface,

      // Shape: Rounded corners
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),

      // Children: Exercise cards
      children: children,
    );
  }

  /// Get localized muscle group name
  ///
  /// Maps muscle group name to localized string from context.l10n
  String _getLocalizedMuscleGroupName(BuildContext context, String group) {
    // Normalize group name (lowercase, trim)
    final normalized = group.toLowerCase().trim();

    // Map to localization key
    // Note: Localization keys will be added in Task 1.5 and 1.6
    switch (normalized) {
      case 'chest':
      case 'petto':
        return context.l10n.muscleGroupChest;
      case 'back':
      case 'schiena':
        return context.l10n.muscleGroupBack;
      case 'legs':
      case 'gambe':
        return context.l10n.muscleGroupLegs;
      case 'shoulders':
      case 'spalle':
        return context.l10n.muscleGroupShoulders;
      case 'arms':
      case 'braccia':
        return context.l10n.muscleGroupArms;
      case 'core':
        return context.l10n.muscleGroupCore;
      default:
        // Fallback: capitalize first letter
        return group[0].toUpperCase() + group.substring(1).toLowerCase();
    }
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
