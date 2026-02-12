/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: core/analytics/trackers
/// 🎯 Feature: analytics
/// 🔧 Type: tracker helper
///
/// Workout event tracking helper
library;

import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/core/analytics/analytics_constants.dart';
import 'package:gymbro_flutter_new/core/services/analytics/i_analytics_service.dart';

/// Workout event tracker
///
/// Helper class for tracking workout lifecycle events and exercise operations.
/// Provides convenient methods with predefined event names and parameters.
///
/// Tracks:
/// - Workout lifecycle (start, pause, resume, complete, cancel)
/// - Exercise operations (add, remove, reorder, customize)
/// - Set tracking (completed, skipped)
/// - Performance metrics (duration, total weight, etc.)
///
/// Usage:
/// ```dart
/// final tracker = WorkoutEventTracker(analytics);
///
/// // Start workout
/// await tracker.trackWorkoutStarted(
///   workoutId: 'workout_123',
///   workoutType: 'strength',
/// );
///
/// // Complete workout with stats
/// await tracker.trackWorkoutCompleted(
///   workoutId: 'workout_123',
///   duration: 3600,
///   exerciseCount: 8,
///   totalSets: 24,
///   totalWeight: 5000,
/// );
/// ```
class WorkoutEventTracker {
  WorkoutEventTracker(this.analytics);

  final IAnalyticsService analytics;

  /// Active traces for workout operations
  final Map<String, String> _activeTraces = {};

  // ===== WORKOUT LIFECYCLE =====

  /// Track workout started
  ///
  /// Logs when user starts a workout session.
  ///
  /// Parameters:
  /// - [workoutId] - Unique workout identifier
  /// - [workoutType] - Type of workout (strength, cardio, hybrid)
  /// - [workoutName] - Optional workout name
  /// - [templateId] - Optional template ID if from template
  /// - [source] - Where workout was started (home, templates, routines)
  Future<void> trackWorkoutStarted({
    required String workoutId,
    required String workoutType,
    String? workoutName,
    String? templateId,
    String source = 'unknown',
  }) async {
    try {
      await analytics.logEvent(
        name: AnalyticsEvents.workoutStarted,
        parameters: {
          AnalyticsParameters.workoutId: workoutId,
          AnalyticsParameters.workoutType: workoutType,
          if (workoutName != null) AnalyticsParameters.workoutName: workoutName,
          if (templateId != null) AnalyticsParameters.templateId: templateId,
          AnalyticsParameters.source: source,
        },
      );

      if (kDebugMode) {
        debugPrint('📊 Workout started: $workoutId ($workoutType) from $source');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error tracking workout started: $e');
      }
    }
  }

  /// Track workout paused
  ///
  /// Logs when user pauses an active workout.
  ///
  /// Parameters:
  /// - [workoutId] - Workout identifier
  /// - [elapsedSeconds] - Time elapsed before pause
  Future<void> trackWorkoutPaused({
    required String workoutId,
    required int elapsedSeconds,
  }) async {
    try {
      await analytics.logEvent(
        name: AnalyticsEvents.workoutPaused,
        parameters: {
          AnalyticsParameters.workoutId: workoutId,
          AnalyticsParameters.elapsedSeconds: elapsedSeconds,
        },
      );

      if (kDebugMode) {
        debugPrint('📊 Workout paused: $workoutId after ${elapsedSeconds}s');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error tracking workout paused: $e');
      }
    }
  }

  /// Track workout resumed
  ///
  /// Logs when user resumes a paused workout.
  ///
  /// Parameters:
  /// - [workoutId] - Workout identifier
  /// - [pausedSeconds] - Duration of pause
  Future<void> trackWorkoutResumed({
    required String workoutId,
    required int pausedSeconds,
  }) async {
    try {
      await analytics.logEvent(
        name: AnalyticsEvents.workoutResumed,
        parameters: {
          AnalyticsParameters.workoutId: workoutId,
          AnalyticsParameters.pausedSeconds: pausedSeconds,
        },
      );

      if (kDebugMode) {
        debugPrint('📊 Workout resumed: $workoutId after ${pausedSeconds}s pause');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error tracking workout resumed: $e');
      }
    }
  }

