/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/data/services
/// 🎯 Feature: analytics
/// 🔧 Type: service
///
/// AnalyticsMigrationService - Migrates existing workouts to analytics collection
///
/// **Purpose**: One-time migration of historical workout data to new analytics structure
///
/// **Migration Logic**:
/// 1. Read ALL workouts for user from `workouts` collection
/// 2. Group exercises by exercise name across all workouts
/// 3. Extract sets (weight, reps, date) from each workout
/// 4. Create ExerciseHistory entities with all sessions
/// 5. Write to `users/{userId}/analytics/{exerciseName}` collection
///
/// **Data Mapping**:
/// - `Exercise.name` → `ExerciseHistory.exerciseName`
/// - `Exercise.category` → `ExerciseHistory.muscleGroup` (enum → string)
/// - `ExerciseSet.weight/reps/completedAt` → `AnalyticsSet`
/// - `Workout.startTime` → `ExerciseSession.date` (if completedAt missing)
///
/// **Usage**:
/// ```dart
/// final service = AnalyticsMigrationService(firestore, repository);
///
/// // Migrate all workouts for user
/// final result = await service.migrateUserWorkouts(userId: 'user123');
/// result.fold(
///   (failure) => print('Migration failed: $failure'),
///   (stats) => print('Migrated: ${stats.totalWorkouts} workouts, ${stats.totalExercises} exercises'),
/// );
/// ```
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gymbro_flutter_new/features/analytics/data/models/exercise_history_model.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_session.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/analytics_set.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';

/// Migration statistics
class MigrationStats {
  final int totalWorkouts;
  final int totalExercises;
  final int totalSessions;
  final int totalSets;
  final List<String> skippedExercises;

  MigrationStats({
    required this.totalWorkouts,
    required this.totalExercises,
    required this.totalSessions,
    required this.totalSets,
    required this.skippedExercises,
  });

  @override
  String toString() {
    return '''
Migration Stats:
- Workouts processed: $totalWorkouts
- Unique exercises: $totalExercises
- Total sessions: $totalSessions
- Total sets: $totalSets
- Skipped exercises: ${skippedExercises.length}
''';
  }
}

/// Analytics migration service
class AnalyticsMigrationService {
  final FirebaseFirestore _firestore;

