/// Analytics Aggregator DataSource
///
/// Aggregates user analytics data into AI context.
/// Fetches from analytics, history, recovery, and streak repositories.
///
/// **Layer**: Data - DataSource
/// **Feature**: AI Coach
library;

import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_context.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/metric_type.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/repositories/measurement_repository.dart';
import 'package:gymbro_flutter_new/features/history/data/repositories/workout_history_repository_enhanced.dart';
import 'package:gymbro_flutter_new/features/history/domain/entities/workout_history_detail.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/entities/onboarding_state.dart';
import 'package:gymbro_flutter_new/features/streak/data/repositories/streak_repository.dart';

/// Aggregates analytics data for AI Coach context
class AnalyticsAggregator {
  AnalyticsAggregator({
    required this.analyticsRepo,
    required this.historyRepo,
    required this.streakRepo,
    this.measurementRepo,
    this.onboardingState,
    this.accountTier = 'free',
  });

  final AnalyticsRepository analyticsRepo;
  final WorkoutHistoryRepositoryEnhanced historyRepo;
  final StreakRepository streakRepo;
  final MeasurementRepository? measurementRepo;
  final OnboardingState? onboardingState;
  final String accountTier;
  static const Duration _contextTaskTimeout = Duration(seconds: 8);
  static const Duration _weightTagTimeout = Duration(seconds: 4);

  /// Aggregate full user context for AI
  ///
  /// Returns [AIContext] with streak, last workout, top 5 1RM, recovery status
  Future<AIContext> aggregateContext({required String userId}) async {
    _debugLog('[AI_COACH] 🔍 Starting context aggregation for user: $userId');

    try {
      // Fetch all data in PARALLEL for better performance
      _debugLog('[AI_COACH] 📊 Fetching all context data in parallel...');

      // Fetch in parallelo con variabili tipizzate — evita cast per indice fragili
      final (streak, lastWorkout, top5, recovery) = await (
        _withTimeout<int>(
          label: 'getCurrentStreak',
          timeout: _contextTaskTimeout,
          fallback: 0,
          task: () => getCurrentStreak(userId),
        ),
        _withTimeout<WorkoutSummary?>(
          label: 'getLastWorkout',
          timeout: _contextTaskTimeout,
          fallback: null,
          task: () => getLastWorkout(userId),
        ),
        _withTimeout<Map<String, int>>(
          label: 'getTop5OneRM',
          timeout: _contextTaskTimeout,
          fallback: const <String, int>{},
          task: () => getTop5OneRM(userId),
        ),
        _withTimeout<RecoveryStatus>(
          label: 'getRecoveryStatus',
          timeout: _contextTaskTimeout,
          fallback: RecoveryStatus.green,
          task: () => getRecoveryStatus(userId),
        ),
      ).wait;

      _debugLog('[AI_COACH] ✅ Parallel fetch complete:');
      _debugLog('[AI_COACH]   - Streak: $streak days');
      _debugLog('[AI_COACH]   - Last workout: ${lastWorkout?.name ?? "none"}');
      _debugLog('[AI_COACH]   - Top 5 1RM: ${top5.length} exercises');
      _debugLog('[AI_COACH]   - Recovery: ${recovery.name}');

      final experienceLevel = _resolveExperienceLevel();
      final fitnessGoal = _resolveFitnessGoal();
      final weeklyTarget = onboardingState?.weeklyWorkoutTarget;
      final weightTag = await _withTimeout<String?>(
        label: '_resolveWeightTag',
        timeout: _weightTagTimeout,
        fallback: null,
        task: () => _resolveWeightTag(userId),
      );
      final goalParts = <String>[
        if (fitnessGoal != null) fitnessGoal,
        if (weeklyTarget != null) 'weekly_target:$weeklyTarget',
        if (weightTag != null) weightTag,
      ];
      final enrichedGoal = goalParts.isNotEmpty ? goalParts.join('|') : null;

      final context = AIContext(
        currentStreak: streak,
        lastWorkout: lastWorkout,
        top5OneRM: top5,
        recoveryStatus: recovery,
        userTier: accountTier,
        experienceLevel: experienceLevel,
        fitnessGoal: enrichedGoal,
      );

      _debugLog(
        '[AI_COACH] 🎯 Context aggregation complete:\n${context.toPromptString()}',
      );
      return context;
    } catch (e, stackTrace) {
      // Fallback to empty context on error
      _debugLog('[AI_COACH] ❌ Error aggregating context: $e');
      _debugLog('[AI_COACH] Stack: $stackTrace');

      return const AIContext(
        currentStreak: 0,
        top5OneRM: {},
        recoveryStatus: RecoveryStatus.green,
        userTier: 'free',
      );
    }
  }

