import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/rest_timer.dart';
import '../../../workout/domain/entities/exercise.dart';

/// Provider for managing iOS Live Activities
final liveActivityProvider = Provider<LiveActivityService>((ref) {
  return LiveActivityService();
});

class LiveActivityService {
  static const _channel = MethodChannel('com.gymbro.timer/live_activity');
  
  // ✅ React Native Method: Production iOS optimizations
  final Map<String, DateTime> _lastUpdateTimes = {};
  final Map<String, LiveActivityRecoveryData> _recoveryData = {};

  /// Start a Live Activity for the current timer
  Future<String?> startLiveActivity({
    required String exerciseName,
    required String timerType,
    required int totalSeconds,
    required int currentSet,
    required int totalSets,
    String? workoutName,
  }) async {
    try {
      final result = await _channel.invokeMethod<String>('startLiveActivity', {
        'exerciseName': exerciseName,
        'timerType': timerType,
        'workoutName': workoutName,
        'totalSeconds': totalSeconds,
        'remainingSeconds': totalSeconds,
        'isRunning': true,
        'currentSet': currentSet,
        'totalSets': totalSets,
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
      });
      
      // ✅ Store recovery data for auto-recovery
      if (result != null) {
        _recoveryData[result] = LiveActivityRecoveryData(
          exerciseName: exerciseName,
          timerType: timerType,
          workoutName: workoutName,
          totalSeconds: totalSeconds,
          currentSet: currentSet,
          totalSets: totalSets,
        );
        print('✅ Live Activity started with recovery data');
      }
      
      return result;
    } catch (e) {
      print('Error starting Live Activity: $e');
      return null;
    }
  }

  /// Update an existing Live Activity with iOS production optimizations
  Future<bool> updateLiveActivity({
    required String activityId,
    required RestTimer timer,
    required int currentSet,
    required int totalSets,
    int? targetReps,
    double? weight,
    int? actualReps,
    int? selectedRPE,
  }) async {
    try {
      // ✅ Native iOS Timer: Drastically reduce update frequency
      final now = DateTime.now();
      final lastUpdate = _lastUpdateTimes[activityId];
      
      // For native iOS timer, only update on significant changes
      if (lastUpdate != null && timer.status == TimerStatus.running) {
        final secondsSinceLastUpdate = now.difference(lastUpdate).inSeconds;
        
        // OPTIMIZED: Reduced throttling for better sync (5s instead of 10s)
        // Don't throttle near completion or state changes
        final shouldThrottle = secondsSinceLastUpdate < 5 && // More frequent updates
                              timer.remainingSeconds > 15 && // Don't throttle last 15s
                              !timer.isCompleted;
        
        if (shouldThrottle) {
          print('⚠️ Live Activity update throttled (< 5s since last update) - Native iOS timer handles countdown');
          return true;
        }
      }
      
      _lastUpdateTimes[activityId] = now;
      print('🔄 Live Activity update allowed - significant change detected');
      
      await _channel.invokeMethod('updateLiveActivity', {
        'activityId': activityId,
        'remainingSeconds': timer.remainingSeconds,
        'totalSeconds': timer.totalDurationSeconds,
        'isRunning': timer.status == TimerStatus.running,
        'isAwaitingRPE': timer.isAwaitingRPE,
        'currentSet': currentSet,
        'totalSets': totalSets,
        'targetReps': targetReps,
        'weight': weight,
        'actualReps': actualReps,
        'selectedRPE': selectedRPE,
        'lastUpdated': now.millisecondsSinceEpoch,
      });
      
      print('✅ Live Activity updated successfully (throttled)');
      return true;
      
    } catch (e) {
      print('❌ Error updating Live Activity: $e');
      
      // ✅ Auto-recovery: Se fallisce, prova a ricreare
      if (e.toString().contains('Activity not found') || 
          e.toString().contains('invalid') ||
          e.toString().contains('expired')) {
        print('🔄 Live Activity lost, attempting recovery...');
        return await _attemptLiveActivityRecovery(
          activityId: activityId,
          timer: timer,
          currentSet: currentSet,
          totalSets: totalSets,
          targetReps: targetReps,
          weight: weight,
        );
      }
      
      return false;
    }
  }

