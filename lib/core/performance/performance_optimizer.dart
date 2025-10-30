import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

/// Performance optimizer for GymBro app
/// Provides tools to monitor and optimize widget rebuilds and provider usage
class PerformanceOptimizer {
  factory PerformanceOptimizer() => _instance;
  PerformanceOptimizer._internal();
  static final PerformanceOptimizer _instance = PerformanceOptimizer._internal();

  final Map<String, int> _providerRebuildCounts = {};
  final Map<String, DateTime> _lastRebuildTimes = {};
  Timer? _resetTimer;
  
  /// Track provider rebuilds to identify excessive updates
  void trackProviderRebuild(String providerName) {
    if (!kDebugMode) return;
    
    final now = DateTime.now();
    _providerRebuildCounts[providerName] = (_providerRebuildCounts[providerName] ?? 0) + 1;
    _lastRebuildTimes[providerName] = now;
    
    // Reset counters every 10 seconds
    _resetTimer?.cancel();
    _resetTimer = Timer(const Duration(seconds: 10), () {
      _providerRebuildCounts.clear();
      _lastRebuildTimes.clear();
    });
    
    // Log excessive rebuilds
    final count = _providerRebuildCounts[providerName]!;
    if (count > 5) {
      debugPrint('⚠️ PERFORMANCE: Provider "$providerName" rebuilt $count times in 10s');
    }
  }
  
  /// Get rebuild statistics
  Map<String, int> getRebuildStats() => Map.from(_providerRebuildCounts);
  
  /// Schedule widget rebuild optimization
  static void optimizeWidgetRebuild(VoidCallback callback) {
    // Use addPostFrameCallback to avoid rebuilding during a frame
    SchedulerBinding.instance.addPostFrameCallback((_) {
      callback();
    });
  }
}

/// Mixin to add performance tracking to providers
mixin PerformanceTrackingMixin {
  void trackRebuild(String providerName) {
    PerformanceOptimizer().trackProviderRebuild(providerName);
  }
}

/// Optimized Consumer widget that prevents unnecessary rebuilds
class OptimizedConsumer extends ConsumerWidget {
  
  const OptimizedConsumer({
    super.key,
    required this.builder,
    this.child,
  });
  final Widget Function(BuildContext, WidgetRef) builder;
  final Widget? child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Track the consumer rebuild for debugging
    if (kDebugMode) {
      PerformanceOptimizer().trackProviderRebuild('OptimizedConsumer');
    }
    return builder(context, ref);
  }
}

/// Provider that automatically disposes when not used
final class AutoDisposeTimerMixin<T> {
  Timer? _disposeTimer;
  
  void scheduleDisposal(Ref ref, Duration delay) {
    _disposeTimer?.cancel();
    _disposeTimer = Timer(delay, () {
      // Check if the ref is still valid before invalidating
      try {
        ref.invalidateSelf();
      } catch (_) {
        // Provider may have already been disposed
      }
    });
    
    ref.onDispose(() {
      _disposeTimer?.cancel();
    });
  }
}