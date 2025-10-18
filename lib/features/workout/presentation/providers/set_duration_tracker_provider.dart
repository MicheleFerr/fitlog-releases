/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: presentation
/// 🎯 Feature: workout
/// 🔧 Type: provider
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
/// 
/// Dependencies:
/// - Riverpod: StateNotifierProvider
/// - Firebase: None
/// - Hive: None
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

/// Tracks the duration of each set from start to completion
/// Tracks ONLY execution time, not rest time
class SetDurationTracker {
  // Track when each set STARTS (after rest timer or manual start)
  final Map<String, DateTime> _setStartTimes = {};
  
  // Track when rest timer ends for next set
  DateTime? _restTimerEndTime;

  /// Called when starting a set (either from rest timer end or manual start)
  DateTime startSet(String exerciseId, int setNumber) {
    final key = '${exerciseId}_$setNumber';

    // Use rest timer end time if available (no time limit)
    DateTime startTime;
    if (_restTimerEndTime != null) {
      startTime = _restTimerEndTime!;
      if (kDebugMode) {
        debugPrint('🎯 Set $setNumber starting from rest timer end: ${startTime.toIso8601String()}');
      }
      _restTimerEndTime = null; // Clear after use
    } else {
      startTime = DateTime.now();
      if (kDebugMode) {
        debugPrint('🎯 Set $setNumber starting now: ${startTime.toIso8601String()}');
      }
    }

    _setStartTimes[key] = startTime;
    return startTime;
  }
  
  /// Called when a set is completed - returns the duration
  /// Duration = time from set START to set COMPLETION (execution time only)
  double? onSetCompleted(String exerciseId, int setNumber) {
    final key = '${exerciseId}_$setNumber';
    final startTime = _setStartTimes[key];
    
    if (startTime != null) {
      // Calculate duration from start to now
      final duration = DateTime.now().difference(startTime).inMilliseconds.toDouble();
      
      // Clean up the start time
      _setStartTimes.remove(key);
      
      return duration;
    }
    
    // If no start time, try to use a default start (now - 10 seconds)
    // This handles cases where tracking wasn't started properly
    return null;
  }
  
  /// Mark when an exercise starts (for first set duration tracking)
  void markExerciseStarted(String exerciseId) {
    // Start tracking for set 1
    final timestamp = startSet(exerciseId, 1);
    if (kDebugMode) {
      debugPrint('✅ Exercise $exerciseId started, set 1 timestamp: ${timestamp.toIso8601String()}');
    }
  }
  
  /// Clear timestamps for an exercise when moving to next exercise
  void clearExercise(String exerciseId) {
    // Remove all start times for this exercise
    _setStartTimes.removeWhere((key, value) => key.startsWith('${exerciseId}_'));
  }
  
  /// Clear all tracking data (call when workout ends)
  void clear() {
    _setStartTimes.clear();
    _restTimerEndTime = null;
  }
  
  
  // Legacy method for compatibility
  DateTime? getSetStartTime(String exerciseId, int setNumber) {
    final key = '${exerciseId}_$setNumber';
    return _setStartTimes[key];
  }
  
  // Method to manually set a start time (for calculating durations when not tracked)
  void setStartTime(String exerciseId, int setNumber, DateTime startTime) {
    final key = '${exerciseId}_$setNumber';
    _setStartTimes[key] = startTime;
    if (kDebugMode) {
      debugPrint('⏰ Manually set start time for set $setNumber: ${startTime.toIso8601String()}');
    }
  }
  
  /// Get formatted duration string (e.g., "12.34s")
  static String formatDuration(double? milliseconds) {
    if (milliseconds == null) return '';
    final seconds = milliseconds / 1000;
    // Show with 2 decimal places for precision
    return '${seconds.toStringAsFixed(2)}s';
  }
  
  /// Get formatted duration for edit field (e.g., "12,34")
  static String formatDurationForEdit(double? milliseconds) {
    if (milliseconds == null) return '';
    final totalMillis = milliseconds.round();
    final seconds = totalMillis ~/ 1000;
    final centis = (totalMillis % 1000) ~/ 10; // Get centiseconds
    return '$seconds,${centis.toString().padLeft(2, '0')}';
  }
}

/// Global provider for set duration tracking
final setDurationTrackerProvider = Provider<SetDurationTracker>((ref) {
  return SetDurationTracker();
});

/// State notifier for managing set durations during workout
class SetDurationNotifier extends StateNotifier<Map<String, double>> {
  
  SetDurationNotifier(this.ref) : super({});
  final Ref ref;
  
  /// Record a set duration
  void recordSetDuration(String exerciseId, int setNumber, double durationMillis) {
    final key = '${exerciseId}_$setNumber';
    state = {...state, key: durationMillis};
  }
  
  /// Get duration for a specific set
  double? getSetDuration(String exerciseId, int setNumber) {
    final key = '${exerciseId}_$setNumber';
    return state[key];
  }
  
  /// Clear all durations (when workout ends)
  void clear() {
    state = {};
  }
}

/// Provider for managing set durations state
final setDurationProvider = StateNotifierProvider<SetDurationNotifier, Map<String, double>>((ref) {
  return SetDurationNotifier(ref);
});