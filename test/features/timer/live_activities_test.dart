import 'package:flutter_test/flutter_test.dart';
import 'dart:async';

// Mock Live Activity Manager for iOS
class LiveActivityManager {
  bool _isSupported = false;
  LiveActivityState? _currentActivity;
  final List<LiveActivityEvent> _eventHistory = [];
  final StreamController<LiveActivityState> _stateController = StreamController<LiveActivityState>.broadcast();
  Timer? _countdownTimer;
  
  LiveActivityState? get currentActivity => _currentActivity;
  List<LiveActivityEvent> get eventHistory => List.unmodifiable(_eventHistory);
  Stream<LiveActivityState> get stateStream => _stateController.stream;
  
  // Initialize and check support
  Future<void> initialize() async {
    // Simulate iOS check
    _isSupported = _checkiOSSupport();
    
    if (_isSupported) {
      _logEvent(LiveActivityEvent(
        type: LiveActivityEventType.initialized,
        timestamp: DateTime.now(),
      ));
    }
  }
  
  bool _checkiOSSupport() {
    // In real app, would check Platform.isIOS && iOS version >= 16.1
    // For testing, we'll simulate support
    return true; // Simulating iOS environment
  }
  
  bool get isSupported => _isSupported;
  
  // Start Live Activity for rest timer
  Future<LiveActivityResult> startRestTimerActivity({
    required String exerciseName,
    required int durationSeconds,
    required int currentSet,
    required int totalSets,
    String? nextExerciseName,
  }) async {
    if (!_isSupported) {
      return LiveActivityResult(
        success: false,
        error: 'Live Activities not supported on this device',
      );
    }
    
    if (_currentActivity != null) {
      return LiveActivityResult(
        success: false,
        error: 'Another Live Activity is already running',
      );
    }
    
    // Simulate activity creation
    await Future.delayed(const Duration(milliseconds: 100));
    
    _currentActivity = LiveActivityState(
      id: 'la-${DateTime.now().millisecondsSinceEpoch}',
      type: LiveActivityType.restTimer,
      exerciseName: exerciseName,
      durationSeconds: durationSeconds,
      remainingSeconds: durationSeconds,
      currentSet: currentSet,
      totalSets: totalSets,
      nextExerciseName: nextExerciseName,
      startTime: DateTime.now(),
      isActive: true,
      isPaused: false,
    );
    
    _stateController.add(_currentActivity!);
    
    _logEvent(LiveActivityEvent(
      type: LiveActivityEventType.started,
      timestamp: DateTime.now(),
      activityId: _currentActivity!.id,
      metadata: {
        'exercise': exerciseName,
        'duration': durationSeconds,
      },
    ));
    
    // Start countdown timer
    _startCountdown();
    
    return LiveActivityResult(
      success: true,
      activityId: _currentActivity!.id,
    );
  }
  
  // Start workout Live Activity
  Future<LiveActivityResult> startWorkoutActivity({
    required String workoutName,
    required int totalExercises,
    required int completedExercises,
    String? currentExercise,
    Duration? elapsedTime,
  }) async {
    if (!_isSupported) {
      return LiveActivityResult(
        success: false,
        error: 'Live Activities not supported',
      );
    }
    
    if (_currentActivity != null) {
      return LiveActivityResult(
        success: false,
        error: 'Another Live Activity is already running',
      );
    }
    
    await Future.delayed(const Duration(milliseconds: 100));
    
    _currentActivity = LiveActivityState(
      id: 'la-${DateTime.now().millisecondsSinceEpoch}',
      type: LiveActivityType.workout,
      workoutName: workoutName,
      totalExercises: totalExercises,
      completedExercises: completedExercises,
      currentExercise: currentExercise,
      elapsedTime: elapsedTime ?? Duration.zero,
      startTime: DateTime.now(),
      isActive: true,
      isPaused: false,
    );
    
    _stateController.add(_currentActivity!);
    
    _logEvent(LiveActivityEvent(
      type: LiveActivityEventType.started,
      timestamp: DateTime.now(),
      activityId: _currentActivity!.id,
      metadata: {
        'workout': workoutName,
        'exercises': totalExercises,
      },
    ));
    
    return LiveActivityResult(
      success: true,
      activityId: _currentActivity!.id,
    );
  }
  
