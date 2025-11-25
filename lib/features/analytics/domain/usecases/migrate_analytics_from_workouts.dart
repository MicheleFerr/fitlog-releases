/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/domain/usecases
/// 🎯 Feature: analytics
/// 🔧 Type: use case
///
/// Migrate Analytics From Workouts Use Case
///
/// **Purpose**: Populate analytics collection from existing workouts (one-time migration)
///
/// **Use Case**: Admin runs this to backfill analytics for workouts saved before analytics feature
///
/// **What it does**:
/// 1. Reads all workouts from local storage (Hive)
/// 2. Converts to analytics sessions using WorkoutToAnalyticsConverter
/// 3. Updates analytics collection in Firestore
///
/// **Usage** (from admin screen):
/// ```dart
/// final useCase = ref.read(migrateAnalyticsUseCaseProvider);
/// final result = await useCase.execute(userId: currentUser.uid);
/// result.fold(
///   (failure) => print('Error: $failure'),
///   (stats) => print('Migrated ${stats.totalExercises} exercises from ${stats.totalWorkouts} workouts'),
/// );
/// ```
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gymbro_flutter_new/features/analytics/data/converters/workout_to_analytics_converter.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:gymbro_flutter_new/features/workout/data/datasources/hive_workout_datasource.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';

/// Migration statistics
class MigrationStats {
  const MigrationStats({
    required this.totalWorkouts,
    required this.totalExercises,
    required this.uniqueExercises,
    required this.skippedWorkouts,
  });

  final int totalWorkouts;
  final int totalExercises;
  final Set<String> uniqueExercises;
  final int skippedWorkouts;

  @override
  String toString() {
    return 'MigrationStats('
        'totalWorkouts: $totalWorkouts, '
        'totalExercises: $totalExercises, '
        'uniqueExercises: ${uniqueExercises.length}, '
        'skippedWorkouts: $skippedWorkouts)';
  }
}

/// Use case for migrating analytics from existing workouts
class MigrateAnalyticsFromWorkouts {
  MigrateAnalyticsFromWorkouts({
    required HiveWorkoutDataSource localDataSource,
    required AnalyticsRepository analyticsRepository,
  })  : _localDataSource = localDataSource,
        _analyticsRepository = analyticsRepository;

  final HiveWorkoutDataSource _localDataSource;
  final AnalyticsRepository _analyticsRepository;

  /// Execute migration
  ///
  /// **Returns**: Either<Failure, MigrationStats>
  ///
  /// **Process**:
  /// 1. Read all workouts from Hive
  /// 2. Filter completed workouts only
  /// 3. Convert to analytics using WorkoutToAnalyticsConverter
  /// 4. Update analytics repository
  ///
  /// **Example**:
  /// ```dart
  /// final result = await migrateAnalyticsUseCase.execute(userId: 'user123');
  /// result.fold(
  ///   (failure) => showError(failure.message),
  ///   (stats) => showSuccess('Migrated ${stats.totalExercises} exercises'),
  /// );
  /// ```
  Future<Either<Failure, MigrationStats>> execute({
    required String userId,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('📊 [MigrateAnalytics] Starting migration for user: $userId');
      }

      // 1. Read all workouts from local storage
      final workouts = await _localDataSource.getAllWorkouts(userId);

      if (workouts.isEmpty) {
        if (kDebugMode) {
          debugPrint('ℹ️ [MigrateAnalytics] No workouts found');
        }
        return const Right(MigrationStats(
          totalWorkouts: 0,
          totalExercises: 0,
          uniqueExercises: {},
          skippedWorkouts: 0,
        ));
      }

      if (kDebugMode) {
        debugPrint('📊 [MigrateAnalytics] Found ${workouts.length} workouts');
      }

      // 2. Process each workout
      int totalWorkouts = 0;
      int totalExercises = 0;
      int skippedWorkouts = 0;
      final Set<String> uniqueExercises = {};

      for (final workoutModel in workouts) {
        try {
          final workout = workoutModel.toDomain();

          // Skip incomplete workouts
          if (!workout.isCompleted) {
            skippedWorkouts++;
            continue;
          }

          // Convert to analytics data
          final analyticsData = WorkoutToAnalyticsConverter.convert(workout);

          if (analyticsData.isEmpty) {
            if (kDebugMode) {
              debugPrint('   ⚠️ [MigrateAnalytics] No valid exercises in workout: ${workout.name}');
            }
            skippedWorkouts++;
            continue;
          }

          if (kDebugMode) {
            debugPrint('   📝 [MigrateAnalytics] Processing workout: ${workout.name} (${analyticsData.length} exercises)');
          }

          // Update analytics for each exercise
          for (final data in analyticsData) {
            uniqueExercises.add(data.exerciseName);

            await _analyticsRepository.updateExerciseHistory(
              userId: userId,
              exerciseName: data.exerciseName,
              muscleGroup: data.muscleGroup,
              session: data.session,
            );

            totalExercises++;

            if (kDebugMode) {
              debugPrint('      ✅ [MigrateAnalytics] Updated analytics for ${data.exerciseName}');
            }
          }

          totalWorkouts++;
        } catch (e) {
          if (kDebugMode) {
            debugPrint('   ❌ [MigrateAnalytics] Error processing workout: $e');
          }
          skippedWorkouts++;
        }
      }

      // 3. Return stats
      final stats = MigrationStats(
        totalWorkouts: totalWorkouts,
        totalExercises: totalExercises,
        uniqueExercises: uniqueExercises,
        skippedWorkouts: skippedWorkouts,
      );

      if (kDebugMode) {
        debugPrint('✅ [MigrateAnalytics] Migration complete: $stats');
      }

      return Right(stats);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [MigrateAnalytics] Migration failed: $e');
      }
      return Left(UnexpectedFailure('Migration failed: $e'));
    }
  }
}
