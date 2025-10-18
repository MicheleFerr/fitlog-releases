import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Memory Monitor for GymBro
/// Tracks memory usage and helps identify memory leaks
class MemoryMonitor {
  factory MemoryMonitor() => _instance;
  MemoryMonitor._internal();
  static final MemoryMonitor _instance = MemoryMonitor._internal();

  Timer? _monitoringTimer;
  int _lastMemoryUsage = 0;
  final List<String> _activeResources = [];
  final Map<String, int> _resourceCounts = {};
  
  /// Start monitoring memory usage
  void startMonitoring({Duration interval = const Duration(seconds: 30)}) {
    if (!kDebugMode) return; // Only in debug mode
    
    _monitoringTimer?.cancel();
    _monitoringTimer = Timer.periodic(interval, (_) {
      _checkMemory();
    });
    
    debugPrint('🧠 Memory Monitor started - checking every ${interval.inSeconds}s');
  }
  
  /// Stop monitoring
  void stopMonitoring() {
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
  }
  
  /// Track a resource
  void trackResource(String resourceType, String resourceId) {
    if (!kDebugMode) return;
    
    final key = '$resourceType:$resourceId';
    _activeResources.add(key);
    _resourceCounts[resourceType] = (_resourceCounts[resourceType] ?? 0) + 1;
    
    // Warn if too many resources
    if (_resourceCounts[resourceType]! > 10) {
      debugPrint('⚠️ MEMORY WARNING: Too many $resourceType (${_resourceCounts[resourceType]})');
    }
  }
  
  /// Release a resource
  void releaseResource(String resourceType, String resourceId) {
    if (!kDebugMode) return;
    
    final key = '$resourceType:$resourceId';
    _activeResources.remove(key);
    if (_resourceCounts.containsKey(resourceType)) {
      _resourceCounts[resourceType] = (_resourceCounts[resourceType]! - 1).clamp(0, 999);
    }
  }
  
  /// Check current memory usage
  void _checkMemory() {
    if (!kDebugMode) return;
    
    // Get memory info using developer tools
    developer.ServiceExtensionResponse.result('''
    {
      "heapUsage": ${_estimateMemoryMB()},
      "activeResources": ${_activeResources.length},
      "resourceCounts": ${_resourceCounts.toString()}
    }
    ''');
    
    final currentMemory = _estimateMemoryMB();
    final memoryDelta = currentMemory - _lastMemoryUsage;
    
    // Print report
    debugPrint('');
    debugPrint('=' * 50);
    debugPrint('🧠 MEMORY USAGE REPORT');
    debugPrint('=' * 50);
    debugPrint('Estimated Memory: ${currentMemory}MB');
    debugPrint('Memory Delta: ${memoryDelta > 0 ? '+' : ''}${memoryDelta}MB');
    debugPrint('Active Resources: ${_activeResources.length}');
    
    // Print resource breakdown
    if (_resourceCounts.isNotEmpty) {
      debugPrint('Resource Breakdown:');
      _resourceCounts.forEach((type, count) {
        if (count > 0) {
          debugPrint('  - $type: $count');
        }
      });
    }
    
    // Warnings
    if (currentMemory > 200) {
      debugPrint('⚠️ WARNING: High memory usage (>200MB)');
    }
    
    if (memoryDelta > 50) {
      debugPrint('⚠️ WARNING: Large memory increase (+${memoryDelta}MB)');
    }
    
    if (_activeResources.length > 100) {
      debugPrint('⚠️ WARNING: Too many active resources (${_activeResources.length})');
    }
    
    debugPrint('=' * 50);
    debugPrint('');
    
    _lastMemoryUsage = currentMemory;
  }
  
  /// Estimate memory usage in MB (simplified)
  int _estimateMemoryMB() {
    // This is a rough estimate based on active resources
    // Each resource is estimated at ~1MB average
    // In reality, you'd use proper memory profiling tools
    return 50 + // Base app memory
           (_activeResources.length * 1) + // Resources
           (_resourceCounts['Firebase'] ?? 0) * 5 + // Firebase connections
           (_resourceCounts['Image'] ?? 0) * 2 + // Images
           (_resourceCounts['Animation'] ?? 0) * 3; // Animations
  }
  
  /// Get current status
  Map<String, dynamic> getStatus() {
    return {
      'estimatedMemoryMB': _estimateMemoryMB(),
      'activeResources': _activeResources.length,
      'resourceCounts': Map.from(_resourceCounts),
    };
  }
  
  /// Clear all tracking (for cleanup)
  void clear() {
    _activeResources.clear();
    _resourceCounts.clear();
    _lastMemoryUsage = 0;
  }
}

/// Mixin to add memory tracking to widgets
mixin MemoryTrackingMixin<T extends StatefulWidget> on State<T> {
  String get resourceId => '${widget.runtimeType}_$hashCode';
  
  @override
  void initState() {
    super.initState();
    MemoryMonitor().trackResource('Widget', resourceId);
  }
  
  @override
  void dispose() {
    MemoryMonitor().releaseResource('Widget', resourceId);
    super.dispose();
  }
}

/// Mixin for providers
mixin ProviderMemoryTrackingMixin {
  void trackProviderCreation(String providerName) {
    MemoryMonitor().trackResource('Provider', providerName);
  }
  
  void trackProviderDisposal(String providerName) {
    MemoryMonitor().releaseResource('Provider', providerName);
  }
}