  /// Track workout completed
  ///
  /// Logs when user successfully completes a workout with full statistics.
  ///
  /// Parameters:
  /// - [workoutId] - Workout identifier
  /// - [duration] - Total workout duration in seconds
  /// - [exerciseCount] - Number of exercises performed
  /// - [totalSets] - Total sets completed
  /// - [totalReps] - Optional total reps
  /// - [totalWeight] - Optional total weight lifted (in kg)
  /// - [completionRate] - Percentage of planned workout completed (0-100)
  /// - [workoutType] - Type of workout
  /// - [sessionId] - Optional session ID for funnel correlation
  Future<void> trackWorkoutCompleted({
    required String workoutId,
    required int duration,
    required int exerciseCount,
    required int totalSets,
    int? totalReps,
    double? totalWeight,
    int? completionRate,
    String? workoutType,
    String? sessionId, // ✅ FIX #8: Add sessionId for funnel correlation
  }) async {
    try {
      await analytics.logEvent(
        name: AnalyticsEvents.workoutCompleted,
        parameters: {
          AnalyticsParameters.workoutId: workoutId,
          AnalyticsParameters.duration: duration,
          AnalyticsParameters.exerciseCount: exerciseCount,
          AnalyticsParameters.totalSets: totalSets,
          if (totalReps != null) AnalyticsParameters.totalReps: totalReps,
          if (totalWeight != null) AnalyticsParameters.totalWeight: totalWeight,
          if (completionRate != null) AnalyticsParameters.completionRate: completionRate,
          if (workoutType != null) AnalyticsParameters.workoutType: workoutType,
          if (sessionId != null) AnalyticsParameters.sessionId: sessionId, // ✅ FIX #8: Include sessionId
        },
      );

      if (kDebugMode) {
        debugPrint('📊 Workout completed: $workoutId');
        debugPrint('   Duration: ${duration}s, Exercises: $exerciseCount, Sets: $totalSets');
        if (totalWeight != null) {
          debugPrint('   Total weight: ${totalWeight}kg');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error tracking workout completed: $e');
      }
    }
  }

  /// Track workout cancelled
  ///
  /// Logs when user abandons a workout before completion.
  ///
  /// Parameters:
  /// - [workoutId] - Workout identifier
  /// - [elapsedSeconds] - Time elapsed before cancellation
  /// - [exerciseCount] - Exercises added before cancellation
  /// - [reason] - Optional cancellation reason
  Future<void> trackWorkoutCancelled({
    required String workoutId,
    required int elapsedSeconds,
    int? exerciseCount,
    String? reason,
  }) async {
    try {
      await analytics.logEvent(
        name: AnalyticsEvents.workoutCancelled,
        parameters: {
          AnalyticsParameters.workoutId: workoutId,
          AnalyticsParameters.elapsedSeconds: elapsedSeconds,
          if (exerciseCount != null) AnalyticsParameters.exerciseCount: exerciseCount,
          if (reason != null) AnalyticsParameters.reason: reason,
        },
      );

      if (kDebugMode) {
        debugPrint('📊 Workout cancelled: $workoutId after ${elapsedSeconds}s');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error tracking workout cancelled: $e');
      }
    }
  }

  // ===== EXERCISE OPERATIONS =====

  /// Track exercise added
  ///
  /// Logs when user adds an exercise to workout.
  ///
  /// Parameters:
  /// - [workoutId] - Workout identifier
  /// - [exerciseId] - Exercise identifier
  /// - [exerciseName] - Exercise name
  /// - [exerciseCategory] - Category (chest, back, legs, etc.)
  /// - [sets] - Number of sets
  /// - [reps] - Number of reps (or null for custom)
  /// - [source] - How exercise was added (search, template, recent)
  Future<void> trackExerciseAdded({
    required String workoutId,
    required String exerciseId,
    required String exerciseName,
    String? exerciseCategory,
    int? sets,
    int? reps,
    String source = 'unknown',
  }) async {
    try {
      await analytics.logEvent(
        name: AnalyticsEvents.exerciseAdded,
        parameters: {
          AnalyticsParameters.workoutId: workoutId,
          AnalyticsParameters.exerciseId: exerciseId,
          AnalyticsParameters.exerciseName: exerciseName,
          if (exerciseCategory != null)
            AnalyticsParameters.exerciseCategory: exerciseCategory,
          if (sets != null) AnalyticsParameters.sets: sets,
          if (reps != null) AnalyticsParameters.reps: reps,
          AnalyticsParameters.source: source,
        },
      );

      if (kDebugMode) {
        debugPrint('📊 Exercise added: $exerciseName to $workoutId (source: $source)');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error tracking exercise added: $e');
      }
    }
  }

  /// Track exercise removed
  ///
  /// Logs when user removes an exercise from workout.
  ///
  /// Parameters:
  /// - [workoutId] - Workout identifier
  /// - [exerciseId] - Exercise identifier
  /// - [exerciseName] - Exercise name
  Future<void> trackExerciseRemoved({
    required String workoutId,
    required String exerciseId,
    required String exerciseName,
  }) async {
    try {
      await analytics.logEvent(
        name: AnalyticsEvents.exerciseRemoved,
        parameters: {
          AnalyticsParameters.workoutId: workoutId,
          AnalyticsParameters.exerciseId: exerciseId,
          AnalyticsParameters.exerciseName: exerciseName,
        },
      );

      if (kDebugMode) {
        debugPrint('📊 Exercise removed: $exerciseName from $workoutId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error tracking exercise removed: $e');
      }
    }
  }

  /// Track exercise customized
  ///
  /// Logs when user customizes exercise parameters (sets/reps/weight).
  ///
  /// Parameters:
  /// - [workoutId] - Workout identifier
  /// - [exerciseId] - Exercise identifier
  /// - [fieldChanged] - What was changed (sets, reps, weight, rest_time)
  /// - [oldValue] - Previous value
  /// - [newValue] - New value
  Future<void> trackExerciseCustomized({
    required String workoutId,
    required String exerciseId,
    required String fieldChanged,
    required dynamic oldValue,
    required dynamic newValue,
  }) async {
    try {
      await analytics.logEvent(
        name: AnalyticsEvents.exerciseCustomized,
        parameters: {
          AnalyticsParameters.workoutId: workoutId,
          AnalyticsParameters.exerciseId: exerciseId,
          AnalyticsParameters.fieldChanged: fieldChanged,
          AnalyticsParameters.oldValue: oldValue.toString(),
          AnalyticsParameters.newValue: newValue.toString(),
        },
      );

      if (kDebugMode) {
        debugPrint('📊 Exercise customized: $exerciseId - $fieldChanged: $oldValue → $newValue');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error tracking exercise customized: $e');
      }
    }
  }

  // ===== TEMPLATE EVENTS =====

  /// Track template loaded
  ///
  /// Logs when user starts a workout from a template.
  /// This is different from individual exercise_added events.
  ///
  /// Parameters:
  /// - [workoutId] - Workout identifier
  /// - [templateId] - Template identifier
  /// - [templateName] - Template name
  /// - [exerciseCount] - Number of exercises in template
  Future<void> trackTemplateLoaded({
    required String workoutId,
    required String templateId,
    required String templateName,
    required int exerciseCount,
  }) async {
    try {
      await analytics.logEvent(
        name: AnalyticsEvents.templateLoaded,
        parameters: {
          AnalyticsParameters.workoutId: workoutId,
          AnalyticsParameters.templateId: templateId,
          AnalyticsParameters.templateName: templateName,
          AnalyticsParameters.exerciseCount: exerciseCount,
        },
      );

      if (kDebugMode) {
        debugPrint('📊 Template loaded: $templateName ($exerciseCount exercises) for workout $workoutId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error tracking template loaded: $e');
      }
    }
  }

  // ===== SET TRACKING =====

  /// Track set completed
  ///
  /// Logs when user completes a set.
  ///
  /// Parameters:
  /// - [workoutId] - Workout identifier
  /// - [exerciseId] - Exercise identifier
  /// - [setNumber] - Set number (1, 2, 3, etc.)
  /// - [reps] - Reps completed
  /// - [weight] - Weight used (optional)
  /// - [rpe] - Rate of Perceived Exertion 1-10 (optional)
  Future<void> trackSetCompleted({
    required String workoutId,
    required String exerciseId,
    required int setNumber,
    required int reps,
    double? weight,
    int? rpe,
  }) async {
    try {
      await analytics.logEvent(
        name: AnalyticsEvents.setCompleted,
        parameters: {
          AnalyticsParameters.workoutId: workoutId,
          AnalyticsParameters.exerciseId: exerciseId,
          AnalyticsParameters.setNumber: setNumber,
          AnalyticsParameters.reps: reps,
          if (weight != null) AnalyticsParameters.weight: weight,
          if (rpe != null) AnalyticsParameters.rpe: rpe,
        },
      );

      if (kDebugMode) {
        debugPrint('📊 Set completed: Exercise $exerciseId - Set $setNumber ($reps reps${weight != null ? ' @ ${weight}kg' : ''})');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error tracking set completed: $e');
      }
    }
  }

  // ===== PERFORMANCE TRACING =====

  /// Start tracing workout save operation
  ///
  /// Call this before saving workout, then call [stopSaveTrace] after.
  ///
  /// Parameters:
  /// - [workoutId] - Workout identifier
  ///
  /// Returns trace ID to pass to [stopSaveTrace]
  Future<String> startSaveTrace(String workoutId) async {
    try {
      final traceId = await analytics.startTrace(AnalyticsTraces.saveWorkout);
      _activeTraces[workoutId] = traceId;

      if (kDebugMode) {
        debugPrint('⏱️ Started save trace for workout: $workoutId');
      }

      return traceId;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error starting save trace: $e');
      }
      rethrow;
    }
  }

