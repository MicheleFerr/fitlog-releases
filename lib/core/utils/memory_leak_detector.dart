import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/core/utils/debug_logger.dart';

/// MEMORY LEAK DETECTION: Tool for detecting and reporting memory leaks
/// 
/// This tool provides various methods to detect common memory leak patterns
/// in Flutter applications, specifically focused on Timers, StreamSubscriptions,
/// and other disposable resources.
class MemoryLeakDetector {
  factory MemoryLeakDetector() => _instance;
  MemoryLeakDetector._internal();
  static final MemoryLeakDetector _instance = MemoryLeakDetector._internal();
  
  // Tracking active resources
  final Set<Timer> _activeTimers = {};
  final Set<StreamSubscription> _activeSubscriptions = {};
  final Set<String> _activeProviders = {};
  
  // Metrics
  int _totalTimersCreated = 0;
  int _totalSubscriptionsCreated = 0;
  int _totalProvidersCreated = 0;
  
  Timer? _memoryCheckTimer;
  bool _isMonitoring = false;
  
  /// Start monitoring memory leaks
  void startMonitoring({Duration interval = const Duration(seconds: 30)}) {
    if (_isMonitoring) return;
    
    _isMonitoring = true;
    DebugLogger.log(LogCategory.performance, '🔍 Memory leak monitoring started');
    
    _memoryCheckTimer = Timer.periodic(interval, (_) {
      _performMemoryCheck();
    });
  }
  
  /// Stop monitoring memory leaks
  void stopMonitoring() {
    if (!_isMonitoring) return;
    
    _isMonitoring = false;
    _memoryCheckTimer?.cancel();
    _memoryCheckTimer = null;
    
    DebugLogger.log(LogCategory.performance, '🛑 Memory leak monitoring stopped');
  }
  
  /// Register a timer for tracking
  void registerTimer(Timer timer, [String? context]) {
    _activeTimers.add(timer);
    _totalTimersCreated++;
    
    DebugLogger.log(LogCategory.performance, 
      '⏱️ Timer registered${context != null ? " ($context)" : ""} - Total active: ${_activeTimers.length}');
  }
  
  /// Unregister a timer (when properly cancelled)
  void unregisterTimer(Timer timer, [String? context]) {
    _activeTimers.remove(timer);
    
    DebugLogger.log(LogCategory.performance, 
      '✅ Timer unregistered${context != null ? " ($context)" : ""} - Total active: ${_activeTimers.length}');
  }
  
  /// Register a stream subscription for tracking
  void registerSubscription(StreamSubscription subscription, [String? context]) {
    _activeSubscriptions.add(subscription);
    _totalSubscriptionsCreated++;
    
    DebugLogger.log(LogCategory.performance, 
      '📡 Subscription registered${context != null ? " ($context)" : ""} - Total active: ${_activeSubscriptions.length}');
  }
  
  /// Unregister a subscription (when properly cancelled)
  void unregisterSubscription(StreamSubscription subscription, [String? context]) {
    _activeSubscriptions.remove(subscription);
    
    DebugLogger.log(LogCategory.performance, 
      '✅ Subscription unregistered${context != null ? " ($context)" : ""} - Total active: ${_activeSubscriptions.length}');
  }
  
  /// Register a provider for tracking
  void registerProvider(String providerId, String type) {
    _activeProviders.add(providerId);
    _totalProvidersCreated++;
    
    DebugLogger.log(LogCategory.performance, 
      '🏭 Provider registered: $type ($providerId) - Total active: ${_activeProviders.length}');
  }
  
  /// Unregister a provider (when properly disposed)
  void unregisterProvider(String providerId, String type) {
    _activeProviders.remove(providerId);
    
    DebugLogger.log(LogCategory.performance, 
      '✅ Provider unregistered: $type ($providerId) - Total active: ${_activeProviders.length}');
  }
  
  /// Perform a comprehensive memory check
  void _performMemoryCheck() {
    DebugLogger.log(LogCategory.performance, '🧐 Performing memory leak check...');
    
    // Check for dead timers that weren't properly unregistered
    final deadTimers = _activeTimers.where((timer) => !timer.isActive).toList();
    if (deadTimers.isNotEmpty) {
      DebugLogger.log(LogCategory.performance, 
        '⚠️ Found ${deadTimers.length} dead timers that should have been unregistered');
      
      // Clean up dead timers
      for (final timer in deadTimers) {
        _activeTimers.remove(timer);
      }
    }
    
    // Report current state
    _reportMemoryState();
    
    // Check system memory if available
    if (Platform.isAndroid || Platform.isIOS) {
      _checkSystemMemory();
    }
  }
  
  /// Report current memory state
  void _reportMemoryState() {
    final report = getMemoryReport();
    
    DebugLogger.log(LogCategory.performance, '📊 Memory Report:');
    DebugLogger.log(LogCategory.performance, '  Active Timers: ${report['activeTimers']}');
    DebugLogger.log(LogCategory.performance, '  Active Subscriptions: ${report['activeSubscriptions']}');
    DebugLogger.log(LogCategory.performance, '  Active Providers: ${report['activeProviders']}');
    DebugLogger.log(LogCategory.performance, '  Total Timers Created: ${report['totalTimers']}');
    DebugLogger.log(LogCategory.performance, '  Total Subscriptions Created: ${report['totalSubscriptions']}');
    DebugLogger.log(LogCategory.performance, '  Total Providers Created: ${report['totalProviders']}');
    
    // Warn about potential leaks
    if (report['activeTimers']! > 10) {
      DebugLogger.log(LogCategory.performance, 
        '🚨 WARNING: High number of active timers (${report['activeTimers']}) - possible memory leak!');
    }
    
    if (report['activeSubscriptions']! > 20) {
      DebugLogger.log(LogCategory.performance, 
        '🚨 WARNING: High number of active subscriptions (${report['activeSubscriptions']}) - possible memory leak!');
    }
    
    if (report['activeProviders']! > 50) {
      DebugLogger.log(LogCategory.performance, 
        '🚨 WARNING: High number of active providers (${report['activeProviders']}) - possible memory leak!');
    }
  }
  