  AnalyticsMigrationService({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  /// Migrate all workouts for a user to analytics collection
  ///
  /// **Steps**:
  /// 1. Fetch all completed workouts
  /// 2. Group exercises by name
  /// 3. Create analytics documents
  /// 4. Write to Firestore
  ///
  /// **Returns**: `Either<Failure, MigrationStats>`
  Future<Either<Failure, MigrationStats>> migrateUserWorkouts({
    required String userId,
  }) async {
    try {
      // Step 1: Fetch all completed workouts for user
      final workoutsSnapshot = await _firestore
          .collection('workouts')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'completed') // Only completed workouts
          .orderBy('startTime', descending: false) // Oldest first
          .get();

      if (workoutsSnapshot.docs.isEmpty) {
        return Right(
          MigrationStats(
            totalWorkouts: 0,
            totalExercises: 0,
            totalSessions: 0,
            totalSets: 0,
            skippedExercises: [],
          ),
        );
      }

      // Step 2: Parse workouts and group exercises by name
      final exerciseSessionsMap = <String, List<_ExerciseSessionData>>{};
      int totalWorkouts = 0;
      int totalSets = 0;
      final List<String> skippedExercises = [];

      for (final workoutDoc in workoutsSnapshot.docs) {
        try {
          final workoutData = workoutDoc.data();
          final workout = Workout.fromJson(workoutData);

          // Skip if workout has no exercises
          if (workout.exercises.isEmpty) continue;

          totalWorkouts++;

          // Extract session date (use startTime or createdAt)
          final sessionDate = workout.startTime ?? workout.createdAt;

          // Process each exercise in workout
          for (final exercise in workout.exercises) {
            // Skip exercises with no completed sets
            final completedSets =
                exercise.sets.where((set) => set.isCompleted).toList();
            if (completedSets.isEmpty) continue;

            final exerciseName = exercise.name;
            final muscleGroup = _categoryToMuscleGroup(exercise.category);

            // Convert Exercise sets to AnalyticsSets
            final analyticsSets = completedSets
                .where((set) =>
                    (set.weight != null && set.weight! > 0) &&
                    ((set.actualReps ?? set.reps) != null &&
                        (set.actualReps ?? set.reps)! > 0))
                .map((set) {
              return AnalyticsSet(
                weight: set.weight!,
                reps: set.actualReps ?? set.reps!,
                date: set.completedAt ?? sessionDate,
              );
            }).toList();

            if (analyticsSets.isEmpty) {
              skippedExercises.add('$exerciseName (no valid sets)');
              continue;
            }

            totalSets += analyticsSets.length;

            // Create session data
            final sessionData = _ExerciseSessionData(
              exerciseName: exerciseName,
              muscleGroup: muscleGroup,
              date: sessionDate,
              sets: analyticsSets,
            );

            // Group by exercise name
            exerciseSessionsMap
                .putIfAbsent(exerciseName, () => [])
                .add(sessionData);
          }
        } catch (e) {
          // Skip malformed workout document
          continue;
        }
      }

      // Step 3: Create ExerciseHistory documents for each exercise
      final batch = _firestore.batch();
      int totalSessions = 0;

      for (final entry in exerciseSessionsMap.entries) {
        final exerciseName = entry.key;
        final sessions = entry.value;

        // Sort sessions by date ascending
        sessions.sort((a, b) => a.date.compareTo(b.date));

        totalSessions += sessions.length;

        // Create ExerciseHistory entity
        final history = ExerciseHistory(
          exerciseName: exerciseName,
          muscleGroup: sessions.first.muscleGroup, // Use first session's muscle group
          sessions: sessions
              .map((sessionData) => ExerciseSession(
                    exerciseName: sessionData.exerciseName,
                    muscleGroup: sessionData.muscleGroup,
                    sets: sessionData.sets,
                    date: sessionData.date,
                  ))
              .toList(),
        );

        // Convert to Firestore model
        final model = ExerciseHistoryModel.fromDomain(history);

        // Add to batch write
        final docRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('analytics')
            .doc(exerciseName); // Document ID = exercise name

        batch.set(docRef, model.toFirestore());
      }

      // Step 4: Commit batch write
      await batch.commit();

      // Return statistics
      return Right(
        MigrationStats(
          totalWorkouts: totalWorkouts,
          totalExercises: exerciseSessionsMap.length,
          totalSessions: totalSessions,
          totalSets: totalSets,
          skippedExercises: skippedExercises,
        ),
      );
    } catch (e) {
      return Left(ServerFailure('Migration failed: $e'));
    }
  }

  /// Map ExerciseCategory enum to muscle group string
  ///
  /// **Mapping**:
  /// - chest → "chest"
  /// - back → "back"
  /// - shoulders → "shoulders"
  /// - arms → "arms"
  /// - legs → "legs"
  /// - abs → "abs"
  /// - cardio → "cardio"
  /// - other → "other"
  String _categoryToMuscleGroup(ExerciseCategory category) {
    return category.name; // Enum name matches string value
  }

  /// Delete all analytics for a user (for re-migration or cleanup)
  ///
  /// **WARNING**: Destructive operation!
  Future<Either<Failure, void>> deleteAllAnalytics({
    required String userId,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('analytics')
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to delete analytics: $e'));
    }
  }
}

/// Internal data structure for migration
class _ExerciseSessionData {
  final String exerciseName;
  final String muscleGroup;
  final DateTime date;
  final List<AnalyticsSet> sets;

  _ExerciseSessionData({
    required this.exerciseName,
    required this.muscleGroup,
    required this.date,
    required this.sets,
  });
}