  Future<T> _withTimeout<T>({
    required String label,
    required Duration timeout,
    required T fallback,
    required Future<T> Function() task,
  }) async {
    try {
      return await task().timeout(
        timeout,
        onTimeout: () {
          _debugLog(
            '[AI_COACH] ⚠️ Context task timed out: $label (${timeout.inSeconds}s), using fallback',
          );
          return fallback;
        },
      );
    } catch (e, stackTrace) {
      _debugLog('[AI_COACH] ⚠️ Context task failed: $label -> $e');
      _debugLog('[AI_COACH] Stack: $stackTrace');
      return fallback;
    }
  }

  String? _resolveExperienceLevel() {
    final fromAiStepData = onboardingState?.stepData['aiExperienceLevel']
        ?.toString();
    final normalizedAi = _normalizeExperienceLevel(fromAiStepData);
    if (normalizedAi != null) return normalizedAi;

    final onboarding = onboardingState?.userExperienceLevel;
    if (onboarding == 'beginner') return 'beginner';
    if (onboarding == 'expert') return 'experienced';
    return null;
  }

  String? _normalizeExperienceLevel(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final v = raw.toLowerCase().trim();

    if (v.contains('begin') || v.contains('principiante')) return 'beginner';
    if (v.contains('athlet') || v.contains('atleta')) return 'athlete';
    if (v.contains('advanced') ||
        v.contains('avanz') ||
        v.contains('expert') ||
        v.contains('esperto')) {
      return 'experienced';
    }
    if (v.contains('intermedio') ||
        v.contains('intermediate') ||
        v.contains('some')) {
      return 'some';
    }
    return null;
  }

  String? _resolveFitnessGoal() {
    final fromAiStepData = onboardingState?.stepData['aiGoal']?.toString();
    final normalizedAi = _normalizeGoal(fromAiStepData);
    if (normalizedAi != null) return normalizedAi;

    return switch (onboardingState?.userGoal) {
      'buildMuscle' => 'muscle',
      'loseWeight' => 'fat_loss',
      'getStronger' => 'strength',
      'stayFit' => 'endurance',
      _ => null,
    };
  }

  String? _normalizeGoal(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final v = raw.toLowerCase().trim();

    if (v.contains('muscle') || v.contains('massa') || v.contains('ipertrof')) {
      return 'muscle';
    }
    if (v.contains('strength') || v.contains('forza') || v.contains('power')) {
      return 'strength';
    }
    if (v.contains('ricompos') || v.contains('recomposition')) {
      return 'recomposition';
    }
    if (v.contains('fat') ||
        v.contains('dimagr') ||
        v.contains('lose') ||
        v.contains('peso')) {
      return 'fat_loss';
    }
    if (v.contains('endurance') ||
        v.contains('resistenza') ||
        v.contains('fit')) {
      return 'endurance';
    }
    return null;
  }

  Future<String?> _resolveWeightTag(String userId) async {
    if (measurementRepo == null) return null;

    try {
      final latestByType = await measurementRepo!.getLatestMeasurementsByType(
        userId,
      );

      return latestByType.fold((_) => null, (latest) {
        final weight = latest[MetricType.weight];
        if (weight == null) return null;
        return 'body_weight_kg:${weight.value.toStringAsFixed(1)}';
      });
    } catch (_) {
      return null;
    }
  }

  /// Get top 5 exercises by 1RM for the user
  ///
  /// Returns map of exercise name -> 1RM in kg
  Future<Map<String, int>> getTop5OneRM(String userId) async {
    try {
      _debugLog('[AI_COACH] 💪 getTop5OneRM - userId: $userId');

      // Analytics repo returns Stream<Either<Failure, List<ExerciseHistory>>>
      // We need to get the first value from the stream
      final exerciseHistoryStream = analyticsRepo.getExerciseHistory(userId);

      // Get first emit with timeout to prevent indefinite blocking
      final firstResult = await exerciseHistoryStream.first.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          _debugLog('[AI_COACH] ⚠️ Timeout waiting for exercise history');
          return const Right(<ExerciseHistory>[]);
        },
      );

