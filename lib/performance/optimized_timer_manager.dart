import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/utils/production_logger.dart';

/// CPU Optimized Timer Manager - Prevents excessive timer creation and ensures proper disposal
class OptimizedTimerManager {
  static final OptimizedTimerManager _instance = OptimizedTimerManager._internal();
  factory OptimizedTimerManager() => _instance;
  OptimizedTimerManager._internal();

  final Map<String, Timer> _activeTimers = {};
  final Map<String, DateTime> _timerStartTimes = {};
  
  /// Create a managed timer that will be automatically tracked and disposed
  Timer createTimer({
    required String id,
    required Duration duration,
    required VoidCallback callback,
    bool repeating = false,
  }) {
    // Cancel existing timer with same ID
    cancelTimer(id);
    
    final timer = repeating
        ? Timer.periodic(duration, (_) => callback())
        : Timer(duration, callback);
    
    _activeTimers[id] = timer;
    _timerStartTimes[id] = DateTime.now();
    
    ProductionLogger.performance('Created ${repeating ? 'periodic' : 'one-shot'} timer: $id', category: 'TimerManager');
    return timer;
  }
  
  /// Cancel a specific timer
  void cancelTimer(String id) {
    final timer = _activeTimers.remove(id);
    if (timer != null) {
      timer.cancel();
      _timerStartTimes.remove(id);
      ProductionLogger.performance('Cancelled timer: $id', category: 'TimerManager');
    }
  }
  
  /// Cancel all active timers
  void cancelAllTimers() {
    final timerIds = List<String>.from(_activeTimers.keys);
    for (final id in timerIds) {
      cancelTimer(id);
    }
    ProductionLogger.performance('Cancelled all ${timerIds.length} active timers', category: 'TimerManager');
  }
  
  /// Get list of active timer IDs
  List<String> getActiveTimerIds() {
    return _activeTimers.keys.toList();
  }
  
  /// Get timer statistics
  TimerStats getStats() {
    final activeCount = _activeTimers.length;
    final longestRunning = _getLongestRunningTimer();
    
    return TimerStats(
      activeTimerCount: activeCount,
      longestRunningTimerId: longestRunning?.$1,
      longestRunningDuration: longestRunning?.$2,
    );
  }
  
  (String, Duration)? _getLongestRunningTimer() {
    if (_timerStartTimes.isEmpty) return null;
    
    String? longestId;
    Duration longest = Duration.zero;
    
    for (final entry in _timerStartTimes.entries) {
      final duration = DateTime.now().difference(entry.value);
      if (duration > longest) {
        longest = duration;
        longestId = entry.key;
      }
    }
    
    return longestId != null ? (longestId, longest) : null;
  }
  
  /// Clean up expired timers
  void cleanup() {
    final expiredIds = <String>[];
    
    for (final entry in _activeTimers.entries) {
      if (!entry.value.isActive) {
        expiredIds.add(entry.key);
      }
    }
    
    for (final id in expiredIds) {
      _activeTimers.remove(id);
      _timerStartTimes.remove(id);
    }
    
    if (expiredIds.isNotEmpty) {
      ProductionLogger.performance('Cleaned up ${expiredIds.length} expired timers', category: 'TimerManager');
    }
  }
}

class TimerStats {
  final int activeTimerCount;
  final String? longestRunningTimerId;
  final Duration? longestRunningDuration;
  
  TimerStats({
    required this.activeTimerCount,
    this.longestRunningTimerId,
    this.longestRunningDuration,
  });
  
  @override
  String toString() {
    return 'TimerStats(active: $activeTimerCount, longest: ${longestRunningTimerId ?? 'none'})';
  }
}