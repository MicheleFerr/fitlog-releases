/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation/providers
/// 🎯 Feature: workout
/// 🔧 Type: provider
/// 📱 Platform: Universal
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

/// Notifier for managing exercise expansion
class ExerciseExpansionNotifier extends FamilyNotifier<ExerciseExpansionState, String> {
  @override
  ExerciseExpansionState build(String exerciseId) {
    return const ExerciseExpansionState();
  }

  /// Expand the exercise
  void expand() {
    state = state.copyWith(
      isExpanded: true,
      userManuallyExpanded: true,
    );
  }

  /// Collapse the exercise
  void collapse() {
    state = state.copyWith(isExpanded: false);
  }

  /// Mark as auto-collapsed
  void markAutoCollapsed() {
    state = state.copyWith(
      isExpanded: false,
      hasAutoCollapsed: true,
    );
  }

  /// Reset flags when exercise becomes incomplete again
  void resetForIncomplete() {
    state = state.copyWith(
      isExpanded: true,
      hasAutoCollapsed: false,
      userManuallyExpanded: false,
    );
  }

  /// Check if auto-collapse should be allowed
  bool shouldAutoCollapse() {
    return state.isExpanded && !state.hasAutoCollapsed && !state.userManuallyExpanded;
  }
}

/// Provider for exercise expansion state
/// Family provider indexed by exercise ID
final exerciseExpansionProvider = NotifierProvider.family<
  ExerciseExpansionNotifier,
  ExerciseExpansionState,
  String
>(ExerciseExpansionNotifier.new);