  /// Update Live Activity for duration changes (add time) - bypasses throttle
  Future<bool> updateLiveActivityDuration({
    required String activityId,
    required RestTimer timer,
    required int currentSet,
    required int totalSets,
  }) async {
    try {
      print('🔄 === LIVE ACTIVITY DURATION UPDATE ===');
      print('🔄 New Total Duration: ${timer.totalDurationSeconds}s');
      print('🔄 Remaining: ${timer.remainingSeconds}s');
      print('🔄 Bypassing throttle for duration change');
      
      // Force update lastUpdateTime to reset throttle
      _lastUpdateTimes[activityId] = DateTime.now();
      
      await _channel.invokeMethod('updateLiveActivity', {
        'activityId': activityId,
        'remainingSeconds': timer.remainingSeconds,
        'totalSeconds': timer.totalDurationSeconds,
        'isRunning': timer.status == TimerStatus.running,
        'currentSet': currentSet,
        'totalSets': totalSets,
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
        'forceUpdate': true, // Signal to iOS to force update
      });
      
      print('✅ Live Activity duration updated successfully');
      return true;
      
    } catch (e) {
      print('❌ Error updating Live Activity duration: $e');
      return false;
    }
  }

  /// Force update Live Activity for critical changes - bypasses ALL throttling
  Future<bool> forceUpdateLiveActivity({
    required String activityId,
    required RestTimer timer,
    required int currentSet,
    required int totalSets,
    int? targetReps,
    double? weight,
    int? actualReps,
    int? selectedRPE,
  }) async {
    try {
      print('🔄 === FORCE LIVE ACTIVITY UPDATE ===');
      print('🔄 Timer Status: ${timer.status}');
      print('🔄 Remaining: ${timer.remainingSeconds}s');
      print('🔄 Total: ${timer.totalDurationSeconds}s');
      print('🔄 Bypassing ALL throttling for critical update');
      
      // Force update by resetting last update time
      _lastUpdateTimes[activityId] = DateTime.now();
      
      await _channel.invokeMethod('updateLiveActivity', {
        'activityId': activityId,
        'remainingSeconds': timer.remainingSeconds,
        'totalSeconds': timer.totalDurationSeconds,
        'isRunning': timer.status == TimerStatus.running,
        'isAwaitingRPE': timer.isAwaitingRPE,
        'currentSet': currentSet,
        'totalSets': totalSets,
        'targetReps': targetReps,
        'weight': weight,
        'actualReps': actualReps,
        'selectedRPE': selectedRPE,
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
        'forceUpdate': true, // Signal to iOS to force update
      });
      
      print('✅ Force Live Activity update completed successfully');
      return true;
      
    } catch (e) {
      print('❌ Error forcing Live Activity update: $e');
      return false;
    }
  }
  
  /// Update Live Activity for state changes (pause/resume) - bypasses throttle
  Future<bool> updateLiveActivityState({
    required String activityId,
    required RestTimer timer,
    required int currentSet,
    required int totalSets,
    int? targetReps,
    double? weight,
    int? actualReps,
    int? selectedRPE,
  }) async {
    try {
      print('🔄 === LIVE ACTIVITY STATE CHANGE UPDATE ===');
      print('🔄 Timer Status: ${timer.status}');
      print('🔄 Bypassing throttle for state change');
      
      // Force update lastUpdateTime to reset throttle
      _lastUpdateTimes[activityId] = DateTime.now();
      
      await _channel.invokeMethod('updateLiveActivity', {
        'activityId': activityId,
        'remainingSeconds': timer.remainingSeconds,
        'totalSeconds': timer.totalDurationSeconds,
        'isRunning': timer.status == TimerStatus.running,
        'isAwaitingRPE': timer.isAwaitingRPE,
        'currentSet': currentSet,
        'totalSets': totalSets,
        'targetReps': targetReps,
        'weight': weight,
        'actualReps': actualReps,
        'selectedRPE': selectedRPE,
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
      });
      
      print('✅ Live Activity state updated successfully (no throttle)');
      return true;
      
    } catch (e) {
      print('❌ Error updating Live Activity state: $e');
      return false;
    }
  }

  /// End a Live Activity
  Future<bool> endLiveActivity({
    required String activityId,
    String? dismissalPolicy,
  }) async {
    try {
      await _channel.invokeMethod('endLiveActivity', {
        'activityId': activityId,
        'dismissalPolicy': dismissalPolicy ?? 'immediate', // 'immediate' or 'after'  
      });
      
      // ✅ Clean up recovery data
      _recoveryData.remove(activityId);
      _lastUpdateTimes.remove(activityId);
      print('✅ Live Activity ended and recovery data cleaned');
      
      return true;
    } catch (e) {
      print('Error ending Live Activity: $e');
      return false;
    }
  }