  // Update Live Activity
  Future<LiveActivityResult> updateActivity({
    int? remainingSeconds,
    int? completedExercises,
    String? currentExercise,
    Duration? elapsedTime,
    bool? isPaused,
  }) async {
    if (_currentActivity == null) {
      return LiveActivityResult(
        success: false,
        error: 'No active Live Activity',
      );
    }
    
    if (!_currentActivity!.isActive) {
      return LiveActivityResult(
        success: false,
        error: 'Live Activity is not active',
      );
    }
    
    // Update state
    if (_currentActivity!.type == LiveActivityType.restTimer) {
      _currentActivity = _currentActivity!.copyWith(
        remainingSeconds: remainingSeconds ?? _currentActivity!.remainingSeconds,
        isPaused: isPaused ?? _currentActivity!.isPaused,
      );
    } else if (_currentActivity!.type == LiveActivityType.workout) {
      _currentActivity = _currentActivity!.copyWith(
        completedExercises: completedExercises ?? _currentActivity!.completedExercises,
        currentExercise: currentExercise ?? _currentActivity!.currentExercise,
        elapsedTime: elapsedTime ?? _currentActivity!.elapsedTime,
        isPaused: isPaused ?? _currentActivity!.isPaused,
      );
    }
    
    // Only add to stream if controller is not closed
    if (!_stateController.isClosed) {
      _stateController.add(_currentActivity!);
    }
    
    _logEvent(LiveActivityEvent(
      type: LiveActivityEventType.updated,
      timestamp: DateTime.now(),
      activityId: _currentActivity!.id,
    ));
    
    return LiveActivityResult(
      success: true,
      activityId: _currentActivity!.id,
    );
  }
  
  // End Live Activity
  Future<LiveActivityResult> endActivity({String? finalMessage}) async {
    if (_currentActivity == null) {
      return LiveActivityResult(
        success: false,
        error: 'No active Live Activity',
      );
    }
    
    // Cancel timer if running
    _countdownTimer?.cancel();
    _countdownTimer = null;
    
    final activityId = _currentActivity!.id;
    
    _currentActivity = _currentActivity!.copyWith(
      isActive: false,
      endTime: DateTime.now(),
    );
    
    // Only add to stream if controller is not closed
    if (!_stateController.isClosed) {
      _stateController.add(_currentActivity!);
    }
    
    _logEvent(LiveActivityEvent(
      type: LiveActivityEventType.ended,
      timestamp: DateTime.now(),
      activityId: activityId,
      metadata: finalMessage != null ? {'message': finalMessage} : null,
    ));
    
    // Clear after delay
    await Future.delayed(const Duration(milliseconds: 500));
    _currentActivity = null;
    
    return LiveActivityResult(
      success: true,
      message: finalMessage,
    );
  }
  
  // Pause/Resume
  Future<LiveActivityResult> pauseActivity() async {
    if (_currentActivity == null || !_currentActivity!.isActive) {
      return LiveActivityResult(
        success: false,
        error: 'No active Live Activity to pause',
      );
    }
    
    if (_currentActivity!.isPaused) {
      return LiveActivityResult(
        success: false,
        error: 'Activity is already paused',
      );
    }
    
    await updateActivity(isPaused: true);
    
    _logEvent(LiveActivityEvent(
      type: LiveActivityEventType.paused,
      timestamp: DateTime.now(),
      activityId: _currentActivity!.id,
    ));
    
    return LiveActivityResult(success: true);
  }
  
  Future<LiveActivityResult> resumeActivity() async {
    if (_currentActivity == null || !_currentActivity!.isActive) {
      return LiveActivityResult(
        success: false,
        error: 'No active Live Activity to resume',
      );
    }
    
    if (!_currentActivity!.isPaused) {
      return LiveActivityResult(
        success: false,
        error: 'Activity is not paused',
      );
    }
    
    await updateActivity(isPaused: false);
    
    _logEvent(LiveActivityEvent(
      type: LiveActivityEventType.resumed,
      timestamp: DateTime.now(),
      activityId: _currentActivity!.id,
    ));
    
    return LiveActivityResult(success: true);
  }
  
  // Dynamic Island interactions
  Future<void> expandDynamicIsland() async {
    if (_currentActivity == null || !_currentActivity!.isActive) return;
    
    _logEvent(LiveActivityEvent(
      type: LiveActivityEventType.dynamicIslandExpanded,
      timestamp: DateTime.now(),
      activityId: _currentActivity!.id,
    ));
  }
  
