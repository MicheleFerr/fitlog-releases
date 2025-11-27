/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/workout/presentation/widgets/exercise_list_item/controllers
/// 🎯 Feature: workout
/// 🔧 Type: controller
///
/// Controller for ExerciseListItem set operations.
/// Encapsulates all set management logic (add, delete, update, duplicate, toggle completion)
/// and handles APRE/RPE suggestions.
///
/// This controller is part of the ExerciseListItem refactoring to break down
/// the monolithic 5593-line widget into smaller, maintainable components.
///
/// Design Pattern: StateNotifier + Riverpod
/// - Presentation-agnostic (no BuildContext in methods except for callbacks)
/// - Pure business logic for set operations
/// - Immutable state updates
/// - Haptic feedback on mutations
///
/// Usage Example:
/// ```dart
/// final controller = ref.watch(exerciseListItemControllerProvider);
///
/// // Add new set
/// controller.addSet(
///   exercise: currentExercise,
///   onUpdate: (updated) => ref.read(workoutProvider.notifier).updateExercise(updated),
///   onFeedback: (message) => SnackBarService.showInfo(context, message),
/// );
///
/// // Delete set with undo
/// controller.deleteSet(
///   exercise: currentExercise,
///   setIndex: 2,
///   onUpdate: (updated) => ref.read(workoutProvider.notifier).updateExercise(updated),
///   onFeedback: (message, actionLabel, onAction) =>
///     SnackBarService.showCustom(context, message: message, actionLabel: actionLabel, onAction: onAction),
/// );
/// ```
library;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';

/// Callback signature for exercise updates
typedef OnExerciseUpdate = void Function(Exercise updatedExercise);

/// Callback signature for user feedback (snackbar/toast)
typedef OnFeedback = void Function(String message);

/// Callback signature for user feedback with action (snackbar with undo)
typedef OnFeedbackWithAction = void Function(
  String message,
  String actionLabel,
  VoidCallback onAction,
);

/// Controller state for ExerciseListItem
/// Currently stateless - can be extended for undo/redo history if needed
class ExerciseListItemState {
  const ExerciseListItemState();
}

/// Provider for ExerciseListItemController
final exerciseListItemControllerProvider =
    NotifierProvider<ExerciseListItemController, ExerciseListItemState>(ExerciseListItemController.new);

/// Controller for ExerciseListItem set operations
///
/// Manages all set-related operations:
/// - addSet: Create new set with smart defaults from last set
/// - deleteSet: Remove set with undo support
/// - toggleSetCompletion: Mark set as complete/incomplete
/// - updateSet: Update set data (weight/reps/etc.)
/// - duplicateSet: Clone existing set
/// - handleAPRESuggestion: Apply APRE protocol weight adjustment
/// - handleRPESuggestion: Apply RPE-based weight adjustment
class ExerciseListItemController extends Notifier<ExerciseListItemState> {
  @override
  ExerciseListItemState build() => const ExerciseListItemState();

  /// Add a new set with smart defaults
  ///
  /// Logic:
  /// 1. Find last non-warmup set (or fallback to last set)
  /// 2. Copy weight from last set
  /// 3. Copy reps from last set (default 10 if none)
  /// 4. Set isWarmup = false
  /// 5. Auto-increment setNumber
  ///
  /// Parameters:
  /// - [exercise]: Current exercise to add set to
  /// - [onUpdate]: Callback to update exercise in parent state
  /// - [onFeedback]: Callback to show feedback message (e.g., snackbar)
  ///
  /// Haptic: Light impact on success
  void addSet({
    required Exercise exercise,
    required OnExerciseUpdate onUpdate,
    required OnFeedback onFeedback,
  }) {
    // Get the last set's values as defaults for the new set
    ExerciseSet? lastSet;
    if (exercise.sets.isNotEmpty) {
      // Find the last non-warmup set
      final workingSets = exercise.sets.where((s) => !s.isWarmup).toList();
      lastSet =
          workingSets.isNotEmpty ? workingSets.last : exercise.sets.last;
    }

    // Create new set with default or copied values
    final newSet = ExerciseSet(
      setNumber: exercise.sets.length + 1,
      weight: lastSet?.weight,
      reps: lastSet?.reps ?? 10,
      isWarmup: false,
    );

    final updatedSets = [...exercise.sets, newSet];
    final updatedExercise = exercise.copyWith(sets: updatedSets);
    onUpdate(updatedExercise);

    // Show feedback (caller must provide localized string)
    onFeedback('Set ${newSet.setNumber} added');

    HapticFeedback.lightImpact();
  }