  /// ✅ React Native Method: Live Activity Recovery System
  Future<bool> _attemptLiveActivityRecovery({
    required String activityId,
    required RestTimer timer,
    required int currentSet,
    required int totalSets,
    int? targetReps,
    double? weight,
  }) async {
    print('🔄 === LIVE ACTIVITY RECOVERY START ===');
    
    final recoveryData = _recoveryData[activityId];
    if (recoveryData == null) {
      print('❌ No recovery data found for activity: $activityId');
      return false;
    }
    
    try {
      // 1. End the broken activity (if still exists)
      try {
        await _channel.invokeMethod('endLiveActivity', {
          'activityId': activityId,
          'dismissalPolicy': 'immediate',
        });
        print('🗑️ Old activity terminated');
      } catch (e) {
        print('⚠️ Old activity already terminated: $e');
      }
      
      // 2. Create new Live Activity with current state
      final newActivityId = await startLiveActivity(
        exerciseName: recoveryData.exerciseName,
        timerType: recoveryData.timerType,
        totalSeconds: timer.totalDurationSeconds,
        currentSet: currentSet,
        totalSets: totalSets,
        workoutName: recoveryData.workoutName,
      );
      
      if (newActivityId != null) {
        // 3. Update with current timer state
        final success = await updateLiveActivity(
          activityId: newActivityId,
          timer: timer,
          currentSet: currentSet,
          totalSets: totalSets,
          targetReps: targetReps,
          weight: weight,
        );
        
        if (success) {
          print('✅ Live Activity recovered successfully: $newActivityId');
          // Update recovery data with new ID
          _recoveryData[newActivityId] = recoveryData;
          _recoveryData.remove(activityId);
          return true;
        }
      }
      
      print('❌ Live Activity recovery failed');
      return false;
      
    } catch (e) {
      print('❌ Live Activity recovery error: $e');
      return false;
    } finally {
      print('🔄 === LIVE ACTIVITY RECOVERY END ===');
    }
  }

  /// Check if Live Activities are supported and enabled
  Future<bool> isLiveActivitySupported() async {
    try {
      return await _channel.invokeMethod<bool>('isLiveActivitySupported') ?? false;
    } catch (e) {
      print('Error checking Live Activity support: $e');
      return false;
    }
  }

  /// Get list of active Live Activities
  Future<List<String>> getActiveLiveActivities() async {
    try {
      final result = await _channel.invokeMethod<List<dynamic>>('getActiveLiveActivities');
      return result?.cast<String>() ?? [];
    } catch (e) {
      print('Error getting active Live Activities: $e');
      return [];
    }
  }

  // MARK: - ✅ Interactive RPE Live Activities
  
  /// Mostra interfaccia RPE quando timer termina
  Future<String?> showRPEInterface({
    required String exerciseName,
    required int targetReps,
    required double weight,
    required int currentSet,
    required int totalSets,
    String? workoutName,
  }) async {
    try {
      final result = await _channel.invokeMethod<String>('showRPEInterface', {
        'exerciseName': exerciseName,
        'targetReps': targetReps,
        'weight': weight,
        'currentSet': currentSet,
        'totalSets': totalSets,
        'workoutName': workoutName,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      return result;
    } catch (e) {
      print('Error showing RPE interface: $e');
      return null;
    }
  }

  /// Aggiorna interfaccia RPE con dati utente
  Future<bool> updateRPEInterface({
    required String activityId,
    required bool repsCompleted,
    int? actualReps,
    int? selectedRPE,
    String? notes,
  }) async {
    try {
      await _channel.invokeMethod('updateRPEInterface', {
        'activityId': activityId,
        'repsCompleted': repsCompleted,
        'actualReps': actualReps,
        'selectedRPE': selectedRPE,
        'notes': notes,
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
      });
      return true;
    } catch (e) {
      print('Error updating RPE interface: $e');
      return false;
    }
  }

  /// Conferma RPE e completa set
  Future<bool> confirmRPEAndCompleteSet({
    required String activityId,
    required int actualReps,
    required int rpe,
    String? notes,
  }) async {
    try {
      await _channel.invokeMethod('confirmRPEAndCompleteSet', {
        'activityId': activityId,
        'actualReps': actualReps,
        'rpe': rpe,
        'notes': notes,
        'completedAt': DateTime.now().millisecondsSinceEpoch,
      });
      return true;
    } catch (e) {
      print('Error confirming RPE: $e');
      return false;
    }
  }

  /// Cancella interfaccia RPE
  Future<bool> dismissRPEInterface({
    required String activityId,
  }) async {
    try {
      await _channel.invokeMethod('dismissRPEInterface', {
        'activityId': activityId,
      });
      return true;
    } catch (e) {
      print('Error dismissing RPE interface: $e');
      return false;
    }
  }

  // MARK: - RPE Callbacks Handler
  
  /// Ascolta eventi dalla Live Activity (iOS → Flutter)
  void setupRPECallbacks({
    required Function(int actualReps, int rpe, String? notes) onRPEConfirmed,
    required Function() onRPECancelled,
    required Function(int newReps) onRepsModified,
  }) {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onRPEConfirmed':
          final actualReps = call.arguments['actualReps'] as int;
          final rpe = call.arguments['rpe'] as int;
          final notes = call.arguments['notes'] as String?;
          onRPEConfirmed(actualReps, rpe, notes);
          break;
          
        case 'onRPECancelled':
          onRPECancelled();
          break;
          
        case 'onRepsModified':
          final newReps = call.arguments['newReps'] as int;
          onRepsModified(newReps);
          break;
      }
    });
  }
}

