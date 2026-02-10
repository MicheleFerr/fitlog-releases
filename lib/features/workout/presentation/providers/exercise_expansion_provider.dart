/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: presentation/providers
/// Feature: workout
/// Type: provider
/// Platform: Universal
///
/// Exercise expansion state provider
/// Manages the collapsed/expanded state of each exercise card
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State for exercise expansion
class ExerciseExpansionState {
  const ExerciseExpansionState({
    this.isExpanded = true,
    this.hasAutoCollapsed = false,
    this.userManuallyExpanded = false,
  });
  final bool isExpanded;
  final bool hasAutoCollapsed;
  final bool userManuallyExpanded;

  ExerciseExpansionState copyWith({
    bool? isExpanded,
    bool? hasAutoCollapsed,
    bool? userManuallyExpanded,
  }) {
    return ExerciseExpansionState(
      isExpanded: isExpanded ?? this.isExpanded,
      hasAutoCollapsed: hasAutoCollapsed ?? this.hasAutoCollapsed,
      userManuallyExpanded: userManuallyExpanded ?? this.userManuallyExpanded,
    );
  }
}

/// Notifier for exercise expansion state
/// ✅ Riverpod 3.x: Uses Notifier with constructor argument for family support
class ExerciseExpansionNotifier extends Notifier<ExerciseExpansionState> {
  ExerciseExpansionNotifier(this.exerciseId);
  final String exerciseId;

  @override
  ExerciseExpansionState build() {
    return const ExerciseExpansionState();
  }

  /// Expand the exercise card
  void expand() {
    state = state.copyWith(
      isExpanded: true,
      userManuallyExpanded: true,
    );
  }

  /// Collapse the exercise card
  void collapse() {
    state = state.copyWith(
      isExpanded: false,
    );
  }

  /// Auto-collapse triggered by system (after completing all sets)
  void autoCollapse() {
    // Don't auto-collapse if user manually expanded
    if (state.userManuallyExpanded) return;

    state = state.copyWith(
      isExpanded: false,
      hasAutoCollapsed: true,
    );
  }

  /// Toggle expansion state
  void toggle() {
    if (state.isExpanded) {
      collapse();
    } else {
      expand();
    }
  }

  /// Reset state (used when exercise changes)
  void reset() {
    state = const ExerciseExpansionState();
  }
}

/// Provider for exercise expansion state with notifier
/// ✅ Riverpod 3.x syntax with family and autoDispose
final exerciseExpansionProvider = NotifierProvider.family
    .autoDispose<ExerciseExpansionNotifier, ExerciseExpansionState, String>(
  ExerciseExpansionNotifier.new,
);