  /// Stop tracing workout save operation
  ///
  /// Call this after save completes.
  ///
  /// Parameters:
  /// - [workoutId] - Workout identifier
  /// - [exerciseCount] - Number of exercises saved
  /// - [success] - Whether save succeeded
  Future<void> stopSaveTrace({
    required String workoutId,
    int? exerciseCount,
    bool success = true,
  }) async {
    try {
      final traceId = _activeTraces[workoutId];
      if (traceId == null) return;

      await analytics.stopTrace(
        traceId,
        metrics: {
          if (exerciseCount != null) 'exercise_count': exerciseCount,
          'success': success ? 1 : 0,
        },
      );

      _activeTraces.remove(workoutId);

      if (kDebugMode) {
        debugPrint('⏱️ Stopped save trace for workout: $workoutId (success: $success)');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error stopping save trace: $e');
      }
    }
  }

  /// Trace complete save operation
  ///
  /// Convenience method that automatically starts and stops trace.
  ///
  /// Usage:
  /// ```dart
  /// await tracker.traceSaveOperation(
  ///   workoutId: 'workout_123',
  ///   operation: () async => await saveWorkout(),
  ///   exerciseCount: 8,
  /// );
  /// ```
  Future<T> traceSaveOperation<T>({
    required String workoutId,
    required Future<T> Function() operation,
    int? exerciseCount,
  }) async {
    await startSaveTrace(workoutId);
    try {
      final result = await operation();
      await stopSaveTrace(
        workoutId: workoutId,
        exerciseCount: exerciseCount,
        success: true,
      );
      return result;
    } catch (e) {
      await stopSaveTrace(
        workoutId: workoutId,
        exerciseCount: exerciseCount,
        success: false,
      );
      rethrow;
    }
  }