  /// Check system memory usage
  void _checkSystemMemory() {
    if (kDebugMode) {
      // In debug mode, we can try to get memory info
      // This is platform-specific and may not always work
      try {
        // Note: This is a simplified approach
        // In production, you might want to use more sophisticated memory monitoring
        DebugLogger.log(LogCategory.performance, '💾 System memory check - This is a placeholder for platform-specific memory monitoring');
      } catch (e) {
        DebugLogger.log(LogCategory.performance, '❌ Could not check system memory: $e');
      }
    }
  }
  
  /// Get detailed memory report
  Map<String, int> getMemoryReport() {
    return {
      'activeTimers': _activeTimers.length,
      'activeSubscriptions': _activeSubscriptions.length,
      'activeProviders': _activeProviders.length,
      'totalTimers': _totalTimersCreated,
      'totalSubscriptions': _totalSubscriptionsCreated,
      'totalProviders': _totalProvidersCreated,
    };
  }
  
  /// Force cleanup of all tracked resources (for testing)
  void forceCleanupAll() {
    DebugLogger.log(LogCategory.performance, '🧹 Force cleaning up all tracked resources...');
    
    // Cancel all tracked timers
    for (final timer in _activeTimers.toList()) {
      try {
        timer.cancel();
      } catch (e) {
        DebugLogger.log(LogCategory.performance, '❌ Error cancelling timer during force cleanup: $e');
      }
    }
    _activeTimers.clear();
    
    // Cancel all tracked subscriptions
    for (final subscription in _activeSubscriptions.toList()) {
      try {
        subscription.cancel();
      } catch (e) {
        DebugLogger.log(LogCategory.performance, '❌ Error cancelling subscription during force cleanup: $e');
      }
    }
    _activeSubscriptions.clear();
    
    _activeProviders.clear();
    
    DebugLogger.log(LogCategory.performance, '✅ Force cleanup completed');
  }
  
  /// Generate a detailed leak report
  String generateLeakReport() {
    final report = getMemoryReport();
    final buffer = StringBuffer();
    
    buffer.writeln('=== MEMORY LEAK DETECTION REPORT ===');
    buffer.writeln('Timestamp: ${DateTime.now().toIso8601String()}');
    buffer.writeln('');
    
    buffer.writeln('Active Resources:');
    buffer.writeln('  Timers: ${report['activeTimers']} active');
    buffer.writeln('  Subscriptions: ${report['activeSubscriptions']} active');
    buffer.writeln('  Providers: ${report['activeProviders']} active');
    buffer.writeln('');
    
    buffer.writeln('Total Created Since Start:');
    buffer.writeln('  Timers: ${report['totalTimers']}');
    buffer.writeln('  Subscriptions: ${report['totalSubscriptions']}');
    buffer.writeln('  Providers: ${report['totalProviders']}');
    buffer.writeln('');
    
    // Analyze potential leaks
    buffer.writeln('Analysis:');
    
    if (report['activeTimers']! > 10) {
      buffer.writeln('  🚨 HIGH TIMER COUNT: ${report['activeTimers']} active timers (threshold: 10)');
    } else {
      buffer.writeln('  ✅ Timer count within normal range');
    }
    
    if (report['activeSubscriptions']! > 20) {
      buffer.writeln('  🚨 HIGH SUBSCRIPTION COUNT: ${report['activeSubscriptions']} active subscriptions (threshold: 20)');
    } else {
      buffer.writeln('  ✅ Subscription count within normal range');
    }
    
    if (report['activeProviders']! > 50) {
      buffer.writeln('  🚨 HIGH PROVIDER COUNT: ${report['activeProviders']} active providers (threshold: 50)');
    } else {
      buffer.writeln('  ✅ Provider count within normal range');
    }
    
    buffer.writeln('');
    buffer.writeln('=== END REPORT ===');
    
    return buffer.toString();
  }
  
  /// Dispose the detector itself
  void dispose() {
    stopMonitoring();
    forceCleanupAll();
    
    _totalTimersCreated = 0;
    _totalSubscriptionsCreated = 0;
    _totalProvidersCreated = 0;
    
    DebugLogger.log(LogCategory.performance, '🗑️ Memory leak detector disposed');
  }
}

/// Extension methods for easier tracking
extension TimerTracking on Timer {
  /// Start tracking this timer for memory leaks
  Timer trackMemoryLeaks([String? context]) {
    MemoryLeakDetector().registerTimer(this, context);
    return this;
  }
  
  /// Cancel timer and remove from tracking
  void cancelAndUntrack([String? context]) {
    cancel();
    MemoryLeakDetector().unregisterTimer(this, context);
  }
}

extension SubscriptionTracking on StreamSubscription {
  /// Start tracking this subscription for memory leaks
  StreamSubscription trackMemoryLeaks([String? context]) {
    MemoryLeakDetector().registerSubscription(this, context);
    return this;
  }
  
  /// Cancel subscription and remove from tracking
  Future<void> cancelAndUntrack([String? context]) async {
    await cancel();
    MemoryLeakDetector().unregisterSubscription(this, context);
  }
}