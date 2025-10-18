import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// CPU Performance Monitor for GymBro
/// Tracks and reports CPU usage patterns to identify performance issues
class CPUMonitor {
  factory CPUMonitor() => _instance;
  CPUMonitor._internal();
  static final CPUMonitor _instance = CPUMonitor._internal();

  final List<Timer> _activeTimers = [];
  final List<StreamSubscription> _activeSubscriptions = [];
  int _widgetRebuildCount = 0;
  DateTime? _lastRebuild;
  
  /// Track active timers
  void trackTimer(Timer timer, String source) {
    _activeTimers.add(timer);
    if (kDebugMode) {
      debugPrint('📊 CPU Monitor: Timer added from $source (Total: ${_activeTimers.length})');
    }
  }

  /// Track stream subscriptions
  void trackSubscription(StreamSubscription subscription, String source) {
    _activeSubscriptions.add(subscription);
    if (kDebugMode) {
      debugPrint('📊 CPU Monitor: Subscription added from $source (Total: ${_activeSubscriptions.length})');
    }
  }
  
  /// Track widget rebuilds
  void trackRebuild(String widgetName) {
    _widgetRebuildCount++;
    final now = DateTime.now();
    
    if (_lastRebuild != null) {
      final timeSinceLastRebuild = now.difference(_lastRebuild!).inMilliseconds;
      if (timeSinceLastRebuild < 16) {  // Less than 1 frame (60fps)
        if (kDebugMode) {
          debugPrint('⚠️ CPU Warning: $widgetName rebuilding too fast (${timeSinceLastRebuild}ms)');
        }
      }
    }

    _lastRebuild = now;

    // Log every 100 rebuilds
    if (_widgetRebuildCount % 100 == 0) {
      if (kDebugMode) {
        debugPrint('📊 CPU Monitor: $widgetName rebuild count: $_widgetRebuildCount');
      }
    }
  }
  
  /// Get current CPU status
  Map<String, dynamic> getStatus() {
    // Clean up cancelled timers
    _activeTimers.removeWhere((timer) => !timer.isActive);
    
    return {
      'activeTimers': _activeTimers.length,
      'activeSubscriptions': _activeSubscriptions.length,
      'rebuildCount': _widgetRebuildCount,
      'timersActive': _activeTimers.where((t) => t.isActive).length,
    };
  }
  
  /// Print CPU report
  void printReport() {
    final status = getStatus();
    if (kDebugMode) {
      debugPrint('');
      if (kDebugMode) {
        debugPrint('=' * 50);
      }
      if (kDebugMode) {
        debugPrint('📊 CPU PERFORMANCE REPORT');
      }
      if (kDebugMode) {
        debugPrint('=' * 50);
      }
      if (kDebugMode) {
        debugPrint('Active Timers: ${status['activeTimers']}');
      }
      if (kDebugMode) {
        debugPrint('Active Subscriptions: ${status['activeSubscriptions']}');
      }
      if (kDebugMode) {
        debugPrint('Widget Rebuilds: ${status['rebuildCount']}');
      }
      if (kDebugMode) {
        debugPrint('Timers Actually Running: ${status['timersActive']}');
      }
      if (kDebugMode) {
        debugPrint('=' * 50);
      }
      if (kDebugMode) {
        debugPrint('');
      }
    }
  }
  
  /// Clean up all tracked resources
  void cleanup() {
    // Cancel all timers
    for (final timer in _activeTimers) {
      if (timer.isActive) {
        timer.cancel();
      }
    }
    _activeTimers.clear();
    
    // Cancel all subscriptions
    for (final subscription in _activeSubscriptions) {
      subscription.cancel();
    }
    _activeSubscriptions.clear();
    
    _widgetRebuildCount = 0;
    _lastRebuild = null;

    if (kDebugMode) {
      debugPrint('✅ CPU Monitor: All resources cleaned up');
    }
  }
  
  /// Start periodic monitoring
  Timer? _monitoringTimer;
  
  void startMonitoring({Duration interval = const Duration(seconds: 30)}) {
    _monitoringTimer?.cancel();
    _monitoringTimer = Timer.periodic(interval, (_) {
      printReport();
      
      // Warn if too many timers
      final status = getStatus();
      if (status['activeTimers'] > 5) {
        if (kDebugMode) {
          debugPrint('⚠️ CPU WARNING: Too many active timers (${status['activeTimers']})');
        }
      }

      if (status['activeSubscriptions'] > 20) {
        if (kDebugMode) {
          debugPrint('⚠️ CPU WARNING: Too many active subscriptions (${status['activeSubscriptions']})');
        }
      }
    });
  }
  
  void stopMonitoring() {
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
  }
}

/// Widget wrapper to track rebuilds
class CPUMonitorWidget extends StatelessWidget {
  
  const CPUMonitorWidget({
    super.key,
    required this.widgetName,
    required this.child,
  });
  final String widgetName;
  final Widget child;
  
  @override
  Widget build(BuildContext context) {
    CPUMonitor().trackRebuild(widgetName);
    return child;
  }
}