  /// Delete a set with undo support
  ///
  /// Logic:
  /// 1. Remove set at index
  /// 2. Renumber remaining sets (1, 2, 3, ...)
  /// 3. Show feedback with undo action
  /// 4. Undo restores set at original index and renumbers again
  ///
  /// Parameters:
  /// - [exercise]: Current exercise
  /// - [setIndex]: Index of set to delete (0-based)
  /// - [onUpdate]: Callback to update exercise in parent state
  /// - [onFeedbackWithAction]: Callback to show feedback with undo action
  ///
  /// Haptic: Medium impact on delete
  void deleteSet({
    required Exercise exercise,
    required int setIndex,
    required OnExerciseUpdate onUpdate,
    required OnFeedbackWithAction onFeedbackWithAction,
  }) {
    if (setIndex < 0 || setIndex >= exercise.sets.length) return;

    final deletedSet = exercise.sets[setIndex];

    // Remove the set from the list
    final updatedSets = List<ExerciseSet>.from(exercise.sets);
    updatedSets.removeAt(setIndex);

    // Renumber remaining sets
    for (var i = 0; i < updatedSets.length; i++) {
      updatedSets[i] = updatedSets[i].copyWith(setNumber: i + 1);
    }

    final updatedExercise = exercise.copyWith(sets: updatedSets);
    onUpdate(updatedExercise);

    // Show feedback with undo (caller must provide localized strings)
    final message = deletedSet.isWarmup
        ? 'Warmup set deleted'
        : 'Set ${setIndex + 1} deleted';

    onFeedbackWithAction(
      message,
      'Undo',
      () {
        // Restore the set
        final restoredSets = List<ExerciseSet>.from(updatedSets);
        restoredSets.insert(setIndex, deletedSet);

        // Renumber again
        for (var i = 0; i < restoredSets.length; i++) {
          restoredSets[i] = restoredSets[i].copyWith(setNumber: i + 1);
        }

        final restoredExercise = exercise.copyWith(sets: restoredSets);
        onUpdate(restoredExercise);
      },
    );

    HapticFeedback.mediumImpact();
  }

  /// Toggle set completion status
  ///
  /// Logic:
  /// 1. Find set by ID
  /// 2. Toggle isCompleted flag
  /// 3. Update completedAt timestamp if marking complete
  ///
  /// Parameters:
  /// - [exercise]: Current exercise
  /// - [set]: Set to toggle completion
  /// - [onUpdate]: Callback to update exercise in parent state
  ///
  /// Haptic: Light impact on toggle
  void toggleSetCompletion({
    required Exercise exercise,
    required ExerciseSet set,
    required OnExerciseUpdate onUpdate,
  }) {
    final updatedSets = exercise.sets.map((s) {
      if (s.id == set.id) {
        return s.copyWith(
          isCompleted: !s.isCompleted,
          completedAt: !s.isCompleted ? DateTime.now() : null,
        );
      }
      return s;
    }).toList();

    final updatedExercise = exercise.copyWith(sets: updatedSets);
    onUpdate(updatedExercise);

    HapticFeedback.lightImpact();
  }

  /// Update a set's data (weight, reps, etc.)
  ///
  /// Logic:
  /// 1. Find set by ID
  /// 2. Replace with updated set
  ///
  /// Parameters:
  /// - [exercise]: Current exercise
  /// - [updatedSet]: Set with updated data
  /// - [onUpdate]: Callback to update exercise in parent state
  ///
  /// No haptic feedback (called frequently during typing)
  void updateSet({
    required Exercise exercise,
    required ExerciseSet updatedSet,
    required OnExerciseUpdate onUpdate,
  }) {
    final updatedSets = exercise.sets.map((s) {
      if (s.id == updatedSet.id) {
        return updatedSet;
      }
      return s;
    }).toList();

    final updatedExercise = exercise.copyWith(sets: updatedSets);
    onUpdate(updatedExercise);
  }

  /// Duplicate a set
  ///
  /// Logic:
  /// 1. Clone set at index
  /// 2. Insert after original set
  /// 3. Renumber all sets
  ///
  /// Parameters:
  /// - [exercise]: Current exercise
  /// - [setIndex]: Index of set to duplicate
  /// - [onUpdate]: Callback to update exercise in parent state
  /// - [onFeedback]: Callback to show feedback message
  ///
  /// Haptic: Light impact on success
  void duplicateSet({
    required Exercise exercise,
    required int setIndex,
    required OnExerciseUpdate onUpdate,
    required OnFeedback onFeedback,
  }) {
    if (setIndex < 0 || setIndex >= exercise.sets.length) return;

    final setToDuplicate = exercise.sets[setIndex];

    // Create duplicate with new ID
    final duplicatedSet = ExerciseSet(
      setNumber: setIndex + 2, // Temporary number, will be renumbered
      weight: setToDuplicate.weight,
      reps: setToDuplicate.reps,
      seconds: setToDuplicate.seconds,
      distance: setToDuplicate.distance,
      isWarmup: setToDuplicate.isWarmup,
      restTime: setToDuplicate.restTime,
      notes: setToDuplicate.notes,
    );

    final updatedSets = List<ExerciseSet>.from(exercise.sets);
    updatedSets.insert(setIndex + 1, duplicatedSet);

    // Renumber all sets
    for (var i = 0; i < updatedSets.length; i++) {
      updatedSets[i] = updatedSets[i].copyWith(setNumber: i + 1);
    }

    final updatedExercise = exercise.copyWith(sets: updatedSets);
    onUpdate(updatedExercise);

    // Show feedback
    onFeedback('Set ${setIndex + 1} duplicated');

    HapticFeedback.lightImpact();
  }

