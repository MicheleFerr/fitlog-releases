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
import 'package:gymbro_flutter_new/shared/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/domain/services/secure_logger.dart'; // 🔐 SECURITY: Secure logging
import 'package:gymbro_flutter_new/shared/domain/abstractions/exercise_counting_mode.dart'; // 🏋️ Bodyweight support

/// Migration statistics
class MigrationStats {
  MigrationStats({
    required this.totalWorkouts,
    required this.totalExercises,
    required this.totalSessions,
    required this.totalSets,
    required this.skippedExercises,
  });
  final int totalWorkouts;
  final int totalExercises;
  final int totalSessions;
  final int totalSets;
  final List<String> skippedExercises;

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
  AnalyticsMigrationService({required FirebaseFirestore firestore})
    : _firestore = firestore;
  final FirebaseFirestore _firestore;

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
      // 🔐 SECURITY: Redact userId (show only first 8 chars for debugging)
      SecureLogger.info(
        'Starting analytics migration',
        data: {'userIdPrefix': userId.substring(0, 8.clamp(0, userId.length))},
      );

      final workoutsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('workouts')
          // Note: No orderBy to avoid filtering out docs without startTime field
          .get();

      SecureLogger.info(
        'Fetched workouts for migration',
        data: {'totalWorkouts': workoutsSnapshot.docs.length},
      );

      // Filter only completed workouts. Current workout docs store endTime;
      // keep completedAt as backward-compatible fallback for migrated data.
      final completedWorkoutDocs = workoutsSnapshot.docs.where((doc) {
        final data = doc.data();
        return data['endTime'] != null || data['completedAt'] != null;
      }).toList();

      SecureLogger.info(
        'Filtered completed workouts',
        data: {'completedWorkouts': completedWorkoutDocs.length},
      );

