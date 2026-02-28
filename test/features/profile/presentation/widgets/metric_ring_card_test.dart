import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/profile/presentation/widgets/metric_ring_card.dart';

void main() {
  // ═══════════════════════════════════════════════════════════════
  // MetricRingConfig Data Class
  // ═══════════════════════════════════════════════════════════════
  group('MetricRingConfig', () {
    test('stores all required fields', () {
      final config = MetricRingConfig(
        title: 'Workouts',
        value: '3/5',
        percentage: 0.6,
        color: Colors.green,
      );

      expect(config.title, 'Workouts');
      expect(config.value, '3/5');
      expect(config.percentage, 0.6);
      expect(config.color, Colors.green);
      expect(config.onTap, isNull);
    });

    test('stores optional onTap callback', () {
      var tapped = false;
      final config = MetricRingConfig(
        title: 'Volume',
        value: '75%',
        percentage: 0.75,
        color: Colors.blue,
        onTap: () => tapped = true,
      );

      expect(config.onTap, isNotNull);
      config.onTap!();
      expect(tapped, true);
    });

    test('percentage at 0.0', () {
      final config = MetricRingConfig(
        title: 'Streak',
        value: '0',
        percentage: 0.0,
        color: Colors.grey,
      );

      expect(config.percentage, 0.0);
    });

    test('percentage at 1.0 (complete)', () {
      final config = MetricRingConfig(
        title: 'Streak',
        value: '4/4',
        percentage: 1.0,
        color: Colors.green,
      );

      expect(config.percentage, 1.0);
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // MetricRingCard Static Constants
  // ═══════════════════════════════════════════════════════════════
  group('MetricRingCard constants', () {
    test('ringSize is 80.0', () {
      expect(MetricRingCard.ringSize, 80.0);
    });

    test('strokeWidth is 8.0', () {
      expect(MetricRingCard.strokeWidth, 8.0);
    });

    test('cardHeight is 120.0', () {
      expect(MetricRingCard.cardHeight, 120.0);
    });

    test('animationDuration is 800ms', () {
      expect(
        MetricRingCard.animationDuration,
        const Duration(milliseconds: 800),
      );
    });
  });
}
