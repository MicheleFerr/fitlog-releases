# 🔍 Memory Leak Detector System: Memory Profiling & Leak Detection

> **HIGH Priority System** - Performance monitoring & leak prevention
> **Location**: `lib/core/performance/memory_leak_detector.dart`
> **Status**: Production (debug mode)
> **Last Updated**: October 2025

## Overview

**Memory Leak Detector System** identifies and tracks memory issues:
- **Real-Time Memory Monitoring**: Current/peak memory usage
- **Leak Detection**: Identifies growing allocations
- **Provider Lifecycle Tracking**: Detects undisposed providers
- **Stream Subscription Tracking**: Catches uncanceled streams
- **Timer Tracking**: Prevents timer leaks

## Architecture

### Monitoring Components

**MemoryLeakDetector**: Main detector class
```dart
- trackProvider(name, lifecycle)
- trackStream(name, subscription)
- trackTimer(name, timer)
- reportMetrics() → Memory statistics
```

### Detection Thresholds

```dart
const int _memoryThreshold = 150;           // MB (warning)
const int _memoryAlertThreshold = 250;      // MB (critical)
const Duration _growthCheckInterval = Duration(seconds: 10);
const double _growthRateThreshold = 10.0;   // MB/minute
```

## How It Works

### Provider Lifecycle Tracking

```dart
// When provider is used
detector.trackProvider('userProvider', 'created');

// When provider is cached
detector.trackProvider('userProvider', 'cached');

// When provider is disposed
detector.trackProvider('userProvider', 'disposed');

// If provider not disposed → LEAK DETECTED
```

### Stream Subscription Tracking

```dart
final subscription = stream.listen((data) {
  detector.trackStream('workoutStream', subscription);
});

// Later: Must call
subscription.cancel();
detector.untrackStream('workoutStream');

// If not canceled → LEAK DETECTED
```

### Timer Tracking

```dart
final timer = Timer.periodic(Duration(seconds: 1), (_) {
  detector.trackTimer('workoutTimer', timer);
});

// Later: Must cancel
timer.cancel();
detector.untrackTimer('workoutTimer');

// If not canceled → LEAK DETECTED
```

## Memory Thresholds

| Level | Memory | Action |
|-------|--------|--------|
| **Normal** | < 100 MB | No action |
| **Warning** | 100-150 MB | Log warning |
| **Alert** | 150-250 MB | Aggressive GC |
| **Critical** | > 250 MB | Force cleanup |

## Growth Rate Detection

```
Timeline:
├─ 0s:   100 MB (baseline)
├─ 10s:  110 MB (↑10 MB)
├─ 20s:  120 MB (↑10 MB) ← Growth rate > threshold
└─ 30s:  LEAK DETECTED (consistent growth)
```

## Usage

```dart
// In debug mode
if (kDebugMode) {
  ref.listen(memoryLeakDetectorProvider, (_, detector) {
    final metrics = detector.reportMetrics();
    print('Memory: ${metrics.currentMemory}MB (peak: ${metrics.peakMemory}MB)');

    if (metrics.leaksDetected.isNotEmpty) {
      print('⚠️ LEAKS DETECTED:');
      for (final leak in metrics.leaksDetected) {
        print('  - $leak');
      }
    }
  });
}
```

## Diagnostics Report

```dart
final report = detector.generateDiagnosticsReport();

print('''
MEMORY DIAGNOSTICS
  Current: ${report.currentMemory} MB
  Peak: ${report.peakMemory} MB

PROVIDER TRACKING
  Active: ${report.activeProviders}
  Disposed: ${report.disposedProviders}
  Suspicious: ${report.suspiciousProviders}

STREAM TRACKING
  Active: ${report.activeStreams}
  Canceled: ${report.canceledStreams}
  Orphaned: ${report.orphanedStreams}

TIMER TRACKING
  Active: ${report.activeTimers}
  Canceled: ${report.canceledTimers}
  Zombie: ${report.zombieTimers}
''');
```

## Common Leaks

### ❌ Undisposed Providers
```dart
// LEAK: Provider created but never disposed
final myProvider = StateNotifierProvider((ref) {
  return MyNotifier();  // dispose() never called
});
```

### ❌ Uncanceled Streams
```dart
// LEAK: Subscription never canceled
final subscription = stream.listen((_) {});
// subscription.cancel() never called
```

### ❌ Running Timers
```dart
// LEAK: Timer never canceled
final timer = Timer.periodic(Duration(seconds: 1), (_) {});
// timer.cancel() never called
```

## Performance Impact

- **Memory Overhead**: 1-5 MB (debug only)
- **CPU Overhead**: < 2% (sampling mode)
- **Latency**: Negligible
- **Enabled**: Debug mode only, disabled in release

## Best Practices

1. **Always dispose**: Providers, streams, timers
2. **Use Ref.onDispose**: Cleanup in provider dispose
3. **Cancel subscriptions**: Explicitly call `.cancel()`
4. **Monitor regularly**: Check metrics in debug
5. **Profile before shipping**: Ensure no major leaks

## Cleanup Checklist

- [ ] All StateNotifiers call dispose()
- [ ] All streams canceled in cleanup
- [ ] All timers canceled
- [ ] All listeners removed
- [ ] No circular references
- [ ] Memory grows < 10 MB/minute

---

**See Also**: `PERFORMANCE_OPTIMIZATIONS.md` (general optimization)
