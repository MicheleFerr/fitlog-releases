/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/providers
/// 🎯 Feature: analytics
/// 🔧 Type: provider
///
/// MuscleGroupExpansionProvider - State management for accordion expansion
///
/// **Purpose**: Track which muscle groups are expanded/collapsed in the accordion UI
///
/// **State**: Map<String, bool> where key = muscle group name, value = isExpanded
///
/// **Methods**:
/// - `toggleExpansion(String muscleGroup)`: Toggle a single group
/// - `expandAll()`: Expand all groups
/// - `collapseAll()`: Collapse all groups
/// - `isExpanded(String muscleGroup)`: Check if a group is expanded
///
/// **Initial State**: {} (all collapsed - missing keys = collapsed)
///
/// **Storage**: In-memory only (no persistence - clean slate each session)
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// StateNotifier for managing muscle group expansion state in accordion UI
///
/// **State Structure**:
/// ```dart
/// {
///   "Chest": true,   // Expanded
///   "Back": false,   // Collapsed
///   // Missing keys = collapsed (default)
/// }
/// ```
class MuscleGroupExpansionNotifier extends StateNotifier<Map<String, bool>> {
  /// Initialize with empty map (all groups collapsed by default)
  MuscleGroupExpansionNotifier() : super({});

  /// Toggle expansion state for a specific muscle group
  ///
  /// If group is expanded → collapse it
  /// If group is collapsed (or missing) → expand it
  void toggleExpansion(String muscleGroup) {
    state = {
      ...state,
      muscleGroup: !(state[muscleGroup] ?? false),
    };
  }

  /// Expand all muscle groups
  ///
  /// **Note**: This only expands groups that are currently in the state.
  /// New groups will need to be added first (happens automatically on first toggle).
  void expandAll() {
    // Get all known muscle groups from current state
    final allGroups = state.keys.toList();

    // If no groups in state yet, nothing to expand
    if (allGroups.isEmpty) return;

    // Set all known groups to expanded (true)
    state = {
      for (final group in allGroups) group: true,
    };
  }

  /// Collapse all muscle groups
  ///
  /// Resets state to empty map (all collapsed)
  void collapseAll() {
    state = {};
  }

  /// Check if a muscle group is currently expanded
  ///
  /// Returns `true` if expanded, `false` if collapsed or not in state
  bool isExpanded(String muscleGroup) {
    return state[muscleGroup] ?? false;
  }

  /// Get count of currently expanded groups
  ///
  /// Useful for determining icon state (expand all vs collapse all button)
  int get expandedCount {
    return state.values.where((isExpanded) => isExpanded).length;
  }

  /// Check if all known groups are expanded
  ///
  /// Returns `true` only if state is non-empty AND all values are true
  bool get areAllExpanded {
    if (state.isEmpty) return false;
    return state.values.every((isExpanded) => isExpanded);
  }
}

/// Provider for muscle group expansion state
///
/// **Usage**:
/// ```dart
/// // Watch expansion state
/// final isExpanded = ref.watch(muscleGroupExpansionProvider).isExpanded('Chest');
///
/// // Toggle expansion
/// ref.read(muscleGroupExpansionProvider.notifier).toggleExpansion('Chest');
///
/// // Expand all
/// ref.read(muscleGroupExpansionProvider.notifier).expandAll();
///
/// // Collapse all
/// ref.read(muscleGroupExpansionProvider.notifier).collapseAll();
/// ```
final muscleGroupExpansionProvider =
    StateNotifierProvider<MuscleGroupExpansionNotifier, Map<String, bool>>(
  (ref) => MuscleGroupExpansionNotifier(),
);
