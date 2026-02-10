/// Analytics Auto-Sync Service
///
/// Automatically synchronizes workout data to analytics when the AI Coach opens.
/// Detects missing sync by comparing workout history dates with analytics session dates.
///
/// **Optimization**:
/// - Saves last sync timestamp in SharedPreferences
/// - Only performs full check if there are workouts newer than last sync
/// - Avoids unnecessary Firestore reads on every AI Coach open
///
/// **Usage**:
/// ```dart
/// final service = AnalyticsAutoSyncService(
///   analyticsRepo: ref.read(analyticsRepositoryProvider),
///   historyRepo: ref.read(workoutHistoryRepositoryProvider),
/// );
///
/// await service.ensureSynced(userId: user.uid);
/// ```
library;

import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/analytics/data/converters/workout_to_analytics_converter.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:gymbro_flutter_new/features/history/data/repositories/workout_history_repository_enhanced.dart';
import 'package:gymbro_flutter_new/features/history/domain/entities/workout_history_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Result of auto-sync check
class AutoSyncResult {
  const AutoSyncResult({
    required this.wasNeeded,
    required this.workoutsSynced,
    required this.exercisesSynced,
    this.error,
  });

  final bool wasNeeded;
  final int workoutsSynced;
  final int exercisesSynced;
  final String? error;

  bool get hasError => error != null;

  @override
  String toString() => wasNeeded
      ? 'AutoSyncResult: synced $workoutsSynced workouts, $exercisesSynced exercises'
      : 'AutoSyncResult: no sync needed';
}

/// Service to auto-sync workout data to analytics collection
class AnalyticsAutoSyncService {
  AnalyticsAutoSyncService({
    required this.analyticsRepo,
    required this.historyRepo,
  });

  final AnalyticsRepository analyticsRepo;
  final WorkoutHistoryRepositoryEnhanced historyRepo;

  /// SharedPreferences key for last sync timestamp
  static const _lastSyncKey = 'analytics_auto_sync_last_timestamp';

