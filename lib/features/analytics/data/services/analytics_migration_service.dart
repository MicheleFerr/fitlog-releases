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
      // Step 1: Fetch all workouts for user (filter completed in-memory)
      print('🔄 [MIGRATION] Starting migration for user: $userId');

      final workoutsSnapshot = await _firestore
          .collection('workouts')
          .where('userId', isEqualTo: userId)
          // Note: No orderBy to avoid filtering out docs without startTime field
          .get();

      print('🔄 [MIGRATION] Total workouts fetched: ${workoutsSnapshot.docs.length}');

      // Filter only completed workouts (with completedAt timestamp)
      final completedWorkoutDocs = workoutsSnapshot.docs.where((doc) {
        final data = doc.data();
        return data['completedAt'] != null; // Only workouts with completedAt
      }).toList();

      print('🔄 [MIGRATION] Completed workouts (with completedAt): ${completedWorkoutDocs.length}');

      if (completedWorkoutDocs.isEmpty) {
        print('❌ [MIGRATION] No completed workouts found. Migration aborted.');
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
      int parseErrors = 0;
      int emptyExercisesCount = 0;
      int processedWorkoutsWithExercises = 0;

      print('🔄 [MIGRATION] Starting to parse ${completedWorkoutDocs.length} workouts...');

      for (int i = 0; i < completedWorkoutDocs.length; i++) {
        final workoutDoc = completedWorkoutDocs[i];
        try {
          final workoutData = workoutDoc.data();
          print('🔄 [MIGRATION] Processing workout ${i + 1}/${completedWorkoutDocs.length} - ID: ${workoutDoc.id}');

          // Log raw data structure to debug parsing
          if (i == 0) {
            print('📋 [MIGRATION] Sample workout structure:');
            print('  - Keys: ${workoutData.keys.join(", ")}');
            if (workoutData['exercises'] != null) {
              print('  - Exercises field type: ${workoutData['exercises'].runtimeType}');
              if (workoutData['exercises'] is List) {
                final exercises = workoutData['exercises'] as List;
                print('  - Number of exercises: ${exercises.length}');
                if (exercises.isNotEmpty) {
                  print('  - First exercise: ${exercises.first}');
                }
              }
            }
          }

          // Add missing fields for old workout documents
          // 1. Add the document ID as 'id' field
          // 2. Infer status from completedAt (we already filtered for completed workouts)
          // 3. Convert Firestore Timestamps to ISO strings for proper parsing
          final enrichedData = Map<String, dynamic>.from(workoutData);
          enrichedData['id'] = workoutDoc.id; // Add document ID
          enrichedData['status'] = 'completed'; // All filtered workouts have completedAt, so they're completed

          // Convert Timestamp fields to ISO strings for proper parsing
          ['createdAt', 'updatedAt', 'startTime', 'endTime', 'completedAt', 'startedAt'].forEach((field) {
            if (enrichedData[field] != null && enrichedData[field] is Timestamp) {
              enrichedData[field] = (enrichedData[field] as Timestamp).toDate().toIso8601String();
            }
          });

          // Also convert Timestamps in exercises and their sets
          if (enrichedData['exercises'] != null && enrichedData['exercises'] is List) {
            final exercises = enrichedData['exercises'] as List;
            enrichedData['exercises'] = exercises.map((exercise) {
              if (exercise is Map<String, dynamic>) {
                final exerciseMap = Map<String, dynamic>.from(exercise);

                // CRITICAL FIX: Flatten exerciseData wrapper if it exists
                // Old structure: { category: "...", exerciseData: { id: "...", name: "..." }, sets: [...] }
                // New structure: { category: "...", id: "...", name: "...", sets: [...] }
                if (exerciseMap['exerciseData'] != null && exerciseMap['exerciseData'] is Map) {
                  print('🔧 [MIGRATION] Flattening exerciseData wrapper for exercise');
                  final exerciseData = exerciseMap['exerciseData'] as Map<String, dynamic>;
                  // Move all fields from exerciseData to top level
                  exerciseData.forEach((key, value) {
                    exerciseMap[key] = value;
                  });
                  // Remove the wrapper
                  exerciseMap.remove('exerciseData');
                }

                // Convert exercise timestamps
                ['createdAt', 'updatedAt'].forEach((field) {
                  if (exerciseMap[field] != null && exerciseMap[field] is Timestamp) {
                    exerciseMap[field] = (exerciseMap[field] as Timestamp).toDate().toIso8601String();
                  }
                });

                // Convert timestamps in sets
                if (exerciseMap['sets'] != null && exerciseMap['sets'] is List) {
                  final sets = exerciseMap['sets'] as List;
                  exerciseMap['sets'] = sets.map((set) {
                    if (set is Map<String, dynamic>) {
                      final setMap = Map<String, dynamic>.from(set);
                      if (setMap['completedAt'] != null && setMap['completedAt'] is Timestamp) {
                        setMap['completedAt'] = (setMap['completedAt'] as Timestamp).toDate().toIso8601String();
                      }
                      return setMap;
                    }
                    return set;
                  }).toList();
                }

                return exerciseMap;
              }
              return exercise;
            }).toList();
          }

          // Debug: Check raw exercises data before parsing
          if (enrichedData['exercises'] != null) {
            final rawExercises = enrichedData['exercises'];
            if (rawExercises is List) {
              print('🔍 [DEBUG] Workout ${workoutDoc.id} has ${rawExercises.length} raw exercises in data');
              if (rawExercises.isNotEmpty) {
                print('🔍 [DEBUG] First exercise structure: ${rawExercises.first}');
              }
            } else {
              print('🔍 [DEBUG] exercises field is not a List, it is: ${rawExercises.runtimeType}');
            }
          } else {
            print('🔍 [DEBUG] Workout ${workoutDoc.id} has NO exercises field in enrichedData');
          }

          Workout workout;
          try {
            workout = Workout.fromJson(enrichedData);
            print('🔍 [DEBUG] After parsing: workout.exercises.length = ${workout.exercises.length}');
          } catch (e, stackTrace) {
            print('❌ [ERROR] Failed to parse workout ${workoutDoc.id}: $e');
            print('Stack trace: $stackTrace');
            parseErrors++;
            continue;
          }

          // Skip if workout has no exercises
          if (workout.exercises.isEmpty) {
            emptyExercisesCount++;
            print('⚠️ [MIGRATION] Workout ${workoutDoc.id} has no exercises after parsing');
            continue;
          }

          processedWorkoutsWithExercises++;
          print('✅ [MIGRATION] Workout has ${workout.exercises.length} exercises');

          totalWorkouts++;

          // Extract session date (use startTime or createdAt)
          final sessionDate = workout.startTime ?? workout.createdAt;

          // Process each exercise in workout
          for (final exercise in workout.exercises) {
            print('  📊 Exercise: ${exercise.name} - Sets: ${exercise.sets.length}');

            // Skip exercises with no completed sets
            final completedSets =
                exercise.sets.where((set) => set.isCompleted).toList();
            if (completedSets.isEmpty) {
              print('    ⚠️ No completed sets for ${exercise.name}');
              continue;
            }

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
              print('    ⚠️ No valid sets (with weight/reps) for ${exercise.name}');
              continue;
            }

            print('    ✅ Created ${analyticsSets.length} analytics sets for ${exercise.name}');
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
        } catch (e, stack) {
          parseErrors++;
          print('❌ [MIGRATION] Error parsing workout ${workoutDoc.id}: $e');
          print('   Stack trace: $stack');
          // Skip malformed workout document
          continue;
        }
      }

      print('🔄 [MIGRATION] Parsing complete:');
      print('   - Parse errors: $parseErrors');
      print('   - Workouts with empty exercises: $emptyExercisesCount');
      print('   - Workouts processed with exercises: $processedWorkoutsWithExercises');
      print('   - Unique exercises found: ${exerciseSessionsMap.length}');
      print('   - Skipped exercises: ${skippedExercises.length}');

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
      print('🔄 [MIGRATION] Writing ${exerciseSessionsMap.length} exercises to Firestore...');
      print('🔄 [MIGRATION] Exercises: ${exerciseSessionsMap.keys.join(", ")}');

      await batch.commit();

      print('✅ [MIGRATION] Migration complete!');
      print('   - Total workouts: $totalWorkouts');
      print('   - Unique exercises: ${exerciseSessionsMap.length}');
      print('   - Total sessions: $totalSessions');
      print('   - Total sets: $totalSets');

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
