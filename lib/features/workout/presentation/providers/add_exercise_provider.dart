import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gymbro_flutter_new/features/workout/data/services/firestore_workout_history_reader.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/exercise_usage_tracker.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/models/exercise_usage_model.dart';

// Exercise sets management for the modal
class ExerciseSetNotifier extends Notifier<List<ExerciseSet>> {
  @override
  List<ExerciseSet> build() => [
    ExerciseSet(setNumber: 1, weight: 0, reps: 10),
    ExerciseSet(setNumber: 2, weight: 0, reps: 10),
    ExerciseSet(setNumber: 3, weight: 0, reps: 10),
  ];

  void addSet() {
    final newSetNumber = state.length + 1;
    final lastSet = state.isNotEmpty ? state.last : null;

    final newSet = ExerciseSet(
      setNumber: newSetNumber,
      weight: lastSet?.weight ?? 0,
      reps: lastSet?.reps ?? 10,
    );

    state = [...state, newSet];
  }

  void removeSet(String setId) {
    if (state.length <= 1) return; // Keep at least one set

    final updatedSets = state.where((set) => set.id != setId).toList();

    // Renumber sets
    for (int i = 0; i < updatedSets.length; i++) {
      updatedSets[i] = updatedSets[i].copyWith(setNumber: i + 1);
    }

    state = updatedSets;
  }

  void updateSet(String setId, ExerciseSet updatedSet) {
    state = state.map((set) {
      if (set.id == setId) {
        return updatedSet;
      }
      return set;
    }).toList();
  }

  void reset() {
    state = [
      ExerciseSet(setNumber: 1, weight: 0, reps: 10),
      ExerciseSet(setNumber: 2, weight: 0, reps: 10),
      ExerciseSet(setNumber: 3, weight: 0, reps: 10),
    ];
  }
}

// Provider for exercise sets in the modal
final exerciseSetsProvider =
    NotifierProvider<ExerciseSetNotifier, List<ExerciseSet>>(
      ExerciseSetNotifier.new,
    );

// Superset exercises management
class SupersetExercisesNotifier extends Notifier<List<Exercise>> {
  @override
  List<Exercise> build() => [];

  void addExercise(Exercise exercise) {
    state = [...state, exercise];
  }

  void removeExercise(Exercise exercise) {
    state = state.where((e) => e.id != exercise.id).toList();
  }

  void clear() {
    state = [];
  }
}

// Provider for superset exercises
final supersetExercisesProvider =
    NotifierProvider<SupersetExercisesNotifier, List<Exercise>>(
      SupersetExercisesNotifier.new,
    );

/// P0: Provider for recently used exercises in AddExerciseModal & ExerciseSearchScreen
/// Returns the 8 most recently used exercises for quick one-tap selection.
/// Uses ExerciseUsageTracker (Hive local) with automatic backfill from Firestore
/// workout history when the tracker is empty (first launch or fresh install).
final recentExercisesForModalProvider =
    FutureProvider.autoDispose<List<ExerciseUsageModel>>((ref) async {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return [];

      final tracker = ExerciseUsageTracker();
      var recent = await tracker.getRecentlyUsedExercises(limit: 8);

      // Backfill from Firestore if tracker is empty (existing user, first use of feature)
      if (recent.isEmpty) {
        await _backfillUsageFromFirestore(tracker, userId);
        recent = await tracker.getRecentlyUsedExercises(limit: 8);
      }

      return recent;
    });

/// Backfill ExerciseUsageTracker from existing Firestore workout history.
/// Reads the last 20 completed workouts and extracts all exercise names/IDs.
/// Runs only once (when tracker is empty), then future workouts keep it updated
/// via the completeWorkout() tracking in workout_provider.dart.
Future<void> _backfillUsageFromFirestore(
  ExerciseUsageTracker tracker,
  String userId,
) async {
  try {
    final reader = FirestoreWorkoutHistoryReader(
      firestore: FirebaseFirestore.instance,
    );
    final workouts = await reader.getRecentCompletedWorkouts(
      userId: userId,
      limit: 20,
      scanLimit: 80,
    );

    if (workouts.isEmpty) return;

    // Track unique exercises to avoid duplicate incrementUsage calls
    final seen = <String>{};

    for (final workout in workouts) {
      final exercises = workout.exercises;
      for (final exercise in exercises) {
        final id =
            (exercise.exerciseData['databaseExerciseId'] as String?) ??
            exercise.id;
        final name = exercise.name;
        if (!seen.contains(id)) {
          seen.add(id);
          await tracker.incrementUsage(
            exerciseId: id,
            exerciseName: name,
            userId: userId,
          );
        }
      }
    }

    if (kDebugMode) {
      debugPrint(
        '✅ [ExerciseUsage] Backfilled ${seen.length} exercises from Firestore history',
      );
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('❌ [ExerciseUsage] Backfill from Firestore failed: $e');
    }
  }
}