  /// Get last sync timestamp from SharedPreferences
  Future<DateTime?> _getLastSyncTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_lastSyncKey);
      if (timestamp == null) return null;
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } catch (e) {
      debugPrint('[AUTO_SYNC] Failed to read last sync timestamp: $e');
      return null;
    }
  }

  /// Save last sync timestamp to SharedPreferences
  Future<void> _saveLastSyncTimestamp(DateTime timestamp) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastSyncKey, timestamp.millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('[AUTO_SYNC] Failed to save last sync timestamp: $e');
    }
  }

  /// Check if sync is needed and perform it automatically
  ///
  /// **Optimization Logic**:
  /// 1. Check last sync timestamp from SharedPreferences
  /// 2. Get recent workouts from history (lightweight, local Hive)
  /// 3. If no workouts newer than last sync → SKIP (no Firestore reads!)
  /// 4. Only if needed: fetch analytics and sync missing data
  ///
  /// **Performance**: Avoids Firestore reads in most cases (when data is up-to-date)
  Future<AutoSyncResult> ensureSynced({
    required String userId,
    int maxDaysToCheck = 30,
  }) async {
    debugPrint('🔄 [AUTO_SYNC] Checking if analytics sync is needed...');

    try {
      // 1. Get last sync timestamp
      final lastSync = await _getLastSyncTimestamp();
      debugPrint('   Last sync: ${lastSync != null ? _formatDate(lastSync) : "never"}');

      // 2. Get recent workouts from history (lightweight - from local Hive)
      final workoutsResult = await historyRepo.getWorkouts();

      return await workoutsResult.fold(
        (failure) {
          debugPrint('❌ [AUTO_SYNC] Failed to fetch workouts: ${failure.message}');
          return AutoSyncResult(
            wasNeeded: false,
            workoutsSynced: 0,
            exercisesSynced: 0,
            error: 'Failed to fetch workouts: ${failure.message}',
          );
        },
        (workouts) async {
          // Filter to recent workouts only
          final cutoffDate = DateTime.now().subtract(Duration(days: maxDaysToCheck));
          final recentWorkouts = workouts
              .where((w) => w.completedAt.isAfter(cutoffDate))
              .toList()
            ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

          if (recentWorkouts.isEmpty) {
            debugPrint('ℹ️ [AUTO_SYNC] No recent workouts to check');
            return const AutoSyncResult(
              wasNeeded: false,
              workoutsSynced: 0,
              exercisesSynced: 0,
            );
          }

          // 3. OPTIMIZATION: Check if any workout is newer than last sync
          // If not, we can skip the expensive Firestore read entirely!
          if (lastSync != null) {
            final newestWorkout = recentWorkouts.first.completedAt;
            if (newestWorkout.isBefore(lastSync) ||
                newestWorkout.difference(lastSync).inMinutes < 5) {
              debugPrint('✅ [AUTO_SYNC] No new workouts since last sync - skipping Firestore check');
              return const AutoSyncResult(
                wasNeeded: false,
                workoutsSynced: 0,
                exercisesSynced: 0,
              );
            }
            debugPrint('📋 [AUTO_SYNC] Found workouts newer than last sync - checking Firestore');
          }

          debugPrint('📊 [AUTO_SYNC] Found ${recentWorkouts.length} workouts in last $maxDaysToCheck days');

          // 4. Get existing analytics data (only if needed)
          final analyticsStream = analyticsRepo.getExerciseHistory(userId);
          final analyticsResult = await analyticsStream.first;

          return await analyticsResult.fold(
            (failure) {
              debugPrint('❌ [AUTO_SYNC] Failed to fetch analytics: ${failure.message}');
              return AutoSyncResult(
                wasNeeded: false,
                workoutsSynced: 0,
                exercisesSynced: 0,
                error: 'Failed to fetch analytics: ${failure.message}',
              );
            },
            (analyticsData) async {
              // Build a map of exercise -> latest session date
              final latestAnalyticsDates = <String, DateTime>{};
              for (final history in analyticsData) {
                if (history.sessions.isNotEmpty) {
                  final latestSession = history.sessions
                      .reduce((a, b) => a.date.isAfter(b.date) ? a : b);
                  latestAnalyticsDates[history.exerciseName.toLowerCase()] = latestSession.date;
                }
              }

              debugPrint('📊 [AUTO_SYNC] Found ${analyticsData.length} exercises in analytics');

              // 3. Find workouts that need syncing
              final workoutsToSync = <WorkoutHistoryDetail>[];

              for (final workout in recentWorkouts) {
                final needsSync = _workoutNeedsSync(
                  workout: workout,
                  latestAnalyticsDates: latestAnalyticsDates,
                );

                if (needsSync) {
                  workoutsToSync.add(workout);
                }
              }

              if (workoutsToSync.isEmpty) {
                debugPrint('✅ [AUTO_SYNC] All recent workouts are synced');
                // Save timestamp so we don't check again until new workout
                await _saveLastSyncTimestamp(DateTime.now());
                return const AutoSyncResult(
                  wasNeeded: false,
                  workoutsSynced: 0,
                  exercisesSynced: 0,
                );
              }

              debugPrint('⚠️ [AUTO_SYNC] Found ${workoutsToSync.length} workouts needing sync');

              // 4. Sync missing workouts
              var exercisesSynced = 0;
              var workoutsSynced = 0;

              for (final workout in workoutsToSync) {
                final workoutEntity = workout.toWorkout();

                if (!WorkoutToAnalyticsConverter.canConvert(workoutEntity)) {
                  debugPrint('   ⏭️ Skipping "${workout.name}" - no valid sets');
                  continue;
                }

                debugPrint('   🔄 Syncing "${workout.name}" (${_formatDate(workout.completedAt)})');

                final analyticsDataList = WorkoutToAnalyticsConverter.convert(workoutEntity);

                for (final data in analyticsDataList) {
                  final result = await analyticsRepo.updateExerciseHistory(
                    userId: userId,
                    exerciseId: data.exerciseId,
                    exerciseName: data.exerciseName,
                    muscleGroup: data.muscleGroup,
                    session: data.session,
                  );

                  result.fold(
                    (failure) {
                      debugPrint('   ❌ Failed to sync "${data.exerciseName}": ${failure.message}');
                    },
                    (_) {
                      exercisesSynced++;
                      debugPrint('   ✅ Synced "${data.exerciseName}"');
                    },
                  );
                }

                workoutsSynced++;
              }

              debugPrint('🎉 [AUTO_SYNC] Complete: $workoutsSynced workouts, $exercisesSynced exercises');

              // Save sync timestamp for optimization on next open
              await _saveLastSyncTimestamp(DateTime.now());

              return AutoSyncResult(
                wasNeeded: true,
                workoutsSynced: workoutsSynced,
                exercisesSynced: exercisesSynced,
              );
            },
          );
        },
      );
    } catch (e, stackTrace) {
      debugPrint('❌ [AUTO_SYNC] Exception: $e');
      debugPrint('   Stack: $stackTrace');
      return AutoSyncResult(
        wasNeeded: false,
        workoutsSynced: 0,
        exercisesSynced: 0,
        error: 'Exception: $e',
      );
    }
  }

  /// Check if a workout needs syncing
  ///
  /// A workout needs sync if ANY of its exercises:
  /// - Doesn't exist in analytics at all, OR
  /// - Has analytics but with older date than workout completion
  bool _workoutNeedsSync({
    required WorkoutHistoryDetail workout,
    required Map<String, DateTime> latestAnalyticsDates,
  }) {
    for (final exercise in workout.exercises) {
      // Skip exercises without valid sets (weight > 0 and reps > 0)
      // All sets in history are already completed
      final hasValidSets = exercise.sets.any((s) => s.weight > 0 && s.reps > 0);
      if (!hasValidSets) continue;

      final exerciseNameLower = exercise.name.toLowerCase();
      final analyticsDate = latestAnalyticsDates[exerciseNameLower];

      if (analyticsDate == null) {
        // Exercise not in analytics at all
        debugPrint('   📋 "${exercise.name}" not found in analytics');
        return true;
      }

      // Compare dates (workout date should be in analytics)
      // Allow 1 day tolerance for timezone differences
      final workoutDate = workout.completedAt;
      final daysDiff = workoutDate.difference(analyticsDate).inDays;

      if (daysDiff > 1) {
        debugPrint(
          '   📋 "${exercise.name}" analytics outdated: '
          'workout ${_formatDate(workoutDate)}, analytics ${_formatDate(analyticsDate)}',
        );
        return true;
      }
    }

    return false;
  }

  /// Format date as YYYY-MM-DD
  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
