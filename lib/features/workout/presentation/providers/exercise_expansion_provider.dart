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

/// TEMPORARY: Using Provider.family as workaround (StateProvider removed in Riverpod 3.x)
/// TODO: Migrate to @riverpod codegen for proper NotifierProvider.family support
final exerciseExpansionProvider =
    Provider.family.autoDispose<ExerciseExpansionState, String>(
  (ref, exerciseId) => const ExerciseExpansionState(),
);