      if (completedWorkoutDocs.isEmpty) {
        SecureLogger.info('No completed workouts found - migration skipped');
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

      SecureLogger.debug(
        'Starting workout parsing',
        data: {'totalWorkouts': completedWorkoutDocs.length},
      );

      for (int i = 0; i < completedWorkoutDocs.length; i++) {
        final workoutDoc = completedWorkoutDocs[i];
        try {
          final workoutData = workoutDoc.data();
          SecureLogger.debug(
            'Processing workout',
            data: {
              'progress': '${i + 1}/${completedWorkoutDocs.length}',
              'workoutId': workoutDoc.id,
            },
          );

          // Log raw data structure to debug parsing
          if (i == 0) {
            SecureLogger.debug(
              'Sample workout structure',
              data: {
                'keys': workoutData.keys.join(', '),
                'exercisesType':
                    workoutData['exercises']?.runtimeType.toString() ?? 'null',
                'exerciseCount': workoutData['exercises'] is List
                    ? (workoutData['exercises'] as List).length
                    : 0,
              },
            );
          }

          // Add missing fields for old workout documents
          // 1. Add the document ID as 'id' field
          // 2. Infer status from completedAt (we already filtered for completed workouts)
          // 3. Convert Firestore Timestamps to ISO strings for proper parsing
          final enrichedData = Map<String, dynamic>.from(workoutData);
          enrichedData['id'] = workoutDoc.id; // Add document ID
          enrichedData['status'] =
              'completed'; // All filtered workouts have completedAt, so they're completed

          // Convert Timestamp fields to ISO strings for proper parsing
          for (var field in [
            'createdAt',
            'updatedAt',
            'startTime',
            'endTime',
            'completedAt',
            'startedAt',
          ]) {
            if (enrichedData[field] != null &&
                enrichedData[field] is Timestamp) {
              enrichedData[field] = (enrichedData[field] as Timestamp)
                  .toDate()
                  .toIso8601String();
            }
          }

          // Also convert Timestamps in exercises and their sets
          if (enrichedData['exercises'] != null &&
              enrichedData['exercises'] is List) {
            final exercises = enrichedData['exercises'] as List;
            enrichedData['exercises'] = exercises.map((exercise) {
              if (exercise is Map<String, dynamic>) {
                final exerciseMap = Map<String, dynamic>.from(exercise);

                // CRITICAL FIX: Flatten exerciseData wrapper if it exists
                // Old structure: { category: "...", exerciseData: { id: "...", name: "..." }, sets: [...] }
                // New structure: { category: "...", id: "...", name: "...", sets: [...] }
                if (exerciseMap['exerciseData'] != null &&
                    exerciseMap['exerciseData'] is Map) {
                  SecureLogger.debug(
                    'Flattening exerciseData wrapper structure',
                  );
                  final exerciseData =
                      exerciseMap['exerciseData'] as Map<String, dynamic>;
                  // Move all fields from exerciseData to top level
                  exerciseData.forEach((key, value) {
                    exerciseMap[key] = value;
                  });
                  // Remove the wrapper
                  exerciseMap.remove('exerciseData');
                }

                // Convert exercise timestamps
                for (var field in ['createdAt', 'updatedAt']) {
                  if (exerciseMap[field] != null &&
                      exerciseMap[field] is Timestamp) {
                    exerciseMap[field] = (exerciseMap[field] as Timestamp)
                        .toDate()
                        .toIso8601String();
                  }
                }

                // Convert timestamps in sets
                if (exerciseMap['sets'] != null &&
                    exerciseMap['sets'] is List) {
                  final sets = exerciseMap['sets'] as List;
                  exerciseMap['sets'] = sets.map((set) {
                    if (set is Map<String, dynamic>) {
                      final setMap = Map<String, dynamic>.from(set);
                      if (setMap['completedAt'] != null &&
                          setMap['completedAt'] is Timestamp) {
                        setMap['completedAt'] =
                            (setMap['completedAt'] as Timestamp)
                                .toDate()
                                .toIso8601String();
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
              SecureLogger.debug(
                'Workout has raw exercises',
                data: {
                  'workoutId': workoutDoc.id,
                  'exerciseCount': rawExercises.length,
                },
              );
            } else {
              SecureLogger.warning(
                'Exercises field is not a List',
                data: {
                  'workoutId': workoutDoc.id,
                  'actualType': rawExercises.runtimeType.toString(),
                },
              );
            }
          } else {
            SecureLogger.warning(
              'Workout has no exercises field',
              data: {'workoutId': workoutDoc.id},
            );
          }

          Workout workout;
          try {
            workout = Workout.fromJson(enrichedData);
            SecureLogger.debug(
              'Parsed workout successfully',
              data: {'exerciseCount': workout.exercises.length},
            );
          } catch (e, stackTrace) {
            SecureLogger.error(
              'Failed to parse workout',
              error: e,
              stackTrace: stackTrace,
              data: {'workoutId': workoutDoc.id},
            );
            parseErrors++;
            continue;
          }

          // Skip if workout has no exercises
          if (workout.exercises.isEmpty) {
            emptyExercisesCount++;
            SecureLogger.warning(
              'Workout has no exercises after parsing',
              data: {'workoutId': workoutDoc.id},
            );
            continue;
          }

          processedWorkoutsWithExercises++;
          SecureLogger.debug(
            'Workout parsed with exercises',
            data: {'exerciseCount': workout.exercises.length},
          );

          totalWorkouts++;

          // Extract session date (use startTime or createdAt)
          final sessionDate = workout.startTime ?? workout.createdAt;

          // Process each exercise in workout
          for (final exercise in workout.exercises) {
            SecureLogger.debug(
              'Processing exercise',
              data: {
                'exerciseName': exercise.name,
                'setCount': exercise.sets.length,
              },
            );

            // For completed workouts, consider all sets with valid weight/reps as completed
            // Don't rely on isCompleted field which may be false in older data
            // 🏋️ Bodyweight support: For countingMode.reps, only require valid reps
            final isBodyweight =
                exercise.countingMode == ExerciseCountingMode.reps;

            final validSets = exercise.sets.where((set) {
              final reps = set.actualReps ?? set.reps;
              if (reps == null || reps <= 0) return false;

              if (isBodyweight) {
                // Bodyweight exercise: only need valid reps
                return true;
              } else {
                // Weighted exercise: need weight > 0
                return set.weight != null && set.weight! > 0;
              }
            }).toList();

            if (validSets.isEmpty) {
              SecureLogger.warning(
                'Exercise has no valid sets with weight/reps',
                data: {'exerciseName': exercise.name},
              );
              skippedExercises.add('${exercise.name} (no valid sets)');
              continue;
            }

            final exerciseName = exercise.name;
            final muscleGroup = _categoryToMuscleGroup(exercise.category);

            // Convert Exercise sets to AnalyticsSets
            // 🏋️ For bodyweight exercises, weight will be 0 (historical data doesn't have user body weight)
            final analyticsSets = validSets.map((set) {
              final effectiveWeight = isBodyweight ? 0.0 : set.weight!;
              return AnalyticsSet(
                weight: effectiveWeight,
                reps: set.actualReps ?? set.reps!,
                date: set.completedAt ?? sessionDate,
              );
            }).toList();

            SecureLogger.debug(
              'Created analytics sets for exercise',
              data: {
                'exerciseName': exercise.name,
                'setCount': analyticsSets.length,
              },
            );
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
          SecureLogger.error(
            'Error parsing workout document',
            error: e,
            stackTrace: stack,
            data: {'workoutId': workoutDoc.id},
          );
          // Skip malformed workout document
          continue;
        }
      }

      SecureLogger.info(
        'Parsing complete',
        data: {
          'parseErrors': parseErrors,
          'emptyExercisesCount': emptyExercisesCount,
          'processedWorkouts': processedWorkoutsWithExercises,
          'uniqueExercises': exerciseSessionsMap.length,
          'skippedExercises': skippedExercises.length,
        },
      );

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
        // Note: exerciseId uses exerciseName as fallback for legacy migration data
        final history = ExerciseHistory(
          exerciseId: exerciseName, // Fallback: use name as ID for legacy data
          exerciseName: exerciseName,
          muscleGroup:
              sessions.first.muscleGroup, // Use first session's muscle group
          sessions: sessions
              .map(
                (sessionData) => ExerciseSession(
                  exerciseName: sessionData.exerciseName,
                  muscleGroup: sessionData.muscleGroup,
                  sets: sessionData.sets,
                  date: sessionData.date,
                ),
              )
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
      SecureLogger.info(
        'Writing exercises to Firestore',
        data: {
          'exerciseCount': exerciseSessionsMap.length,
          'exercises': exerciseSessionsMap.keys.join(', '),
        },
      );

      await batch.commit();

      SecureLogger.info(
        'Migration complete',
        data: {
          'totalWorkouts': totalWorkouts,
          'uniqueExercises': exerciseSessionsMap.length,
          'totalSessions': totalSessions,
          'totalSets': totalSets,
        },
      );

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
  _ExerciseSessionData({
    required this.exerciseName,
    required this.muscleGroup,
    required this.date,
    required this.sets,
  });
  final String exerciseName;
  final String muscleGroup;
  final DateTime date;
  final List<AnalyticsSet> sets;
}