      // Handle Either result
      return firstResult.fold(
        (failure) {
          _debugLog(
            '[AI_COACH] ❌ Failed to get exercise history: ${failure.message}',
          );
          return <String, int>{};
        },
        (exercises) {
          _debugLog(
            '[AI_COACH] ✅ Got ${exercises.length} exercises from analytics',
          );

          // Extract top 5 by highest estimated 1RM
          final recordsMap = <String, int>{};

          for (final exercise in exercises) {
            if (exercise.sessions.isNotEmpty) {
              // Get highest 1RM from all sessions
              final highestRM = exercise.sessions
                  .map((s) => s.highestEstimated1RM)
                  .reduce((a, b) => a > b ? a : b);

              recordsMap[exercise.exerciseName] = highestRM.round();
            }
          }

          // Sort by 1RM descending
          final sorted = recordsMap.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          final top5 = Map.fromEntries(sorted.take(5));
          _debugLog('[AI_COACH] 💪 Top 5 1RM: $top5');

          return top5;
        },
      );
    } catch (e, stackTrace) {
      _debugLog('[AI_COACH] ❌ Error in getTop5OneRM: $e');
      _debugLog('[AI_COACH] Stack: $stackTrace');
      return {};
    }
  }

  /// Get current workout streak in days
  Future<int> getCurrentStreak(String userId) async {
    try {
      _debugLog('[AI_COACH] 📊 getCurrentStreak - userId: $userId');

      final streak = await streakRepo.getCurrentStreak();
      final days = streak.currentStreak;

      _debugLog('[AI_COACH] ✅ Current streak: $days days');
      return days;
    } catch (e, stackTrace) {
      _debugLog('[AI_COACH] ❌ Error in getCurrentStreak: $e');
      _debugLog('[AI_COACH] Stack: $stackTrace');
      return 0;
    }
  }

  /// Get last completed workout summary
  Future<WorkoutSummary?> getLastWorkout(String userId) async {
    try {
      _debugLog('[AI_COACH] 📝 getLastWorkout - userId: $userId');

      // Call getWorkouts() which returns Either<Failure, List<WorkoutHistoryDetail>>
      final workoutsEither = await historyRepo.getWorkouts();

      return workoutsEither.fold(
        (failure) {
          _debugLog('[AI_COACH] ❌ Failed to get workouts: ${failure.message}');
          return null;
        },
        (workouts) {
          _debugLog(
            '[AI_COACH] ✅ Got ${workouts.length} workouts from history',
          );

          if (workouts.isEmpty) {
            _debugLog('[AI_COACH] ℹ️ No workouts found');
            return null;
          }

          // Get most recent workout (already sorted by date)
          final last = workouts.first;

          final summary = WorkoutSummary(
            id: last.id,
            name: last.name,
            completedAt: last.completedAt,
            exerciseCount: last.exercises.length,
            durationMinutes: last.duration.inMinutes,
          );

          _debugLog(
            '[AI_COACH] 📝 Last workout: ${summary.name} (${summary.completedAt})',
          );
          return summary;
        },
      );
    } catch (e, stackTrace) {
      _debugLog('[AI_COACH] ❌ Error in getLastWorkout: $e');
      _debugLog('[AI_COACH] Stack: $stackTrace');
      return null;
    }
  }

  /// Get user recovery status based on recent training load
  Future<RecoveryStatus> getRecoveryStatus(String userId) async {
    // Simple heuristic: check workout frequency in last 7 days
    try {
      _debugLog('[AI_COACH] 🏃 getRecoveryStatus - userId: $userId');

      final workoutsEither = await historyRepo.getWorkouts();

      return workoutsEither.fold(
        (failure) {
          _debugLog(
            '[AI_COACH] ❌ Failed to get workouts for recovery: ${failure.message}',
          );
          return RecoveryStatus.green;
        },
        (allWorkouts) {
          // Filter last 7 days
          final lastWeek = allWorkouts.where((WorkoutHistoryDetail w) {
            return w.completedAt.isAfter(
              DateTime.now().subtract(const Duration(days: 7)),
            );
          }).length;

          _debugLog('[AI_COACH] 🏃 Workouts in last 7 days: $lastWeek');

          // Unified thresholds: >=6 red, >=4 amber, <4 green
          if (lastWeek >= 6) {
            _debugLog('[AI_COACH] 🔴 Very high frequency - recovery red');
            return RecoveryStatus.red; // Overtraining risk
          }
          if (lastWeek >= 4) {
            _debugLog('[AI_COACH] ⚠️ High frequency - recovery amber');
            return RecoveryStatus.amber; // High frequency
          }

          _debugLog('[AI_COACH] ✅ Low frequency - well recovered');
          return RecoveryStatus.green; // Low frequency, well recovered
        },
      );
    } catch (e, stackTrace) {
      _debugLog('[AI_COACH] ❌ Error in getRecoveryStatus: $e');
      _debugLog('[AI_COACH] Stack: $stackTrace');
      return RecoveryStatus.green;
    }
  }

  void _debugLog(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }
}