  // ===== ROUTINE EVENTS =====

  /// Track manual routine day completion
  ///
  /// Logs when user manually completes a routine day via the WorkoutSelectorSheet.
  ///
  /// Parameters:
  /// - [routineId] - Routine identifier
  /// - [date] - Date of the completed day
  /// - [method] - Completion method: 'manual_with_workout' or 'manual_without_workout'
  /// - [workoutId] - Optional workout ID if completed with workout
  /// Track routine day completed using IAnalyticsService instance
  ///
  /// NOTE: Converted from static to instance method to use IAnalyticsService
  /// instead of direct FirebaseAnalytics.instance access.
  Future<void> trackRoutineDayCompleted({
    required String routineId,
    required DateTime date,
    required String method,
    String? workoutId,
  }) async {
    try {
      await analytics.logEvent(
        name: AnalyticsEvents.routineDayCompleted,
        parameters: {
          AnalyticsParameters.routineId: routineId,
          'date': date.toIso8601String(),
          'completion_method': method,
          if (workoutId != null) AnalyticsParameters.workoutId: workoutId,
        },
      );

      if (kDebugMode) {
        debugPrint('📊 Routine day completed: $routineId on ${date.toIso8601String()} ($method)');
        if (workoutId != null) {
          debugPrint('   Linked workout: $workoutId');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error tracking routine day completed: $e');
      }
    }
  }
}
