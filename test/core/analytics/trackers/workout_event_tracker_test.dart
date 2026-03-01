/// Tests for WorkoutEventTracker
///
/// Uses MockAnalyticsService (from lib) as a pure fake — no mockito/mocktail.
/// Verifies that each tracker method logs the correct event name and
/// parameter keys/values via the analytics service.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/core/analytics/analytics_constants.dart';
import 'package:gymbro_flutter_new/core/analytics/trackers/workout_event_tracker.dart';
import 'package:gymbro_flutter_new/core/services/analytics/mock_analytics_service.dart';

void main() {
  late MockAnalyticsService analytics;
  late WorkoutEventTracker tracker;

  setUp(() {
    analytics = MockAnalyticsService();
    tracker = WorkoutEventTracker(analytics);
  });

  // =========================================================================
  // trackWorkoutStarted
  // =========================================================================

  group('trackWorkoutStarted', () {
    test('logs workout_started event with required parameters', () async {
      await tracker.trackWorkoutStarted(
        workoutId: 'w-1',
        workoutType: 'strength',
      );

      expect(analytics.loggedEvents.length, 1);
      final event = analytics.loggedEvents.first;
      expect(event['name'], AnalyticsEvents.workoutStarted);
      final params = event['parameters'] as Map;
      expect(params[AnalyticsParameters.workoutId], 'w-1');
      expect(params[AnalyticsParameters.workoutType], 'strength');
      expect(params[AnalyticsParameters.source], 'unknown');
    });

    test('includes optional workoutName when provided', () async {
      await tracker.trackWorkoutStarted(
        workoutId: 'w-1',
        workoutType: 'cardio',
        workoutName: 'Morning Run',
      );
      final params = analytics.loggedEvents.first['parameters'] as Map;
      expect(params[AnalyticsParameters.workoutName], 'Morning Run');
    });

    test('omits workoutName when null', () async {
      await tracker.trackWorkoutStarted(
        workoutId: 'w-1',
        workoutType: 'strength',
      );
      final params = analytics.loggedEvents.first['parameters'] as Map;
      expect(params.containsKey(AnalyticsParameters.workoutName), isFalse);
    });

    test('includes optional templateId when provided', () async {
      await tracker.trackWorkoutStarted(
        workoutId: 'w-1',
        workoutType: 'strength',
        templateId: 'tmpl-42',
      );
      final params = analytics.loggedEvents.first['parameters'] as Map;
      expect(params[AnalyticsParameters.templateId], 'tmpl-42');
    });

    test('omits templateId when null', () async {
      await tracker.trackWorkoutStarted(
        workoutId: 'w-1',
        workoutType: 'strength',
      );
      final params = analytics.loggedEvents.first['parameters'] as Map;
      expect(params.containsKey(AnalyticsParameters.templateId), isFalse);
    });

    test('uses custom source', () async {
      await tracker.trackWorkoutStarted(
        workoutId: 'w-1',
        workoutType: 'hybrid',
        source: 'templates',
      );
      final params = analytics.loggedEvents.first['parameters'] as Map;
      expect(params[AnalyticsParameters.source], 'templates');
    });

    test('swallows analytics errors without throwing', () async {
      // Disable analytics so logEvent is a no-op but won't throw
      await analytics.setAnalyticsCollectionEnabled(false);
      await expectLater(
        tracker.trackWorkoutStarted(workoutId: 'w-1', workoutType: 'strength'),
        completes,
      );
    });
  });

  // =========================================================================
  // trackWorkoutPaused
  // =========================================================================

  group('trackWorkoutPaused', () {
    test('logs workout_paused event with required parameters', () async {
      await tracker.trackWorkoutPaused(
        workoutId: 'w-1',
        elapsedSeconds: 300,
      );

      expect(analytics.loggedEvents.length, 1);
      final event = analytics.loggedEvents.first;
      expect(event['name'], AnalyticsEvents.workoutPaused);
      final params = event['parameters'] as Map;
      expect(params[AnalyticsParameters.workoutId], 'w-1');
      expect(params[AnalyticsParameters.elapsedSeconds], 300);
    });
  });

  // =========================================================================
  // trackWorkoutResumed
  // =========================================================================

  group('trackWorkoutResumed', () {
    test('logs workout_resumed event with required parameters', () async {
      await tracker.trackWorkoutResumed(
        workoutId: 'w-2',
        pausedSeconds: 60,
      );

      expect(analytics.loggedEvents.length, 1);
      final event = analytics.loggedEvents.first;
      expect(event['name'], AnalyticsEvents.workoutResumed);
      final params = event['parameters'] as Map;
      expect(params[AnalyticsParameters.workoutId], 'w-2');
      expect(params[AnalyticsParameters.pausedSeconds], 60);
    });
  });

  // =========================================================================
  // trackWorkoutCompleted
  // =========================================================================

  group('trackWorkoutCompleted', () {
    test('logs workout_completed with all required parameters', () async {
      await tracker.trackWorkoutCompleted(
        workoutId: 'w-3',
        duration: 3600,
        exerciseCount: 8,
        totalSets: 24,
      );

      expect(analytics.loggedEvents.length, 1);
      final event = analytics.loggedEvents.first;
      expect(event['name'], AnalyticsEvents.workoutCompleted);
      final params = event['parameters'] as Map;
      expect(params[AnalyticsParameters.workoutId], 'w-3');
      expect(params[AnalyticsParameters.duration], 3600);
      expect(params[AnalyticsParameters.exerciseCount], 8);
      expect(params[AnalyticsParameters.totalSets], 24);
    });

    test('includes optional totalReps when provided', () async {
      await tracker.trackWorkoutCompleted(
        workoutId: 'w-3',
        duration: 3600,
        exerciseCount: 5,
        totalSets: 15,
        totalReps: 150,
      );
      final params = analytics.loggedEvents.first['parameters'] as Map;
      expect(params[AnalyticsParameters.totalReps], 150);
    });

    test('omits totalReps when null', () async {
      await tracker.trackWorkoutCompleted(
        workoutId: 'w-3',
        duration: 3600,
        exerciseCount: 5,
        totalSets: 15,
      );
      final params = analytics.loggedEvents.first['parameters'] as Map;
      expect(params.containsKey(AnalyticsParameters.totalReps), isFalse);
    });

    test('includes optional totalWeight when provided', () async {
      await tracker.trackWorkoutCompleted(
        workoutId: 'w-3',
        duration: 3600,
        exerciseCount: 5,
        totalSets: 15,
        totalWeight: 5000.0,
      );
      final params = analytics.loggedEvents.first['parameters'] as Map;
      expect(params[AnalyticsParameters.totalWeight], 5000.0);
    });

    test('includes completionRate when provided', () async {
      await tracker.trackWorkoutCompleted(
        workoutId: 'w-3',
        duration: 3600,
        exerciseCount: 5,
        totalSets: 15,
        completionRate: 90,
      );
      final params = analytics.loggedEvents.first['parameters'] as Map;
      expect(params[AnalyticsParameters.completionRate], 90);
    });

    test('includes workoutType when provided', () async {
      await tracker.trackWorkoutCompleted(
        workoutId: 'w-3',
        duration: 3600,
        exerciseCount: 5,
        totalSets: 15,
        workoutType: 'strength',
      );
      final params = analytics.loggedEvents.first['parameters'] as Map;
      expect(params[AnalyticsParameters.workoutType], 'strength');
    });

    test('includes sessionId when provided', () async {
      await tracker.trackWorkoutCompleted(
        workoutId: 'w-3',
        duration: 3600,
        exerciseCount: 5,
        totalSets: 15,
        sessionId: 'sess-abc',
      );
      final params = analytics.loggedEvents.first['parameters'] as Map;
      expect(params[AnalyticsParameters.sessionId], 'sess-abc');
    });

    test('omits sessionId when null', () async {
      await tracker.trackWorkoutCompleted(
        workoutId: 'w-3',
        duration: 3600,
        exerciseCount: 5,
        totalSets: 15,
      );
      final params = analytics.loggedEvents.first['parameters'] as Map;
      expect(params.containsKey(AnalyticsParameters.sessionId), isFalse);
    });
  });

  // =========================================================================
  // trackWorkoutCancelled
  // =========================================================================

  group('trackWorkoutCancelled', () {
    test('logs workout_cancelled with required parameters', () async {
      await tracker.trackWorkoutCancelled(
        workoutId: 'w-4',
        elapsedSeconds: 120,
      );

      expect(analytics.loggedEvents.length, 1);
      final event = analytics.loggedEvents.first;
      expect(event['name'], AnalyticsEvents.workoutCancelled);
      final params = event['parameters'] as Map;
      expect(params[AnalyticsParameters.workoutId], 'w-4');
      expect(params[AnalyticsParameters.elapsedSeconds], 120);
    });

    test('includes exerciseCount when provided', () async {
      await tracker.trackWorkoutCancelled(
        workoutId: 'w-4',
        elapsedSeconds: 120,
        exerciseCount: 3,
      );
      final params = analytics.loggedEvents.first['parameters'] as Map;
      expect(params[AnalyticsParameters.exerciseCount], 3);
    });

    test('omits exerciseCount when null', () async {
      await tracker.trackWorkoutCancelled(
        workoutId: 'w-4',
        elapsedSeconds: 120,
      );
      final params = analytics.loggedEvents.first['parameters'] as Map;
      expect(params.containsKey(AnalyticsParameters.exerciseCount), isFalse);
    });

    test('includes reason when provided', () async {
      await tracker.trackWorkoutCancelled(
        workoutId: 'w-4',
        elapsedSeconds: 120,
        reason: 'user_quit',
      );
      final params = analytics.loggedEvents.first['parameters'] as Map;
      expect(params[AnalyticsParameters.reason], 'user_quit');
    });

    test('omits reason when null', () async {
      await tracker.trackWorkoutCancelled(
        workoutId: 'w-4',
        elapsedSeconds: 120,
      );
      final params = analytics.loggedEvents.first['parameters'] as Map;
      expect(params.containsKey(AnalyticsParameters.reason), isFalse);
    });
  });

  // =========================================================================
  // trackExerciseAdded
  // =========================================================================

  group('trackExerciseAdded', () {
    test('logs exercise_added with required parameters', () async {
      await tracker.trackExerciseAdded(
        workoutId: 'w-1',
        exerciseId: 'e-1',
        exerciseName: 'Bench Press',
      );

      expect(analytics.loggedEvents.length, 1);
      final event = analytics.loggedEvents.first;
      expect(event['name'], AnalyticsEvents.exerciseAdded);
      final params = event['parameters'] as Map;
      expect(params[AnalyticsParameters.workoutId], 'w-1');
      expect(params[AnalyticsParameters.exerciseId], 'e-1');
      expect(params[AnalyticsParameters.exerciseName], 'Bench Press');
      expect(params[AnalyticsParameters.source], 'unknown');
    });

    test('includes category when provided', () async {
      await tracker.trackExerciseAdded(
        workoutId: 'w-1',
        exerciseId: 'e-1',
        exerciseName: 'Squat',
        exerciseCategory: 'legs',
      );
      final params = analytics.loggedEvents.first['parameters'] as Map;
      expect(params[AnalyticsParameters.exerciseCategory], 'legs');
    });

    test('includes sets and reps when provided', () async {
      await tracker.trackExerciseAdded(
        workoutId: 'w-1',
        exerciseId: 'e-1',
        exerciseName: 'Deadlift',
        sets: 3,
        reps: 5,
      );
      final params = analytics.loggedEvents.first['parameters'] as Map;
      expect(params[AnalyticsParameters.sets], 3);
      expect(params[AnalyticsParameters.reps], 5);
    });

    test('custom source is recorded', () async {
      await tracker.trackExerciseAdded(
        workoutId: 'w-1',
        exerciseId: 'e-1',
        exerciseName: 'Pull-up',
        source: 'recent',
      );
      final params = analytics.loggedEvents.first['parameters'] as Map;
      expect(params[AnalyticsParameters.source], 'recent');
    });
  });

  // =========================================================================
  // trackExerciseRemoved
  // =========================================================================

  group('trackExerciseRemoved', () {
    test('logs exercise_removed with required parameters', () async {
      await tracker.trackExerciseRemoved(
        workoutId: 'w-1',
        exerciseId: 'e-2',
        exerciseName: 'Overhead Press',
      );

      final event = analytics.loggedEvents.first;
      expect(event['name'], AnalyticsEvents.exerciseRemoved);
      final params = event['parameters'] as Map;
      expect(params[AnalyticsParameters.workoutId], 'w-1');
      expect(params[AnalyticsParameters.exerciseId], 'e-2');
      expect(params[AnalyticsParameters.exerciseName], 'Overhead Press');
    });
  });

  // =========================================================================
  // trackExerciseCustomized
  // =========================================================================

  group('trackExerciseCustomized', () {
    test('logs exercise_customized with all parameters', () async {
      await tracker.trackExerciseCustomized(
        workoutId: 'w-1',
        exerciseId: 'e-1',
        fieldChanged: 'sets',
        oldValue: 3,
        newValue: 4,
      );

      final event = analytics.loggedEvents.first;
      expect(event['name'], AnalyticsEvents.exerciseCustomized);
      final params = event['parameters'] as Map;
      expect(params[AnalyticsParameters.workoutId], 'w-1');
      expect(params[AnalyticsParameters.exerciseId], 'e-1');
      expect(params[AnalyticsParameters.fieldChanged], 'sets');
      expect(params[AnalyticsParameters.oldValue], '3');
      expect(params[AnalyticsParameters.newValue], '4');
    });

    test('converts dynamic values to strings', () async {
      await tracker.trackExerciseCustomized(
        workoutId: 'w-1',
        exerciseId: 'e-1',
        fieldChanged: 'weight',
        oldValue: 80.0,
        newValue: 82.5,
      );
      final params = analytics.loggedEvents.first['parameters'] as Map;
      expect(params[AnalyticsParameters.oldValue], '80.0');
      expect(params[AnalyticsParameters.newValue], '82.5');
    });
  });

  // =========================================================================
  // trackTemplateLoaded
  // =========================================================================

  group('trackTemplateLoaded', () {
    test('logs template_loaded with all parameters', () async {
      await tracker.trackTemplateLoaded(
        workoutId: 'w-1',
        templateId: 'tmpl-1',
        templateName: 'Push Day',
        exerciseCount: 6,
      );

      final event = analytics.loggedEvents.first;
      expect(event['name'], AnalyticsEvents.templateLoaded);
      final params = event['parameters'] as Map;
      expect(params[AnalyticsParameters.workoutId], 'w-1');
      expect(params[AnalyticsParameters.templateId], 'tmpl-1');
      expect(params[AnalyticsParameters.templateName], 'Push Day');
      expect(params[AnalyticsParameters.exerciseCount], 6);
    });
  });

  // =========================================================================
  // trackSetCompleted
  // =========================================================================

  group('trackSetCompleted', () {
    test('logs set_completed with required parameters', () async {
      await tracker.trackSetCompleted(
        workoutId: 'w-1',
        exerciseId: 'e-1',
        setNumber: 2,
        reps: 10,
      );

      final event = analytics.loggedEvents.first;
      expect(event['name'], AnalyticsEvents.setCompleted);
      final params = event['parameters'] as Map;
      expect(params[AnalyticsParameters.workoutId], 'w-1');
      expect(params[AnalyticsParameters.exerciseId], 'e-1');
      expect(params[AnalyticsParameters.setNumber], 2);
      expect(params[AnalyticsParameters.reps], 10);
    });

    test('includes weight when provided', () async {
      await tracker.trackSetCompleted(
        workoutId: 'w-1',
        exerciseId: 'e-1',
        setNumber: 1,
        reps: 5,
        weight: 100.0,
      );
      final params = analytics.loggedEvents.first['parameters'] as Map;
      expect(params[AnalyticsParameters.weight], 100.0);
    });

    test('omits weight when null', () async {
      await tracker.trackSetCompleted(
        workoutId: 'w-1',
        exerciseId: 'e-1',
        setNumber: 1,
        reps: 5,
      );
      final params = analytics.loggedEvents.first['parameters'] as Map;
      expect(params.containsKey(AnalyticsParameters.weight), isFalse);
    });

    test('includes rpe when provided', () async {
      await tracker.trackSetCompleted(
        workoutId: 'w-1',
        exerciseId: 'e-1',
        setNumber: 1,
        reps: 8,
        rpe: 8,
      );
      final params = analytics.loggedEvents.first['parameters'] as Map;
      expect(params[AnalyticsParameters.rpe], 8);
    });
  });

  // =========================================================================
  // trackRoutineDayCompleted
  // =========================================================================

  group('trackRoutineDayCompleted', () {
    test('logs routine_day_completed with required parameters', () async {
      final date = DateTime(2024, 1, 15);
      await tracker.trackRoutineDayCompleted(
        routineId: 'r-1',
        date: date,
        method: 'manual_with_workout',
      );

      final event = analytics.loggedEvents.first;
      expect(event['name'], AnalyticsEvents.routineDayCompleted);
      final params = event['parameters'] as Map;
      expect(params[AnalyticsParameters.routineId], 'r-1');
      expect(params['date'], date.toIso8601String());
      expect(params['completion_method'], 'manual_with_workout');
    });

    test('includes workoutId when provided', () async {
      await tracker.trackRoutineDayCompleted(
        routineId: 'r-1',
        date: DateTime(2024, 1, 15),
        method: 'manual_with_workout',
        workoutId: 'w-99',
      );
      final params = analytics.loggedEvents.first['parameters'] as Map;
      expect(params[AnalyticsParameters.workoutId], 'w-99');
    });

    test('omits workoutId when null', () async {
      await tracker.trackRoutineDayCompleted(
        routineId: 'r-1',
        date: DateTime(2024, 1, 15),
        method: 'manual_without_workout',
      );
      final params = analytics.loggedEvents.first['parameters'] as Map;
      expect(params.containsKey(AnalyticsParameters.workoutId), isFalse);
    });
  });

  // =========================================================================
  // Performance tracing — startSaveTrace / stopSaveTrace
  // =========================================================================

  group('startSaveTrace / stopSaveTrace', () {
    test('startSaveTrace returns a non-empty traceId', () async {
      final traceId = await tracker.startSaveTrace('w-1');
      expect(traceId, isNotEmpty);
    });

    test('startSaveTrace stores the trace internally', () async {
      await tracker.startSaveTrace('w-1');
      // After start, stopping should succeed (trace exists)
      await expectLater(
        tracker.stopSaveTrace(workoutId: 'w-1', success: true),
        completes,
      );
    });

    test('stopSaveTrace is no-op when no trace was started', () async {
      await expectLater(
        tracker.stopSaveTrace(workoutId: 'w-999', success: true),
        completes,
      );
    });

    test('stopSaveTrace passes exerciseCount metric', () async {
      await tracker.startSaveTrace('w-1');
      await tracker.stopSaveTrace(
        workoutId: 'w-1',
        exerciseCount: 7,
        success: true,
      );
      expect(analytics.completedTraces.length, 1);
      final metrics = analytics.completedTraces.first['metrics'] as Map;
      expect(metrics['exercise_count'], 7);
      expect(metrics['success'], 1);
    });

    test('stopSaveTrace records success=0 on failure', () async {
      await tracker.startSaveTrace('w-1');
      await tracker.stopSaveTrace(workoutId: 'w-1', success: false);
      final metrics = analytics.completedTraces.first['metrics'] as Map;
      expect(metrics['success'], 0);
    });

    test('removing a trace clears it from internal map', () async {
      await tracker.startSaveTrace('w-1');
      await tracker.stopSaveTrace(workoutId: 'w-1');
      // Stopping again should be a no-op (trace already removed)
      await expectLater(
        tracker.stopSaveTrace(workoutId: 'w-1'),
        completes,
      );
    });
  });

  // =========================================================================
  // traceSaveOperation
  // =========================================================================

  group('traceSaveOperation', () {
    test('returns result of operation', () async {
      final result = await tracker.traceSaveOperation<int>(
        workoutId: 'w-1',
        operation: () async => 42,
        exerciseCount: 5,
      );
      expect(result, 42);
    });

    test('records a completed trace', () async {
      await tracker.traceSaveOperation<void>(
        workoutId: 'w-1',
        operation: () async {},
      );
      expect(analytics.completedTraces.length, 1);
    });

    test('marks trace success=1 on successful operation', () async {
      await tracker.traceSaveOperation<void>(
        workoutId: 'w-1',
        operation: () async {},
        exerciseCount: 3,
      );
      final metrics = analytics.completedTraces.first['metrics'] as Map;
      expect(metrics['success'], 1);
    });

    test('marks trace success=0 and rethrows on operation failure', () async {
      await expectLater(
        tracker.traceSaveOperation<void>(
          workoutId: 'w-1',
          operation: () async => throw Exception('save failed'),
        ),
        throwsException,
      );
      final metrics = analytics.completedTraces.first['metrics'] as Map;
      expect(metrics['success'], 0);
    });
  });

  // =========================================================================
  // Analytics disabled — all track methods complete without recording events
  // =========================================================================

  group('when analytics is disabled', () {
    setUp(() async {
      await analytics.setAnalyticsCollectionEnabled(false);
    });

    test('trackWorkoutStarted does not record event', () async {
      await tracker.trackWorkoutStarted(workoutId: 'w', workoutType: 't');
      expect(analytics.loggedEvents, isEmpty);
    });

    test('trackWorkoutPaused does not record event', () async {
      await tracker.trackWorkoutPaused(workoutId: 'w', elapsedSeconds: 10);
      expect(analytics.loggedEvents, isEmpty);
    });

    test('trackWorkoutCompleted does not record event', () async {
      await tracker.trackWorkoutCompleted(
        workoutId: 'w',
        duration: 60,
        exerciseCount: 1,
        totalSets: 3,
      );
      expect(analytics.loggedEvents, isEmpty);
    });

    test('trackSetCompleted does not record event', () async {
      await tracker.trackSetCompleted(
        workoutId: 'w',
        exerciseId: 'e',
        setNumber: 1,
        reps: 10,
      );
      expect(analytics.loggedEvents, isEmpty);
    });
  });
}
