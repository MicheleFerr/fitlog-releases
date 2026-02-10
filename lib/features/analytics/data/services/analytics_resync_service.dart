/// Analytics Re-Sync Service
///
/// Service to re-synchronize all workout data to the analytics collection.
/// Use this when analytics data is missing or out of sync.
///
/// **Usage**:
/// ```dart
/// final service = AnalyticsResyncService(
///   analyticsRepo: ref.read(analyticsRepositoryProvider),
///   historyRepo: ref.read(workoutHistoryRepositoryProvider),
/// );
///
/// await service.resyncAllWorkouts(
///   userId: user.uid,
///   onProgress: (current, total, exerciseName) {
///     print('Syncing $current/$total: $exerciseName');
///   },
/// );
/// ```
library;

import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/analytics/data/converters/workout_to_analytics_converter.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:gymbro_flutter_new/features/history/data/repositories/workout_history_repository_enhanced.dart';

/// Progress callback for resync operation
typedef ResyncProgressCallback = void Function(
  int current,
  int total,
  String exerciseName,
);

/// Result of resync operation
class ResyncResult {
  const ResyncResult({
    required this.workoutsProcessed,
    required this.exercisesSynced,
    required this.errors,
    required this.duration,
  });

  final int workoutsProcessed;
  final int exercisesSynced;
  final List<String> errors;
  final Duration duration;

  bool get hasErrors => errors.isNotEmpty;

  @override
  String toString() => '''
ResyncResult:
  - Workouts processed: $workoutsProcessed
  - Exercises synced: $exercisesSynced
  - Errors: ${errors.length}
  - Duration: ${duration.inSeconds}s
${errors.isNotEmpty ? '  - Error details:\n${errors.map((e) => '    • $e').join('\n')}' : ''}
''';
}

/// Service to re-synchronize workout data to analytics collection
class AnalyticsResyncService {
  AnalyticsResyncService({
    required this.analyticsRepo,
    required this.historyRepo,
  });

  final AnalyticsRepository analyticsRepo;
  final WorkoutHistoryRepositoryEnhanced historyRepo;

