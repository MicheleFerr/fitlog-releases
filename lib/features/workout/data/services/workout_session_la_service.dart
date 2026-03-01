import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/shared/data/platform_channels.dart';

/// Represents the current mode of the Workout Session Live Activity
enum WorkoutSessionMode { exercise, rest, rpe }

/// Represents the current state of a workout session
class WorkoutSessionState {

  const WorkoutSessionState({
    required this.mode,
    required this.exerciseName,
    required this.currentSet,
    required this.totalSets,
    required this.weight,
    required this.targetReps,
    required this.completedExercises,
    required this.totalExercises,
    required this.workoutStartDate,
    this.restRemainingSeconds = 0,
    this.selectedRPE,
    this.rpeEnabled = false,
  });

  factory WorkoutSessionState.fromMap(Map<dynamic, dynamic> map) {
    return WorkoutSessionState(
      mode: WorkoutSessionMode.values.firstWhere(
        (m) => m.name == map['mode'],
        orElse: () => WorkoutSessionMode.exercise,
      ),
      exerciseName: map['exerciseName'] as String? ?? '',
      currentSet: map['currentSet'] as int? ?? 1,
      totalSets: map['totalSets'] as int? ?? 1,
      weight: (map['weight'] as num?)?.toDouble() ?? 0.0,
      targetReps: map['targetReps'] as int? ?? 0,
      completedExercises: map['completedExercises'] as int? ?? 0,
      totalExercises: map['totalExercises'] as int? ?? 0,
      workoutStartDate: DateTime.fromMillisecondsSinceEpoch(
        (map['workoutStartDate'] as num?)?.toInt() ?? 0,
      ),
      restRemainingSeconds: map['restRemainingSeconds'] as int? ?? 0,
      selectedRPE: map['selectedRPE'] as int?,
      rpeEnabled: map['rpeEnabled'] as bool? ?? false,
    );
  }
  final WorkoutSessionMode mode;
  final String exerciseName;
  final int currentSet;
  final int totalSets;
  final double weight;
  final int targetReps;
  final int completedExercises;
  final int totalExercises;
  final DateTime workoutStartDate;
  final int restRemainingSeconds;
  final int? selectedRPE;
  final bool rpeEnabled;
}

/// Event data from Live Activity interactions
class WorkoutSessionEvent {

  const WorkoutSessionEvent({
    required this.eventType,
    required this.activityId,
    required this.timestamp,
    required this.data,
  });

  factory WorkoutSessionEvent.fromMap(Map<dynamic, dynamic> map) {
    return WorkoutSessionEvent(
      eventType: map['eventType'] as String? ?? '',
      activityId: map['activityId'] as String? ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (map['timestamp'] as num?)?.toInt() ?? 0,
      ),
      data: Map<String, dynamic>.from(map),
    );
  }
  final String eventType;
  final String activityId;
  final DateTime timestamp;
  final Map<String, dynamic> data;

  // Event type helpers
  bool get isCompleteSet => eventType == 'complete_set';
  bool get isSkipRest => eventType == 'skip_rest';
  bool get isAddTime => eventType == 'add_time';
  bool get isSelectRPE => eventType == 'select_rpe';
  bool get isConfirmRPE => eventType == 'confirm_rpe';
  bool get isPauseResume => eventType == 'pause_resume';

  // Convenience getters
  int? get selectedRPE => data['selectedRPE'] as int?;
  int? get confirmedRPE => data['confirmedRPE'] as int?;
  int? get addedSeconds => data['addedSeconds'] as int?;
  int? get completedSet => data['completedSet'] as int?;
  bool get audioSkipped => data['audioSkipped'] as bool? ?? false;
}

/// Service to manage the unified Workout Session Live Activity on iOS 17+
///
/// This service communicates with the native iOS WorkoutSessionManager
/// to control a single persistent Live Activity throughout the workout.
class WorkoutSessionLAService {
  factory WorkoutSessionLAService() => _instance;
  WorkoutSessionLAService._internal();
  static final WorkoutSessionLAService _instance =
      WorkoutSessionLAService._internal();

  static const _channel = MethodChannel(PlatformChannels.workoutSession);