  Future<void> collapseDynamicIsland() async {
    if (_currentActivity == null || !_currentActivity!.isActive) return;
    
    _logEvent(LiveActivityEvent(
      type: LiveActivityEventType.dynamicIslandCollapsed,
      timestamp: DateTime.now(),
      activityId: _currentActivity!.id,
    ));
  }
  
  // Private helpers
  void _startCountdown() {
    if (_currentActivity?.type != LiveActivityType.restTimer) return;
    
    // Cancel any existing timer
    _countdownTimer?.cancel();
    
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentActivity == null || !_currentActivity!.isActive) {
        timer.cancel();
        _countdownTimer = null;
        return;
      }
      
      if (!_currentActivity!.isPaused && _currentActivity!.remainingSeconds! > 0) {
        // Check if controller is closed before updating
        if (!_stateController.isClosed) {
          updateActivity(remainingSeconds: _currentActivity!.remainingSeconds! - 1);
        }
        
        if (_currentActivity!.remainingSeconds == 0) {
          if (!_stateController.isClosed) {
            endActivity(finalMessage: 'Rest complete! Time for set ${(_currentActivity!.currentSet ?? 0) + 1}');
          }
          timer.cancel();
          _countdownTimer = null;
        }
      }
    });
  }
  
  void _logEvent(LiveActivityEvent event) {
    _eventHistory.add(event);
  }
  
  // Testing helpers
  void clearHistory() {
    _eventHistory.clear();
  }
  
  void dispose() {
    // Cancel timer before closing stream
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _stateController.close();
  }
}

// Models
class LiveActivityState {
  
  LiveActivityState({
    required this.id,
    required this.type,
    required this.startTime,
    this.endTime,
    required this.isActive,
    required this.isPaused,
    this.exerciseName,
    this.durationSeconds,
    this.remainingSeconds,
    this.currentSet,
    this.totalSets,
    this.nextExerciseName,
    this.workoutName,
    this.totalExercises,
    this.completedExercises,
    this.currentExercise,
    this.elapsedTime,
  });
  final String id;
  final LiveActivityType type;
  final DateTime startTime;
  final DateTime? endTime;
  final bool isActive;
  final bool isPaused;
  
  // Rest timer specific
  final String? exerciseName;
  final int? durationSeconds;
  final int? remainingSeconds;
  final int? currentSet;
  final int? totalSets;
  final String? nextExerciseName;
  
  // Workout specific
  final String? workoutName;
  final int? totalExercises;
  final int? completedExercises;
  final String? currentExercise;
  final Duration? elapsedTime;
  
  LiveActivityState copyWith({
    bool? isActive,
    bool? isPaused,
    DateTime? endTime,
    int? remainingSeconds,
    int? completedExercises,
    String? currentExercise,
    Duration? elapsedTime,
  }) {
    return LiveActivityState(
      id: id,
      type: type,
      startTime: startTime,
      endTime: endTime ?? this.endTime,
      isActive: isActive ?? this.isActive,
      isPaused: isPaused ?? this.isPaused,
      exerciseName: exerciseName,
      durationSeconds: durationSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      currentSet: currentSet,
      totalSets: totalSets,
      nextExerciseName: nextExerciseName,
      workoutName: workoutName,
      totalExercises: totalExercises,
      completedExercises: completedExercises ?? this.completedExercises,
      currentExercise: currentExercise ?? this.currentExercise,
      elapsedTime: elapsedTime ?? this.elapsedTime,
    );
  }
}

class LiveActivityResult {
  
  LiveActivityResult({
    required this.success,
    this.error,
    this.message,
    this.activityId,
  });
  final bool success;
  final String? error;
  final String? message;
  final String? activityId;
}

class LiveActivityEvent {
  
  LiveActivityEvent({
    required this.type,
    required this.timestamp,
    this.activityId,
    this.metadata,
  });
  final LiveActivityEventType type;
  final DateTime timestamp;
  final String? activityId;
  final Map<String, dynamic>? metadata;
}

enum LiveActivityType {
  restTimer,
  workout,
}

enum LiveActivityEventType {
  initialized,
  started,
  updated,
  paused,
  resumed,
  ended,
  dynamicIslandExpanded,
  dynamicIslandCollapsed,
}

