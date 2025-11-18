/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation/providers
/// 🎯 Feature: home
/// 🔧 Type: Cache performance tracking
///
/// CacheWarmTracker - Tracks cache warming performance and hit rates
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CacheWarmTracker {
  final Map<String, CacheMetrics> _metrics = {};
  DateTime? _sessionStart;

  void startSession() {
    _sessionStart = DateTime.now();
    _metrics.clear();

    if (kDebugMode) {
      debugPrint('🔥 [CACHE] Session started at ${_sessionStart!.toIso8601String()}');
    }
  }

  void trackCacheAccess({
    required String key,
    required bool isHit,
    int? dataSize,
    Duration? fetchTime,
  }) {
    _metrics.putIfAbsent(key, () => CacheMetrics(key: key));

    final metrics = _metrics[key]!;
    metrics.totalAccesses++;

    if (isHit) {
      metrics.hits++;

      if (kDebugMode) {
        debugPrint('✅ [CACHE] HIT: $key (${metrics.hitRate.toStringAsFixed(1)}% hit rate)');
      }
    } else {
      metrics.misses++;

      if (fetchTime != null) {
        metrics.totalFetchTime = metrics.totalFetchTime + fetchTime;
      }

      if (dataSize != null) {
        metrics.totalDataFetched += dataSize;
      }

      if (kDebugMode) {
        debugPrint('❌ [CACHE] MISS: $key (fetched ${dataSize ?? 0}B in ${fetchTime?.inMilliseconds ?? 0}ms)');
      }
    }
  }

  double get overallHitRate {
    if (_metrics.isEmpty) return 0.0;

    final totalHits = _metrics.values.fold<int>(0, (sum, m) => sum + m.hits);
    final totalAccesses = _metrics.values.fold<int>(0, (sum, m) => sum + m.totalAccesses);

    return totalAccesses > 0 ? (totalHits / totalAccesses) * 100 : 0.0;
  }

  Duration get totalSessionTime {
    if (_sessionStart == null) return Duration.zero;
    return DateTime.now().difference(_sessionStart!);
  }

  Map<String, dynamic> generateReport() {
    final p50 = _calculatePercentile(50);
    final p95 = _calculatePercentile(95);
    final p99 = _calculatePercentile(99);

    return {
      'session_duration': totalSessionTime.inSeconds,
      'overall_hit_rate': overallHitRate,
      'total_cache_keys': _metrics.length,
      'percentiles': {
        'p50_hit_rate': p50,
        'p95_hit_rate': p95,
        'p99_hit_rate': p99,
      },
      'per_key_metrics': _metrics.map((key, metrics) => MapEntry(key, {
        'hit_rate': metrics.hitRate,
        'hits': metrics.hits,
        'misses': metrics.misses,
        'avg_fetch_time': metrics.averageFetchTime.inMilliseconds,
        'total_data': metrics.totalDataFetched,
      })),
      'actionable_insights': _generateInsights(),
    };
  }

  double _calculatePercentile(int percentile) {
    if (_metrics.isEmpty) return 0.0;

    final hitRates = _metrics.values.map((m) => m.hitRate).toList()..sort();
    final index = ((percentile / 100) * hitRates.length).ceil() - 1;
    return hitRates[index.clamp(0, hitRates.length - 1)];
  }

  List<String> _generateInsights() {
    final insights = <String>[];

    // Low hit rate warning
    if (overallHitRate < 80) {
      insights.add('⚠️ Cache hit rate below 80% - consider pre-warming critical data');
    }

    // Identify keys with poor performance
    final poorPerformers = _metrics.entries
        .where((e) => e.value.hitRate < 50 && e.value.totalAccesses > 5)
        .map((e) => e.key)
        .toList();

    if (poorPerformers.isNotEmpty) {
      insights.add('🔴 Poor cache performance: ${poorPerformers.join(", ")}');
    }

    // Identify keys that are never hit
    final neverHit = _metrics.entries
        .where((e) => e.value.hits == 0 && e.value.totalAccesses > 3)
        .map((e) => e.key)
        .toList();

    if (neverHit.isNotEmpty) {
      insights.add('💡 Never cached (consider removal): ${neverHit.join(", ")}');
    }

    // Success message
    if (overallHitRate > 90) {
      insights.add('🎉 Excellent cache performance! Hit rate > 90%');
    }

    return insights;
  }

  void clear() {
    _metrics.clear();
    _sessionStart = null;
  }
}

class CacheMetrics {
  CacheMetrics({required this.key});

  final String key;
  int hits = 0;
  int misses = 0;
  int totalAccesses = 0;
  Duration totalFetchTime = Duration.zero;
  int totalDataFetched = 0;

  double get hitRate => totalAccesses > 0 ? (hits / totalAccesses) * 100 : 0.0;

  Duration get averageFetchTime {
    if (misses == 0) return Duration.zero;
    return Duration(milliseconds: totalFetchTime.inMilliseconds ~/ misses);
  }
}

// Provider
final cacheWarmTrackerProvider = Provider<CacheWarmTracker>((ref) {
  return CacheWarmTracker();
});