  // Singleton service — dispose not needed, lives for app lifetime.
  // _eventController.close() would break listeners if called prematurely.
  final _eventController = StreamController<WorkoutSessionEvent>.broadcast();

  /// Stream of events from Live Activity interactions (button taps)
  Stream<WorkoutSessionEvent> get events => _eventController.stream;

  String? _currentActivityId;
  bool _isInitialized = false;

  /// Whether iOS 17+ is available (required for interactive Live Activities)
  bool get isSupported => Platform.isIOS;

  /// Current activity ID (if active)
  String? get currentActivityId => _currentActivityId;

  /// Whether a workout session is currently active
  bool get isActive => _currentActivityId != null;

  /// Initialize the service and set up event listeners
  Future<void> initialize() async {
    if (_isInitialized) return;
    if (!Platform.isIOS) return;

    _channel.setMethodCallHandler(_handleMethodCall);
    _isInitialized = true;

    if (kDebugMode) {
      debugPrint('[WorkoutSessionLA] Service initialized');
    }
  }

  /// Handle method calls from iOS (events from button taps)
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onWorkoutSessionEvent':
        final eventMap = call.arguments as Map<dynamic, dynamic>;
        if (kDebugMode) {
          debugPrint(
            '[WorkoutSessionLA] 📥 onWorkoutSessionEvent received from iOS!',
          );
          debugPrint('[WorkoutSessionLA] 📥 Raw event data: $eventMap');
        }
        final event = WorkoutSessionEvent.fromMap(eventMap);
        if (kDebugMode) {
          debugPrint(
            '[WorkoutSessionLA] 📥 Parsed event type: ${event.eventType}',
          );
        }
        _eventController.add(event);
        if (kDebugMode) {
          debugPrint('[WorkoutSessionLA] 📥 Event added to stream controller');
        }
        break;
      default:
        if (kDebugMode) {
          debugPrint(
            '[WorkoutSessionLA] ⚠️ Unknown method call: ${call.method}',
          );
        }
    }
  }

  /// Start a new workout session Live Activity
  ///
  /// Returns the activity ID if successful, null otherwise
  Future<String?> startSession({
    required String workoutId,
    required String workoutName,
    required String exerciseName,
    required int currentSet,
    required int totalSets,
    required double weight,
    required int targetReps,
    required int completedExercises,
    required int totalExercises,
    bool rpeEnabled = false,
  }) async {
    if (!Platform.isIOS) return null;

    try {
      final activityId = await _channel
          .invokeMethod<String>('startWorkoutSession', {
            'workoutId': workoutId,
            'workoutName': workoutName,
            'exerciseName': exerciseName,
            'currentSet': currentSet,
            'totalSets': totalSets,
            'weight': weight,
            'targetReps': targetReps,
            'completedExercises': completedExercises,
            'totalExercises': totalExercises,
            'rpeEnabled': rpeEnabled,
          });

      _currentActivityId = activityId;
      if (kDebugMode) {
        debugPrint('[WorkoutSessionLA] Session started: $activityId');
      }
      return activityId;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint('[WorkoutSessionLA] Failed to start session: ${e.message}');
      }
      return null;
    }
  }

  /// Update the workout session with new exercise info
  Future<bool> updateSession({
    String? exerciseName,
    int? currentSet,
    int? totalSets,
    double? weight,
    int? targetReps,
    int? completedExercises,
    int? totalExercises,
  }) async {
    if (!Platform.isIOS || _currentActivityId == null) return false;

    try {
      final result = await _channel.invokeMethod<bool>('updateWorkoutSession', {
        if (exerciseName != null) 'exerciseName': exerciseName,
        if (currentSet != null) 'currentSet': currentSet,
        if (totalSets != null) 'totalSets': totalSets,
        if (weight != null) 'weight': weight,
        if (targetReps != null) 'targetReps': targetReps,
        if (completedExercises != null)
          'completedExercises': completedExercises,
        if (totalExercises != null) 'totalExercises': totalExercises,
      });

      if (kDebugMode) {
        debugPrint('[WorkoutSessionLA] Session updated');
      }
      return result ?? false;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[WorkoutSessionLA] Failed to update session: ${e.message}',
        );
      }
      return false;
    }
  }

  /// Transition to REST mode with timer
  ///
  /// [restDuration] is in seconds
  Future<bool> transitionToRest({
    required int restDuration,
    String? nextExerciseName,
    int? nextSet,
    int? totalSets,
    double? weight,
    int? targetReps,
  }) async {
    if (!Platform.isIOS || _currentActivityId == null) return false;

    try {
      final result = await _channel.invokeMethod<bool>('transitionToRest', {
        'restDuration': restDuration,
        if (nextExerciseName != null) 'nextExerciseName': nextExerciseName,
        if (nextSet != null) 'nextSet': nextSet,
        if (totalSets != null) 'totalSets': totalSets,
        if (weight != null) 'weight': weight,
        if (targetReps != null) 'targetReps': targetReps,
      });

      if (kDebugMode) {
        debugPrint(
          '[WorkoutSessionLA] Transitioned to REST ($restDuration seconds)',
        );
      }
      return result ?? false;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[WorkoutSessionLA] Failed to transition to rest: ${e.message}',
        );
      }
      return false;
    }
  }

  /// Transition to EXERCISE mode (ready for next set)
  Future<bool> transitionToExercise({
    required String exerciseName,
    required int currentSet,
    required int totalSets,
    required double weight,
    required int targetReps,
    int? completedExercises,
  }) async {
    if (!Platform.isIOS || _currentActivityId == null) return false;

    try {
      final result = await _channel.invokeMethod<bool>('transitionToExercise', {
        'exerciseName': exerciseName,
        'currentSet': currentSet,
        'totalSets': totalSets,
        'weight': weight,
        'targetReps': targetReps,
        if (completedExercises != null)
          'completedExercises': completedExercises,
      });

      if (kDebugMode) {
        debugPrint('[WorkoutSessionLA] Transitioned to EXERCISE');
      }
      return result ?? false;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[WorkoutSessionLA] Failed to transition to exercise: ${e.message}',
        );
      }
      return false;
    }
  }

  /// Transition to RPE selection mode
  Future<bool> transitionToRPE() async {
    if (!Platform.isIOS || _currentActivityId == null) return false;

    try {
      final result = await _channel.invokeMethod<bool>('transitionToRPE');
      if (kDebugMode) {
        debugPrint('[WorkoutSessionLA] Transitioned to RPE');
      }
      return result ?? false;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[WorkoutSessionLA] Failed to transition to RPE: ${e.message}',
        );
      }
      return false;
    }
  }

  /// Sync the rest timer to an absolute end time.
  ///
  /// Used after +30s from Live Activity to guarantee LA and Flutter state match,
  /// regardless of whether the AppIntent update already applied.
  /// Using absolute time avoids double-add issues.
  Future<bool> syncRestEndTime(DateTime absoluteEndTime) async {
    if (!Platform.isIOS || _currentActivityId == null) return false;

    try {
      final result = await _channel.invokeMethod<bool>('syncRestEndTime', {
        'endTimeMs': absoluteEndTime.millisecondsSinceEpoch.toDouble(),
      });
      if (kDebugMode) {
        debugPrint(
          '[WorkoutSessionLA] 🔄 Synced absolute end time: $absoluteEndTime',
        );
      }
      return result ?? false;
    } catch (e) {
      // Catch ALL exceptions (PlatformException, MissingPluginException, etc.)
      // to prevent this from breaking the caller's flow
      if (kDebugMode) {
        debugPrint(
          '[WorkoutSessionLA] ⚠️ Failed to sync rest end time: $e',
        );
      }
      return false;
    }
  }

  /// Extend the rest timer by adding additional seconds
  ///
  /// [additionalSeconds] - Number of seconds to add to current rest timer
  Future<bool> extendRestTimer(int additionalSeconds) async {
    if (!Platform.isIOS || _currentActivityId == null) return false;

    try {
      final result = await _channel.invokeMethod<bool>('extendRestTimer', {
        'additionalSeconds': additionalSeconds,
      });
      if (kDebugMode) {
        debugPrint(
          '[WorkoutSessionLA] Extended rest timer by $additionalSeconds seconds',
        );
      }
      return result ?? false;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[WorkoutSessionLA] Failed to extend rest timer: ${e.message}',
        );
      }
      return false;
    }
  }

  /// Pause the rest timer on the Live Activity
  ///
  /// [remainingSeconds] - The remaining time when pausing
  Future<bool> pauseRestTimer(int remainingSeconds) async {
    if (!Platform.isIOS || _currentActivityId == null) return false;

    try {
      if (kDebugMode) {
        debugPrint(
          '[WorkoutSessionLA] ⏸️ Pausing rest timer with $remainingSeconds seconds remaining',
        );
      }
      final result = await _channel.invokeMethod<bool>('pauseRestTimer', {
        'remainingSeconds': remainingSeconds,
      });
      if (kDebugMode) {
        debugPrint('[WorkoutSessionLA] ⏸️ Pause result: $result');
      }
      return result ?? false;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[WorkoutSessionLA] ❌ Failed to pause rest timer: ${e.message}',
        );
      }
      return false;
    }
  }

  /// Resume the rest timer on the Live Activity
  ///
  /// [remainingSeconds] - The remaining time when resuming
  Future<bool> resumeRestTimer(int remainingSeconds) async {
    if (!Platform.isIOS || _currentActivityId == null) return false;

    try {
      if (kDebugMode) {
        debugPrint(
          '[WorkoutSessionLA] ▶️ Resuming rest timer with $remainingSeconds seconds remaining',
        );
      }
      final result = await _channel.invokeMethod<bool>('resumeRestTimer', {
        'remainingSeconds': remainingSeconds,
      });
      if (kDebugMode) {
        debugPrint('[WorkoutSessionLA] ▶️ Resume result: $result');
      }
      return result ?? false;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[WorkoutSessionLA] ❌ Failed to resume rest timer: ${e.message}',
        );
      }
      return false;
    }
  }

  /// Store the current exercise's rest duration in shared UserDefaults
  ///
  /// This allows AppIntents to read the correct rest duration when the user
  /// taps "Fatto" on the Live Activity from the lock screen.
  /// [durationSeconds] - The rest duration in seconds
  Future<bool> setCurrentRestDuration(int durationSeconds) async {
    if (!Platform.isIOS) return false;

    try {
      final result = await _channel.invokeMethod<bool>(
        'setCurrentRestDuration',
        {'duration': durationSeconds},
      );
      if (kDebugMode) {
        debugPrint(
          '[WorkoutSessionLA] Set current rest duration: ${durationSeconds}s',
        );
      }
      return result ?? false;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[WorkoutSessionLA] Failed to set rest duration: ${e.message}',
        );
      }
      return false;
    }
  }

  /// Store info about the next exercise/set in shared UserDefaults
  ///
  /// This allows AppIntents to read the correct next exercise info when
  /// transitioning to REST mode, so the LA shows the right exercise name
  /// even before Flutter can update it.
  Future<bool> setNextExerciseInfo({
    required String exerciseName,
    required int currentSet,
    required int totalSets,
    required double weight,
    required int targetReps,
    required int restDuration,
    required bool isLastSetOfExercise,
  }) async {
    if (!Platform.isIOS) return false;

    try {
      final result = await _channel.invokeMethod<bool>(
        'setNextExerciseInfo',
        {
          'exerciseName': exerciseName,
          'currentSet': currentSet,
          'totalSets': totalSets,
          'weight': weight,
          'targetReps': targetReps,
          'restDuration': restDuration,
          'isLastSetOfExercise': isLastSetOfExercise,
        },
      );
      if (kDebugMode) {
        debugPrint(
          '[WorkoutSessionLA] Set next exercise info: $exerciseName set $currentSet/$totalSets',
        );
      }
      return result ?? false;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[WorkoutSessionLA] Failed to set next exercise info: ${e.message}',
        );
      }
      return false;
    }
  }

  /// Store the RPE tracking setting in shared UserDefaults
  ///
  /// This allows AppIntents to know whether to show RPE mode or go directly
  /// to REST mode when user taps "Fatto" on the Live Activity.
  Future<bool> setRpeTrackingEnabled(bool enabled) async {
    if (!Platform.isIOS) return false;

    try {
      final result = await _channel.invokeMethod<bool>(
        'setRpeTrackingEnabled',
        {'enabled': enabled},
      );
      if (kDebugMode) {
        debugPrint('[WorkoutSessionLA] Set RPE tracking enabled: $enabled');
      }
      return result ?? false;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[WorkoutSessionLA] Failed to set RPE setting: ${e.message}',
        );
      }
      return false;
    }
  }

  /// Update the selected RPE value in the Live Activity UI
  Future<bool> updateSelectedRPE(int rpe) async {
    if (!Platform.isIOS || _currentActivityId == null) return false;

    try {
      final result = await _channel.invokeMethod<bool>('updateSelectedRPE', {
        'rpe': rpe,
      });
      if (kDebugMode) {
        debugPrint('[WorkoutSessionLA] Selected RPE updated to $rpe');
      }
      return result ?? false;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint('[WorkoutSessionLA] Failed to update RPE: ${e.message}');
      }
      return false;
    }
  }

  /// End the workout session Live Activity
  ///
  /// [dismissPolicy] can be 'immediate', 'after_5s', or 'after_30s'
  Future<bool> endSession({String dismissPolicy = 'immediate'}) async {
    if (!Platform.isIOS) return true;

    try {
      final result = await _channel.invokeMethod<bool>('endWorkoutSession', {
        'dismissPolicy': dismissPolicy,
      });

      _currentActivityId = null;
      if (kDebugMode) {
        debugPrint('[WorkoutSessionLA] Session ended');
      }
      return result ?? true;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint('[WorkoutSessionLA] Failed to end session: ${e.message}');
      }
      _currentActivityId = null;
      return false;
    }
  }

  /// Check if a workout session is currently active
  Future<bool> isSessionActive() async {
    if (!Platform.isIOS) return false;

    try {
      final result = await _channel.invokeMethod<bool>(
        'isWorkoutSessionActive',
      );
      return result ?? false;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[WorkoutSessionLA] Failed to check session status: ${e.message}',
        );
      }
      return false;
    }
  }

  /// Get the current session state
  Future<WorkoutSessionState?> getSessionState() async {
    if (!Platform.isIOS) return null;

    try {
      final result = await _channel.invokeMethod<Map>('getWorkoutSessionState');
      if (result != null) {
        return WorkoutSessionState.fromMap(result);
      }
      return null;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[WorkoutSessionLA] Failed to get session state: ${e.message}',
        );
      }
      return null;
    }
  }

  /// Check for pending Live Activity events that weren't processed
  ///
  /// This should be called when the app resumes from background to catch
  /// any events (like +30s button taps) that were sent while the app was suspended.
  ///
  /// FIX: When app is suspended, Darwin notifications may not wake the callback.
  /// This method explicitly checks UserDefaults for missed events.
  Future<Map<String, dynamic>?> checkPendingEvents() async {
    if (!Platform.isIOS) return null;

    try {
      final result = await _channel.invokeMethod<Map>('checkPendingEvents');
      if (result != null) {
        if (kDebugMode) {
          debugPrint(
            '[WorkoutSessionLA] 📬 Found pending event: ${result['eventType']}',
          );
        }
        return Map<String, dynamic>.from(result);
      }
      if (kDebugMode) {
        debugPrint('[WorkoutSessionLA] 📭 No pending events');
      }
      return null;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[WorkoutSessionLA] Failed to check pending events: ${e.message}',
        );
      }
      return null;
    }
  }

  /// 🔐 SECURITY: Reset session state on logout to prevent data leakage
  Future<void> resetOnLogout() async {
    // End any active Live Activity session
    if (_currentActivityId != null) {
      try {
        await endSession(dismissPolicy: 'immediate');
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[WorkoutSessionLA] Error ending session on logout: $e');
        }
      }
    }
    _currentActivityId = null;
    if (kDebugMode) {
      debugPrint('[WorkoutSessionLA] 🔐 Reset on logout');
    }
  }

  /// Dispose of resources
  void dispose() {
    _eventController.close();
  }
}