void main() {
  group('📱 Live Activities iOS Tests', () {
    late LiveActivityManager manager;
    
    setUp(() async {
      manager = LiveActivityManager();
      await manager.initialize();
    });
    
    tearDown(() async {
      // End any active activity to ensure timer is cancelled
      if (manager.currentActivity != null) {
        await manager.endActivity();
      }
      manager.clearHistory();
      manager.dispose();
    });
    
    group('🎯 Initialization & Support', () {
      test('✅ Initialize Live Activity manager', () async {
        expect(manager.isSupported, true);
        expect(manager.eventHistory.isNotEmpty, true);
        expect(manager.eventHistory.first.type, LiveActivityEventType.initialized);
      });
      
      test('✅ Check iOS support', () {
        // In real app would check Platform.isIOS
        expect(manager.isSupported, true);
      });
    });
    
    group('⏱️ Rest Timer Live Activity', () {
      test('✅ Start rest timer activity', () async {
        final result = await manager.startRestTimerActivity(
          exerciseName: 'Bench Press',
          durationSeconds: 60,
          currentSet: 2,
          totalSets: 4,
          nextExerciseName: 'Incline Press',
        );
        
        expect(result.success, true);
        expect(result.activityId, isNotNull);
        expect(manager.currentActivity, isNotNull);
        expect(manager.currentActivity!.type, LiveActivityType.restTimer);
        expect(manager.currentActivity!.exerciseName, 'Bench Press');
        expect(manager.currentActivity!.remainingSeconds, 60);
      });
      
      test('✅ Countdown timer updates', () async {
        await manager.startRestTimerActivity(
          exerciseName: 'Squat',
          durationSeconds: 3, // Short for testing
          currentSet: 1,
          totalSets: 3,
        );
        
        expect(manager.currentActivity!.remainingSeconds, 3);
        
        // Wait for countdown
        await Future.delayed(const Duration(seconds: 2));
        
        expect(manager.currentActivity!.remainingSeconds, lessThan(3));
      });
      
      test('✅ Auto-end when timer completes', () async {
        await manager.startRestTimerActivity(
          exerciseName: 'Deadlift',
          durationSeconds: 1, // Very short for testing
          currentSet: 1,
          totalSets: 1,
        );
        
        // Wait for timer to complete plus cleanup delay
        await Future.delayed(const Duration(milliseconds: 2000));
        
        expect(manager.currentActivity, isNull); // Should be cleared after ending
        
        // Check event history
        final endEvent = manager.eventHistory.firstWhere(
          (e) => e.type == LiveActivityEventType.ended,
        );
        expect(endEvent.metadata?['message'], contains('Rest complete'));
      });
      
      test('❌ Cannot start when another is active', () async {
        await manager.startRestTimerActivity(
          exerciseName: 'Exercise 1',
          durationSeconds: 60,
          currentSet: 1,
          totalSets: 3,
        );
        
        final result = await manager.startRestTimerActivity(
          exerciseName: 'Exercise 2',
          durationSeconds: 60,
          currentSet: 1,
          totalSets: 3,
        );
        
        expect(result.success, false);
        expect(result.error, contains('already running'));
      });
    });
    
    group('🏋️ Workout Live Activity', () {
      test('✅ Start workout activity', () async {
        final result = await manager.startWorkoutActivity(
          workoutName: 'Push Day',
          totalExercises: 5,
          completedExercises: 0,
          currentExercise: 'Bench Press',
        );
        
        expect(result.success, true);
        expect(manager.currentActivity!.type, LiveActivityType.workout);
        expect(manager.currentActivity!.workoutName, 'Push Day');
        expect(manager.currentActivity!.totalExercises, 5);
      });
      
      test('✅ Update workout progress', () async {
        await manager.startWorkoutActivity(
          workoutName: 'Pull Day',
          totalExercises: 4,
          completedExercises: 0,
        );
        
        await manager.updateActivity(
          completedExercises: 1,
          currentExercise: 'Pull Ups',
          elapsedTime: const Duration(minutes: 15),
        );
        
        expect(manager.currentActivity!.completedExercises, 1);
        expect(manager.currentActivity!.currentExercise, 'Pull Ups');
        expect(manager.currentActivity!.elapsedTime, const Duration(minutes: 15));
      });
      
      test('✅ End workout with message', () async {
        await manager.startWorkoutActivity(
          workoutName: 'Leg Day',
          totalExercises: 3,
          completedExercises: 3,
        );
        
        final result = await manager.endActivity(
          finalMessage: 'Great workout! 💪',
        );
        
        expect(result.success, true);
        expect(result.message, 'Great workout! 💪');
        
        await Future.delayed(const Duration(milliseconds: 600));
        expect(manager.currentActivity, isNull);
      });
    });
    
    group('⏸️ Pause & Resume', () {
      test('✅ Pause active timer', () async {
        await manager.startRestTimerActivity(
          exerciseName: 'Bench Press',
          durationSeconds: 60,
          currentSet: 1,
          totalSets: 3,
        );
        
        final result = await manager.pauseActivity();
        
        expect(result.success, true);
        expect(manager.currentActivity!.isPaused, true);
        
        // Check event logged
        final pauseEvent = manager.eventHistory.lastWhere(
          (e) => e.type == LiveActivityEventType.paused,
        );
        expect(pauseEvent, isNotNull);
      });
      
      test('✅ Resume paused timer', () async {
        await manager.startRestTimerActivity(
          exerciseName: 'Squat',
          durationSeconds: 60,
          currentSet: 1,
          totalSets: 3,
        );
        
        await manager.pauseActivity();
        expect(manager.currentActivity!.isPaused, true);
        
        final result = await manager.resumeActivity();
        
        expect(result.success, true);
        expect(manager.currentActivity!.isPaused, false);
      });
      
      test('❌ Cannot pause already paused', () async {
        await manager.startRestTimerActivity(
          exerciseName: 'Deadlift',
          durationSeconds: 60,
          currentSet: 1,
          totalSets: 1,
        );
        
        await manager.pauseActivity();
        
        final result = await manager.pauseActivity();
        
        expect(result.success, false);
        expect(result.error, contains('already paused'));
      });
      
      test('❌ Cannot resume not paused', () async {
        await manager.startRestTimerActivity(
          exerciseName: 'Row',
          durationSeconds: 60,
          currentSet: 1,
          totalSets: 1,
        );
        
        final result = await manager.resumeActivity();
        
        expect(result.success, false);
        expect(result.error, contains('not paused'));
      });
    });
    
    group('🏝️ Dynamic Island', () {
      test('✅ Expand Dynamic Island', () async {
        await manager.startRestTimerActivity(
          exerciseName: 'Bench Press',
          durationSeconds: 60,
          currentSet: 1,
          totalSets: 3,
        );
        
        await manager.expandDynamicIsland();
        
        final expandEvent = manager.eventHistory.lastWhere(
          (e) => e.type == LiveActivityEventType.dynamicIslandExpanded,
        );
        expect(expandEvent, isNotNull);
      });
      
      test('✅ Collapse Dynamic Island', () async {
        await manager.startRestTimerActivity(
          exerciseName: 'Squat',
          durationSeconds: 60,
          currentSet: 1,
          totalSets: 3,
        );
        
        await manager.collapseDynamicIsland();
        
        final collapseEvent = manager.eventHistory.lastWhere(
          (e) => e.type == LiveActivityEventType.dynamicIslandCollapsed,
        );
        expect(collapseEvent, isNotNull);
      });
      
      test('✅ No-op when no active activity', () async {
        await manager.expandDynamicIsland(); // Should not crash
        await manager.collapseDynamicIsland(); // Should not crash
        
        // Should not add events
        expect(manager.eventHistory.where(
          (e) => e.type == LiveActivityEventType.dynamicIslandExpanded
        ).isEmpty, true);
      });
    });
    
    group('📡 State Stream', () {
      test('✅ Stream state updates', () async {
        final states = <LiveActivityState>[];
        
        final subscription = manager.stateStream.listen((state) {
          states.add(state);
        });
        
        await manager.startRestTimerActivity(
          exerciseName: 'Bench Press',
          durationSeconds: 60,
          currentSet: 1,
          totalSets: 3,
        );
        
        await manager.updateActivity(remainingSeconds: 45);
        await manager.pauseActivity();
        await manager.resumeActivity();
        await manager.endActivity();
        
        await Future.delayed(const Duration(milliseconds: 100));
        
        expect(states.length, greaterThanOrEqualTo(5));
        expect(states.first.isActive, true);
        expect(states.last.isActive, false);
        
        await subscription.cancel();
      });
    });
    
    group('❌ Error Handling', () {
      test('Cannot update non-existent activity', () async {
        final result = await manager.updateActivity(remainingSeconds: 30);
        
        expect(result.success, false);
        expect(result.error, contains('No active'));
      });
      
      test('Cannot end non-existent activity', () async {
        final result = await manager.endActivity();
        
        expect(result.success, false);
        expect(result.error, contains('No active'));
      });
      
      test('Cannot pause non-existent activity', () async {
        final result = await manager.pauseActivity();
        
        expect(result.success, false);
        expect(result.error, contains('No active'));
      });
    });
  });
}