/// ✅ Classe per gestire stato RPE Live Activity
class RPELiveActivityData {
  final String exerciseName;
  final int targetReps;
  final double weight;
  final int currentSet;
  final int totalSets;
  final String? workoutName;
  final bool repsCompleted;
  final int? actualReps;
  final int? selectedRPE;
  final String? notes;
  final DateTime timestamp;

  const RPELiveActivityData({
    required this.exerciseName,
    required this.targetReps,
    required this.weight,
    required this.currentSet,
    required this.totalSets,
    this.workoutName,
    this.repsCompleted = false,
    this.actualReps,
    this.selectedRPE,
    this.notes,
    required this.timestamp,
  });

  RPELiveActivityData copyWith({
    bool? repsCompleted,
    int? actualReps,
    int? selectedRPE,
    String? notes,
  }) {
    return RPELiveActivityData(
      exerciseName: exerciseName,
      targetReps: targetReps,
      weight: weight,
      currentSet: currentSet,
      totalSets: totalSets,
      workoutName: workoutName,
      repsCompleted: repsCompleted ?? this.repsCompleted,
      actualReps: actualReps ?? this.actualReps,
      selectedRPE: selectedRPE ?? this.selectedRPE,
      notes: notes ?? this.notes,
      timestamp: timestamp,
    );
  }

  /// Verifica se i dati sono completi per confermare
  bool get isReadyToConfirm => 
      actualReps != null && 
      selectedRPE != null && 
      selectedRPE! >= 5 && 
      selectedRPE! <= 10;

  /// Crea ExerciseSet completato con i dati RPE
  ExerciseSet toCompletedExerciseSet(String setId, int setNumber) {
    return ExerciseSet(
      id: setId,
      setNumber: setNumber,
      weight: weight,
      reps: targetReps,
      actualReps: actualReps,
      rpe: selectedRPE,
      isCompleted: true,
      notes: notes,
      completedAt: DateTime.now(),
    );
  }

  /// Restituisce testo formattato per display
  String get displayText {
    final repsText = actualReps != null 
        ? '$actualReps/$targetReps reps'
        : '$targetReps reps target';
    final rpeText = selectedRPE != null ? ' • RPE: $selectedRPE/10' : '';
    return '$exerciseName: $repsText @ ${weight}kg$rpeText';
  }
}

/// Provider per stato RPE corrente
final currentRPEStateProvider = StateProvider<RPELiveActivityData?>((ref) => null);

/// ✅ React Native Method: Live Activity Recovery Data
class LiveActivityRecoveryData {
  final String exerciseName;
  final String timerType;
  final String? workoutName;
  final int totalSeconds;
  final int currentSet;
  final int totalSets;
  final DateTime createdAt;

  LiveActivityRecoveryData({
    required this.exerciseName,
    required this.timerType,
    this.workoutName,
    required this.totalSeconds,
    required this.currentSet,
    required this.totalSets,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Check if recovery data is still valid (not too old)
  bool get isValid {
    final now = DateTime.now();
    final age = now.difference(createdAt);
    return age.inHours < 2; // Max 2 hours old
  }

  @override
  String toString() {
    return 'LiveActivityRecoveryData(exercise: $exerciseName, set: $currentSet/$totalSets, age: ${DateTime.now().difference(createdAt).inMinutes}min)';
  }
}