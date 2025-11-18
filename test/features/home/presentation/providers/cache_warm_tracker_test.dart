import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/home/presentation/providers/cache_warm_tracker.dart';

void main() {
  group('CacheWarmTracker', () {
    test('tracks cache hits and misses', () {
      final tracker = CacheWarmTracker();

      tracker.startSession();
      tracker.trackCacheAccess(key: 'test_key', isHit: true);
      tracker.trackCacheAccess(key: 'test_key', isHit: false);
      tracker.trackCacheAccess(key: 'test_key', isHit: true);

      expect(tracker.overallHitRate, closeTo(66.67, 0.01));
    });

    test('generates actionable insights', () {
      final tracker = CacheWarmTracker();

      tracker.startSession();

      // Simulate poor cache performance
      for (int i = 0; i < 10; i++) {
        tracker.trackCacheAccess(key: 'poor_key', isHit: false);
      }

      final report = tracker.generateReport();
      final insights = report['actionable_insights'] as List;

      expect(insights.length, greaterThan(0));
      expect(insights.any((i) => i.contains('below 80%')), isTrue);
    });

    test('calculates percentiles correctly', () {
      final tracker = CacheWarmTracker();

      tracker.startSession();

      // Different cache keys with different hit rates
      for (int i = 0; i < 5; i++) {
        tracker.trackCacheAccess(key: 'good_key', isHit: true);
      }

      for (int i = 0; i < 3; i++) {
        tracker.trackCacheAccess(key: 'medium_key', isHit: i % 2 == 0);
      }

      for (int i = 0; i < 10; i++) {
        tracker.trackCacheAccess(key: 'bad_key', isHit: false);
      }

      final report = tracker.generateReport();
      final percentiles = report['percentiles'] as Map;

      expect(percentiles['p50_hit_rate'], isA<double>());
      expect(percentiles['p95_hit_rate'], isA<double>());
      expect(percentiles['p99_hit_rate'], isA<double>());
    });
  });
}