  /// Handle APRE (Auto-regulating Progressive Resistance Exercise) suggestion
  ///
  /// Logic:
  /// 1. Find next set after currentSet (Set 4 in APRE protocol)
  /// 2. Update next set's weight to suggested weight
  ///
  /// Parameters:
  /// - [exercise]: Current exercise
  /// - [currentSet]: Set that triggered APRE calculation (usually Set 3)
  /// - [suggestedWeight]: Calculated weight for next set
  /// - [onUpdate]: Callback to update exercise in parent state
  /// - [onFeedback]: Callback to show feedback message
  ///
  /// No haptic feedback (automated adjustment)
  void handleAPRESuggestion({
    required Exercise exercise,
    required ExerciseSet currentSet,
    required double suggestedWeight,
    required OnExerciseUpdate onUpdate,
    required OnFeedback onFeedback,
  }) {
    // Find the next set (Set 4 in APRE protocol)
    final nextSetIndex = currentSet.setNumber; // Set 4 is after Set 3
    if (nextSetIndex < exercise.sets.length) {
      final updatedSets = List<ExerciseSet>.from(exercise.sets);
      updatedSets[nextSetIndex] = updatedSets[nextSetIndex].copyWith(
        weight: suggestedWeight,
      );

      final updatedExercise = exercise.copyWith(sets: updatedSets);
      onUpdate(updatedExercise);

      // Show confirmation
      onFeedback(
        'APRE: Set ${nextSetIndex + 1} weight adjusted to ${suggestedWeight.toStringAsFixed(1)} kg',
      );
    }
  }

  /// Handle RPE (Rate of Perceived Exertion) suggestion
  ///
  /// Logic:
  /// 1. Apply suggested weight to ALL remaining incomplete sets
  /// 2. Show feedback only if at least one set was updated
  ///
  /// Parameters:
  /// - [exercise]: Current exercise
  /// - [suggestedWeight]: Calculated weight based on RPE feedback
  /// - [onUpdate]: Callback to update exercise in parent state
  /// - [onFeedback]: Callback to show feedback message
  ///
  /// No haptic feedback (automated adjustment)
  void handleRPESuggestion({
    required Exercise exercise,
    required double suggestedWeight,
    required OnExerciseUpdate onUpdate,
    required OnFeedback onFeedback,
  }) {
    // Apply suggested weight to all remaining incomplete sets
    final updatedSets = List<ExerciseSet>.from(exercise.sets);
    bool hasUpdated = false;

    for (int i = 0; i < updatedSets.length; i++) {
      if (!updatedSets[i].isCompleted) {
        updatedSets[i] = updatedSets[i].copyWith(weight: suggestedWeight);
        hasUpdated = true;
      }
    }

    if (hasUpdated) {
      final updatedExercise = exercise.copyWith(sets: updatedSets);
      onUpdate(updatedExercise);

      // Show confirmation (caller must provide localized string)
      onFeedback(
        'RPE Autoregulation: Weight adjusted to ${suggestedWeight.toStringAsFixed(1)} kg',
      );
    }
  }

  /// Get count of completed sets for an exercise
  ///
  /// Utility method for UI logic
  int getCompletedSetsCount(Exercise exercise) {
    return exercise.sets.where((set) => set.isCompleted).length;
  }

  /// Get last non-warmup set
  ///
  /// Utility method for UI logic
  ExerciseSet? getLastWorkingSet(Exercise exercise) {
    final workingSets = exercise.sets.where((s) => !s.isWarmup).toList();
    return workingSets.isNotEmpty ? workingSets.last : null;
  }

  /// Check if exercise is completed (all sets marked complete)
  bool isExerciseCompleted(Exercise exercise) {
    return exercise.sets.isNotEmpty &&
        exercise.sets.every((set) => set.isCompleted);
  }

  /// Get total volume for exercise (sum of all set volumes)
  double getTotalVolume(Exercise exercise) {
    return exercise.sets.fold(0.0, (sum, set) => sum + set.volume);
  }
}
