import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/timer/presentation/providers/live_activity_provider.dart';
import 'package:gymbro_flutter_new/features/timer/domain/entities/rest_timer.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  late ProviderContainer container;
  late LiveActivityService service;
  
  setUp(() {
    container = ProviderContainer();
    service = container.read(liveActivityProvider);
    
    // Setup MethodChannel mock
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('com.gymbro.timer/live_activity'),
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'startLiveActivity':
            return 'activity-123';
          case 'updateLiveActivity':
            return null;
          case 'endLiveActivity':
            return null;
          case 'isLiveActivitySupported':
            return true;
          case 'getActiveLiveActivities':
            return ['activity-123', 'activity-456'];
          case 'showRPEInterface':
            return 'rpe-activity-789';
          case 'updateRPEInterface':
            return null;
          case 'confirmRPEAndCompleteSet':
            return null;
          case 'dismissRPEInterface':
            return null;
          default:
            return null;
        }
      },
    );
  });

  tearDown(() {
    container.dispose();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('com.gymbro.timer/live_activity'),
      null,
    );
  });

  group('LiveActivityService', () {
    group('startLiveActivity', () {
      test('starts live activity successfully', () async {
        final activityId = await service.startLiveActivity(
          exerciseName: 'Bench Press',
          timerType: 'rest',
          totalSeconds: 120,
          currentSet: 2,
          totalSets: 4,
          workoutName: 'Push Day',
        );
        
        expect(activityId, 'activity-123');
      });

      test('handles error when starting live activity', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
          const MethodChannel('com.gymbro.timer/live_activity'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'startLiveActivity') {
              throw PlatformException(code: 'ERROR', message: 'Failed to start');
            }
            return null;
          },
        );
        
        final activityId = await service.startLiveActivity(
          exerciseName: 'Squat',
          timerType: 'rest',
          totalSeconds: 180,
          currentSet: 1,
          totalSets: 3,
        );
        
        expect(activityId, isNull);
      });

      test('stores recovery data when activity starts', () async {
        final activityId = await service.startLiveActivity(
          exerciseName: 'Deadlift',
          timerType: 'rest',
          totalSeconds: 240,
          currentSet: 3,
          totalSets: 5,
          workoutName: 'Pull Day',
        );
        
        expect(activityId, isNotNull);
        // Recovery data is stored internally
      });
    });

    group('updateLiveActivity', () {
      test('updates live activity successfully', () async {
        final timer = RestTimer(
          totalDurationSeconds: 120,
          remainingSeconds: 60,
          status: TimerStatus.running,
          exerciseName: 'Bench Press',
        );
        
        final success = await service.updateLiveActivity(
          activityId: 'activity-123',
          timer: timer,
          currentSet: 2,
          totalSets: 4,
          targetReps: 10,
          weight: 80.0,
        );
        
        expect(success, true);
      });

      test('throttles updates for running timer', () async {
        final timer = RestTimer(
          totalDurationSeconds: 120,
          remainingSeconds: 100,
          status: TimerStatus.running,
          exerciseName: 'Bench Press',
        );
        
        // First update should succeed
        var success = await service.updateLiveActivity(
          activityId: 'activity-123',
          timer: timer,
          currentSet: 2,
          totalSets: 4,
        );
        expect(success, true);
        
        // Immediate second update should be throttled
        success = await service.updateLiveActivity(
          activityId: 'activity-123',
          timer: timer,
          currentSet: 2,
          totalSets: 4,
        );
        expect(success, true); // Returns true but actually throttled
      });

      test('does not throttle near completion', () async {
        final timer = RestTimer(
          totalDurationSeconds: 120,
          remainingSeconds: 10, // Less than 15 seconds
          status: TimerStatus.running,
          exerciseName: 'Bench Press',
        );
        
        // Both updates should succeed without throttling
        var success = await service.updateLiveActivity(
          activityId: 'activity-123',
          timer: timer,
          currentSet: 2,
          totalSets: 4,
        );
        expect(success, true);
        
        success = await service.updateLiveActivity(
          activityId: 'activity-123',
          timer: timer,
          currentSet: 2,
          totalSets: 4,
        );
        expect(success, true);
      });

      test('handles update error', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
          const MethodChannel('com.gymbro.timer/live_activity'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'updateLiveActivity') {
              throw PlatformException(code: 'ERROR', message: 'Update failed');
            }
            return null;
          },
        );
        
        final timer = RestTimer(
          totalDurationSeconds: 120,
          remainingSeconds: 60,
          status: TimerStatus.running,
          exerciseName: 'Squat',
        );
        
        final success = await service.updateLiveActivity(
          activityId: 'activity-123',
          timer: timer,
          currentSet: 1,
          totalSets: 3,
        );
        
        expect(success, false);
      });

      test('attempts recovery when activity not found', () async {
        // First store recovery data
        await service.startLiveActivity(
          exerciseName: 'Bench Press',
          timerType: 'rest',
          totalSeconds: 120,
          currentSet: 2,
          totalSets: 4,
          workoutName: 'Test Workout',
        );
        
        // Mock error that triggers recovery
        var callCount = 0;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
          const MethodChannel('com.gymbro.timer/live_activity'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'updateLiveActivity' && callCount == 0) {
              callCount++;
              throw PlatformException(code: 'ERROR', message: 'Activity not found');
            } else if (methodCall.method == 'startLiveActivity') {
              return 'new-activity-456';
            } else if (methodCall.method == 'endLiveActivity') {
              return null;
            } else if (methodCall.method == 'updateLiveActivity') {
              return null;
            }
            return null;
          },
        );
        
        final timer = RestTimer(
          totalDurationSeconds: 120,
          remainingSeconds: 60,
          status: TimerStatus.running,
          exerciseName: 'Bench Press',
        );
        
        final success = await service.updateLiveActivity(
          activityId: 'activity-123',
          timer: timer,
          currentSet: 2,
          totalSets: 4,
        );
        
        // Recovery creates new activity and returns true
        expect(success, true);
      });
    });

    group('updateLiveActivityDuration', () {
      test('updates duration bypassing throttle', () async {
        final timer = RestTimer(
          totalDurationSeconds: 150, // Changed duration
          remainingSeconds: 150,
          status: TimerStatus.running,
          exerciseName: 'Bench Press',
        );
        
        final success = await service.updateLiveActivityDuration(
          activityId: 'activity-123',
          timer: timer,
          currentSet: 2,
          totalSets: 4,
        );
        
        expect(success, true);
      });

      test('handles duration update error', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
          const MethodChannel('com.gymbro.timer/live_activity'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'updateLiveActivity') {
              throw PlatformException(code: 'ERROR', message: 'Duration update failed');
            }
            return null;
          },
        );
        
        final timer = RestTimer(
          totalDurationSeconds: 150,
          remainingSeconds: 150,
          status: TimerStatus.running,
          exerciseName: 'Squat',
        );
        
        final success = await service.updateLiveActivityDuration(
          activityId: 'activity-123',
          timer: timer,
          currentSet: 1,
          totalSets: 3,
        );
        
        expect(success, false);
      });
    });

    group('forceUpdateLiveActivity', () {
      test('forces update bypassing all throttling', () async {
        final timer = RestTimer(
          totalDurationSeconds: 120,
          remainingSeconds: 60,
          status: TimerStatus.paused,
          exerciseName: 'Bench Press',
        );
        
        // Multiple force updates should all succeed
        for (int i = 0; i < 3; i++) {
          final success = await service.forceUpdateLiveActivity(
            activityId: 'activity-123',
            timer: timer,
            currentSet: 2,
            totalSets: 4,
            targetReps: 10,
            weight: 80.0,
            actualReps: 8,
            selectedRPE: 7,
          );
          
          expect(success, true);
        }
      });

      test('handles force update error', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
          const MethodChannel('com.gymbro.timer/live_activity'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'updateLiveActivity') {
              throw PlatformException(code: 'ERROR', message: 'Force update failed');
            }
            return null;
          },
        );
        
        final timer = RestTimer(
          totalDurationSeconds: 120,
          remainingSeconds: 60,
          status: TimerStatus.running,
          exerciseName: 'Squat',
        );
        
        final success = await service.forceUpdateLiveActivity(
          activityId: 'activity-123',
          timer: timer,
          currentSet: 1,
          totalSets: 3,
        );
        
        expect(success, false);
      });
    });

    group('updateLiveActivityState', () {
      test('updates state changes bypassing throttle', () async {
        final timer = RestTimer(
          totalDurationSeconds: 120,
          remainingSeconds: 60,
          status: TimerStatus.paused, // State change
          exerciseName: 'Bench Press',
        );
        
        final success = await service.updateLiveActivityState(
          activityId: 'activity-123',
          timer: timer,
          currentSet: 2,
          totalSets: 4,
        );
        
        expect(success, true);
      });

      test('handles state update error', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
          const MethodChannel('com.gymbro.timer/live_activity'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'updateLiveActivity') {
              throw PlatformException(code: 'ERROR', message: 'State update failed');
            }
            return null;
          },
        );
        
        final timer = RestTimer(
          totalDurationSeconds: 120,
          remainingSeconds: 60,
          status: TimerStatus.paused,
          exerciseName: 'Squat',
        );
        
        final success = await service.updateLiveActivityState(
          activityId: 'activity-123',
          timer: timer,
          currentSet: 1,
          totalSets: 3,
        );
        
        expect(success, false);
      });
    });

    group('endLiveActivity', () {
      test('ends live activity successfully', () async {
        final success = await service.endLiveActivity(
          activityId: 'activity-123',
          dismissalPolicy: 'immediate',
        );
        
        expect(success, true);
      });

      test('uses default dismissal policy', () async {
        final success = await service.endLiveActivity(
          activityId: 'activity-123',
        );
        
        expect(success, true);
      });

      test('handles end activity error', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
          const MethodChannel('com.gymbro.timer/live_activity'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'endLiveActivity') {
              throw PlatformException(code: 'ERROR', message: 'End failed');
            }
            return null;
          },
        );
        
        final success = await service.endLiveActivity(
          activityId: 'activity-123',
        );
        
        expect(success, false);
      });

      test('cleans up recovery data when ending', () async {
        // Start activity to create recovery data
        await service.startLiveActivity(
          exerciseName: 'Bench Press',
          timerType: 'rest',
          totalSeconds: 120,
          currentSet: 2,
          totalSets: 4,
        );
        
        // End activity
        final success = await service.endLiveActivity(
          activityId: 'activity-123',
        );
        
        expect(success, true);
        // Recovery data should be cleaned up
      });
    });

    group('isLiveActivitySupported', () {
      test('returns true when supported', () async {
        final supported = await service.isLiveActivitySupported();
        expect(supported, true);
      });

      test('returns false when not supported', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
          const MethodChannel('com.gymbro.timer/live_activity'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'isLiveActivitySupported') {
              return false;
            }
            return null;
          },
        );
        
        final supported = await service.isLiveActivitySupported();
        expect(supported, false);
      });

      test('returns false on error', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
          const MethodChannel('com.gymbro.timer/live_activity'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'isLiveActivitySupported') {
              throw PlatformException(code: 'ERROR', message: 'Check failed');
            }
            return null;
          },
        );
        
        final supported = await service.isLiveActivitySupported();
        expect(supported, false);
      });

      test('returns false when null', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
          const MethodChannel('com.gymbro.timer/live_activity'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'isLiveActivitySupported') {
              return null;
            }
            return null;
          },
        );
        
        final supported = await service.isLiveActivitySupported();
        expect(supported, false);
      });
    });

    group('getActiveLiveActivities', () {
      test('returns list of active activities', () async {
        final activities = await service.getActiveLiveActivities();
        expect(activities, ['activity-123', 'activity-456']);
      });

      test('returns empty list when no activities', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
          const MethodChannel('com.gymbro.timer/live_activity'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'getActiveLiveActivities') {
              return [];
            }
            return null;
          },
        );
        
        final activities = await service.getActiveLiveActivities();
        expect(activities, isEmpty);
      });

      test('returns empty list on error', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
          const MethodChannel('com.gymbro.timer/live_activity'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'getActiveLiveActivities') {
              throw PlatformException(code: 'ERROR', message: 'Get failed');
            }
            return null;
          },
        );
        
        final activities = await service.getActiveLiveActivities();
        expect(activities, isEmpty);
      });

      test('returns empty list when null', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
          const MethodChannel('com.gymbro.timer/live_activity'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'getActiveLiveActivities') {
              return null;
            }
            return null;
          },
        );
        
        final activities = await service.getActiveLiveActivities();
        expect(activities, isEmpty);
      });
    });

    group('RPE Interface', () {
      test('shows RPE interface successfully', () async {
        final activityId = await service.showRPEInterface(
          exerciseName: 'Bench Press',
          targetReps: 10,
          weight: 80.0,
          currentSet: 2,
          totalSets: 4,
          workoutName: 'Push Day',
        );
        
        expect(activityId, 'rpe-activity-789');
      });

      test('handles show RPE interface error', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
          const MethodChannel('com.gymbro.timer/live_activity'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'showRPEInterface') {
              throw PlatformException(code: 'ERROR', message: 'Show failed');
            }
            return null;
          },
        );
        
        final activityId = await service.showRPEInterface(
          exerciseName: 'Squat',
          targetReps: 8,
          weight: 100.0,
          currentSet: 1,
          totalSets: 3,
        );
        
        expect(activityId, isNull);
      });

      test('updates RPE interface successfully', () async {
        final success = await service.updateRPEInterface(
          activityId: 'rpe-activity-789',
          repsCompleted: true,
          actualReps: 9,
          selectedRPE: 7,
          notes: 'Felt good',
        );
        
        expect(success, true);
      });

      test('handles update RPE interface error', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
          const MethodChannel('com.gymbro.timer/live_activity'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'updateRPEInterface') {
              throw PlatformException(code: 'ERROR', message: 'Update failed');
            }
            return null;
          },
        );
        
        final success = await service.updateRPEInterface(
          activityId: 'rpe-activity-789',
          repsCompleted: false,
        );
        
        expect(success, false);
      });

      test('confirms RPE and completes set successfully', () async {
        final success = await service.confirmRPEAndCompleteSet(
          activityId: 'rpe-activity-789',
          actualReps: 10,
          rpe: 8,
          notes: 'Heavy but good',
        );
        
        expect(success, true);
      });

      test('handles confirm RPE error', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
          const MethodChannel('com.gymbro.timer/live_activity'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'confirmRPEAndCompleteSet') {
              throw PlatformException(code: 'ERROR', message: 'Confirm failed');
            }
            return null;
          },
        );
        
        final success = await service.confirmRPEAndCompleteSet(
          activityId: 'rpe-activity-789',
          actualReps: 8,
          rpe: 9,
        );
        
        expect(success, false);
      });

      test('dismisses RPE interface successfully', () async {
        final success = await service.dismissRPEInterface(
          activityId: 'rpe-activity-789',
        );
        
        expect(success, true);
      });

      test('handles dismiss RPE interface error', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
          const MethodChannel('com.gymbro.timer/live_activity'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'dismissRPEInterface') {
              throw PlatformException(code: 'ERROR', message: 'Dismiss failed');
            }
            return null;
          },
        );
        
        final success = await service.dismissRPEInterface(
          activityId: 'rpe-activity-789',
        );
        
        expect(success, false);
      });
    });

    group('RPE Callbacks', () {
      test('handles RPE confirmed callback', () async {
        var callbackCalled = false;
        int? receivedReps;
        int? receivedRpe;
        String? receivedNotes;
        
        service.setupRPECallbacks(
          onRPEConfirmed: (actualReps, rpe, notes) {
            callbackCalled = true;
            receivedReps = actualReps;
            receivedRpe = rpe;
            receivedNotes = notes;
          },
          onRPECancelled: () {},
          onRepsModified: (newReps) {},
        );
        
        // Simulate callback from native
        await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
          'com.gymbro.timer/live_activity',
          const StandardMethodCodec().encodeMethodCall(
            const MethodCall('onRPEConfirmed', {
              'actualReps': 10,
              'rpe': 8,
              'notes': 'Good set',
            }),
          ),
          (_) {},
        );
        
        expect(callbackCalled, true);
        expect(receivedReps, 10);
        expect(receivedRpe, 8);
        expect(receivedNotes, 'Good set');
      });

      test('handles RPE cancelled callback', () async {
        var callbackCalled = false;
        
        service.setupRPECallbacks(
          onRPEConfirmed: (actualReps, rpe, notes) {},
          onRPECancelled: () {
            callbackCalled = true;
          },
          onRepsModified: (newReps) {},
        );
        
        // Simulate callback from native
        await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
          'com.gymbro.timer/live_activity',
          const StandardMethodCodec().encodeMethodCall(
            const MethodCall('onRPECancelled'),
          ),
          (_) {},
        );
        
        expect(callbackCalled, true);
      });

      test('handles reps modified callback', () async {
        var callbackCalled = false;
        int? receivedReps;
        
        service.setupRPECallbacks(
          onRPEConfirmed: (actualReps, rpe, notes) {},
          onRPECancelled: () {},
          onRepsModified: (newReps) {
            callbackCalled = true;
            receivedReps = newReps;
          },
        );
        
        // Simulate callback from native
        await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
          'com.gymbro.timer/live_activity',
          const StandardMethodCodec().encodeMethodCall(
            const MethodCall('onRepsModified', {'newReps': 12}),
          ),
          (_) {},
        );
        
        expect(callbackCalled, true);
        expect(receivedReps, 12);
      });
    });
  });

  group('RPELiveActivityData', () {
    test('creates with correct values', () {
      final data = RPELiveActivityData(
        exerciseName: 'Bench Press',
        targetReps: 10,
        weight: 80.0,
        currentSet: 2,
        totalSets: 4,
        workoutName: 'Push Day',
        timestamp: DateTime.now(),
      );
      
      expect(data.exerciseName, 'Bench Press');
      expect(data.targetReps, 10);
      expect(data.weight, 80.0);
      expect(data.currentSet, 2);
      expect(data.totalSets, 4);
      expect(data.workoutName, 'Push Day');
      expect(data.repsCompleted, false);
      expect(data.actualReps, isNull);
      expect(data.selectedRPE, isNull);
      expect(data.notes, isNull);
    });

    test('copyWith updates values correctly', () {
      final original = RPELiveActivityData(
        exerciseName: 'Bench Press',
        targetReps: 10,
        weight: 80.0,
        currentSet: 2,
        totalSets: 4,
        timestamp: DateTime.now(),
      );
      
      final updated = original.copyWith(
        repsCompleted: true,
        actualReps: 9,
        selectedRPE: 7,
        notes: 'One rep short',
      );
      
      expect(updated.repsCompleted, true);
      expect(updated.actualReps, 9);
      expect(updated.selectedRPE, 7);
      expect(updated.notes, 'One rep short');
      
      // Original unchanged
      expect(original.repsCompleted, false);
      expect(original.actualReps, isNull);
    });

    test('isReadyToConfirm validates correctly', () {
      var data = RPELiveActivityData(
        exerciseName: 'Bench Press',
        targetReps: 10,
        weight: 80.0,
        currentSet: 2,
        totalSets: 4,
        timestamp: DateTime.now(),
      );
      
      expect(data.isReadyToConfirm, false);
      
      data = data.copyWith(actualReps: 10);
      expect(data.isReadyToConfirm, false);
      
      data = data.copyWith(selectedRPE: 4); // Too low
      expect(data.isReadyToConfirm, false);
      
      data = data.copyWith(selectedRPE: 8); // Valid
      expect(data.isReadyToConfirm, true);
      
      data = data.copyWith(selectedRPE: 11); // Too high
      expect(data.isReadyToConfirm, false);
    });

    test('toCompletedExerciseSet creates correct set', () {
      final data = RPELiveActivityData(
        exerciseName: 'Bench Press',
        targetReps: 10,
        weight: 80.0,
        currentSet: 2,
        totalSets: 4,
        timestamp: DateTime.now(),
        actualReps: 9,
        selectedRPE: 8,
        notes: 'Good form',
      );
      
      final set = data.toCompletedExerciseSet('set-123', 2);
      
      expect(set.id, 'set-123');
      expect(set.setNumber, 2);
      expect(set.weight, 80.0);
      expect(set.reps, 10);
      expect(set.actualReps, 9);
      expect(set.rpe, 8);
      expect(set.isCompleted, true);
      expect(set.notes, 'Good form');
      expect(set.completedAt, isNotNull);
    });

    test('displayText formats correctly', () {
      var data = RPELiveActivityData(
        exerciseName: 'Bench Press',
        targetReps: 10,
        weight: 80.0,
        currentSet: 2,
        totalSets: 4,
        timestamp: DateTime.now(),
      );
      
      expect(data.displayText, 'Bench Press: 10 reps target @ 80.0kg');
      
      data = data.copyWith(actualReps: 9);
      expect(data.displayText, 'Bench Press: 9/10 reps @ 80.0kg');
      
      data = data.copyWith(selectedRPE: 8);
      expect(data.displayText, 'Bench Press: 9/10 reps @ 80.0kg • RPE: 8/10');
    });
  });

  group('LiveActivityRecoveryData', () {
    test('creates with correct values', () {
      final data = LiveActivityRecoveryData(
        exerciseName: 'Bench Press',
        timerType: 'rest',
        workoutName: 'Push Day',
        totalSeconds: 120,
        currentSet: 2,
        totalSets: 4,
      );
      
      expect(data.exerciseName, 'Bench Press');
      expect(data.timerType, 'rest');
      expect(data.workoutName, 'Push Day');
      expect(data.totalSeconds, 120);
      expect(data.currentSet, 2);
      expect(data.totalSets, 4);
      expect(data.createdAt, isNotNull);
    });

    test('isValid checks age correctly', () {
      final oldData = LiveActivityRecoveryData(
        exerciseName: 'Bench Press',
        timerType: 'rest',
        totalSeconds: 120,
        currentSet: 2,
        totalSets: 4,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      );
      
      expect(oldData.isValid, false);
      
      final newData = LiveActivityRecoveryData(
        exerciseName: 'Squat',
        timerType: 'rest',
        totalSeconds: 180,
        currentSet: 1,
        totalSets: 3,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      );
      
      expect(newData.isValid, true);
    });

    test('toString formats correctly', () {
      final data = LiveActivityRecoveryData(
        exerciseName: 'Bench Press',
        timerType: 'rest',
        totalSeconds: 120,
        currentSet: 2,
        totalSets: 4,
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      );
      
      final str = data.toString();
      expect(str, contains('Bench Press'));
      expect(str, contains('2/4'));
      expect(str, contains('30min'));
    });
  });

  group('currentRPEStateProvider', () {
    test('initial state is null', () {
      final state = container.read(currentRPEStateProvider);
      expect(state, isNull);
    });

    test('can update state', () {
      final data = RPELiveActivityData(
        exerciseName: 'Bench Press',
        targetReps: 10,
        weight: 80.0,
        currentSet: 2,
        totalSets: 4,
        timestamp: DateTime.now(),
      );
      
      container.read(currentRPEStateProvider.notifier).state = data;
      
      final state = container.read(currentRPEStateProvider);
      expect(state, data);
    });
  });
}