  /// Re-sync all workouts to analytics collection
  ///
  /// This will:
  /// 1. Fetch all workouts from history
  /// 2. Convert each workout to analytics format
  /// 3. Update analytics collection for each exercise
  ///
  /// **WARNING**: This may take a while for users with many workouts.
  /// Consider running in background or with progress indicator.
  Future<ResyncResult> resyncAllWorkouts({
    required String userId,
    ResyncProgressCallback? onProgress,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final stopwatch = Stopwatch()..start();
    final errors = <String>[];
    var exercisesSynced = 0;

    debugPrint('🔄 [RESYNC] Starting analytics resync for user: $userId');
    if (fromDate != null) {
      debugPrint('   From: $fromDate');
    }
    if (toDate != null) {
      debugPrint('   To: $toDate');
    }

    try {
      // 1. Fetch all workouts
      final workoutsResult = await historyRepo.getWorkouts();

      return await workoutsResult.fold(
        (failure) {
          errors.add('Failed to fetch workouts: ${failure.message}');
          stopwatch.stop();
          return ResyncResult(
            workoutsProcessed: 0,
            exercisesSynced: 0,
            errors: errors,
            duration: stopwatch.elapsed,
          );
        },
        (workouts) async {
          debugPrint('📊 [RESYNC] Found ${workouts.length} workouts to process');

          // Filter by date if specified
          var filteredWorkouts = workouts;
          if (fromDate != null) {
            filteredWorkouts = filteredWorkouts
                .where((w) => w.completedAt.isAfter(fromDate))
                .toList();
          }
          if (toDate != null) {
            filteredWorkouts = filteredWorkouts
                .where((w) => w.completedAt.isBefore(toDate))
                .toList();
          }

          debugPrint(
            '📊 [RESYNC] Processing ${filteredWorkouts.length} workouts after date filter',
          );

          // 2. Process each workout
          for (var i = 0; i < filteredWorkouts.length; i++) {
            final workout = filteredWorkouts[i];

            debugPrint(
              '🔄 [RESYNC] Processing workout ${i + 1}/${filteredWorkouts.length}: '
              '"${workout.name}" (${workout.completedAt.toIso8601String().substring(0, 10)})',
            );

            // Convert WorkoutHistoryDetail to Workout for the converter
            final workoutEntity = workout.toWorkout();

            // Skip if no valid exercises
            if (!WorkoutToAnalyticsConverter.canConvert(workoutEntity)) {
              debugPrint('   ⏭️ Skipping - no valid sets');
              continue;
            }

            // 3. Convert workout to analytics format
            final analyticsDataList = WorkoutToAnalyticsConverter.convert(workoutEntity);

            // 4. Update analytics for each exercise
            for (final data in analyticsDataList) {
              onProgress?.call(
                exercisesSynced + 1,
                filteredWorkouts.length * 5, // Estimate
                data.exerciseName,
              );

              debugPrint(
                '   📊 Syncing "${data.exerciseName}" - '
                '${data.session.sets.length} sets, '
                'max ${data.session.maxWeight}kg, '
                'est1RM ${data.session.highestEstimated1RM.toStringAsFixed(1)}kg',
              );

              final result = await analyticsRepo.updateExerciseHistory(
                userId: userId,
                exerciseId: data.exerciseId,
                exerciseName: data.exerciseName,
                muscleGroup: data.muscleGroup,
                session: data.session,
              );

              result.fold(
                (failure) {
                  final errorMsg =
                      'Failed to sync "${data.exerciseName}": ${failure.message}';
                  errors.add(errorMsg);
                  debugPrint('   ❌ $errorMsg');
                },
                (_) {
                  exercisesSynced++;
                  debugPrint('   ✅ Synced "${data.exerciseName}"');
                },
              );
            }
          }

          stopwatch.stop();

          final result = ResyncResult(
            workoutsProcessed: filteredWorkouts.length,
            exercisesSynced: exercisesSynced,
            errors: errors,
            duration: stopwatch.elapsed,
          );

          debugPrint('🎉 [RESYNC] Complete!\n$result');

          return result;
        },
      );
    } catch (e, stackTrace) {
      errors.add('Exception during resync: $e');
      debugPrint('❌ [RESYNC] Exception: $e');
      debugPrint('   Stack: $stackTrace');

      stopwatch.stop();
      return ResyncResult(
        workoutsProcessed: 0,
        exercisesSynced: exercisesSynced,
        errors: errors,
        duration: stopwatch.elapsed,
      );
    }
  }

  /// Re-sync only recent workouts (last N days)
  ///
  /// Convenience method for syncing only recent data.
  Future<ResyncResult> resyncRecentWorkouts({
    required String userId,
    int days = 30,
    ResyncProgressCallback? onProgress,
  }) async {
    final fromDate = DateTime.now().subtract(Duration(days: days));
    return resyncAllWorkouts(
      userId: userId,
      fromDate: fromDate,
      onProgress: onProgress,
    );
  }

  /// Clear analytics and resync from scratch
  ///
  /// **WARNING**: This deletes all existing analytics data first!
  /// Only use if analytics is severely corrupted.
  Future<ResyncResult> clearAndResync({
    required String userId,
    ResyncProgressCallback? onProgress,
  }) async {
    debugPrint('⚠️ [RESYNC] Clearing all analytics before resync...');

    // Note: clearCache only clears local cache, not Firestore data
    // For full reset, would need deleteAllAnalytics (if implemented)
    final clearResult = await analyticsRepo.clearCache();
    clearResult.fold(
      (failure) => debugPrint('   ❌ Failed to clear cache: ${failure.message}'),
      (_) => debugPrint('   ✅ Cache cleared'),
    );

    return resyncAllWorkouts(
      userId: userId,
      onProgress: onProgress,
    );
  }
}
