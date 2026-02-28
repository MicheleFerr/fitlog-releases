import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/home/providers/volume_settings_provider.dart';

void main() {
  // ---------------------------------------------------------------------------
  // VolumeSettings construction and defaults
  // ---------------------------------------------------------------------------
  group('VolumeSettings defaults', () {
    test('defaults to kg unit', () {
      final settings = VolumeSettings();

      expect(settings.unit, WeightUnit.kg);
    });

    test('defaults to week period', () {
      final settings = VolumeSettings();

      expect(settings.period, VolumePeriod.week);
    });
  });

  // ---------------------------------------------------------------------------
  // VolumeSettings.copyWith
  // ---------------------------------------------------------------------------
  group('VolumeSettings.copyWith', () {
    test('updates unit without changing period', () {
      final original = VolumeSettings(unit: WeightUnit.kg, period: VolumePeriod.month);
      final updated = original.copyWith(unit: WeightUnit.lbs);

      expect(updated.unit, WeightUnit.lbs);
      expect(updated.period, VolumePeriod.month); // preserved
    });

    test('updates period without changing unit', () {
      final original = VolumeSettings(unit: WeightUnit.lbs, period: VolumePeriod.week);
      final updated = original.copyWith(period: VolumePeriod.year);

      expect(updated.period, VolumePeriod.year);
      expect(updated.unit, WeightUnit.lbs); // preserved
    });

    test('does not mutate original', () {
      final original = VolumeSettings(unit: WeightUnit.kg, period: VolumePeriod.week);
      original.copyWith(unit: WeightUnit.lbs);

      expect(original.unit, WeightUnit.kg);
    });
  });

  // ---------------------------------------------------------------------------
  // VolumeSettings.convertWeight
  // ---------------------------------------------------------------------------
  group('VolumeSettings.convertWeight', () {
    test('kg unit returns value unchanged', () {
      final settings = VolumeSettings(unit: WeightUnit.kg);

      expect(settings.convertWeight(100.0), 100.0);
    });

    test('lbs unit converts using factor 2.20462', () {
      final settings = VolumeSettings(unit: WeightUnit.lbs);

      expect(settings.convertWeight(100.0), closeTo(220.462, 0.001));
    });

    test('converting 0 kg returns 0 for both units', () {
      final kg = VolumeSettings(unit: WeightUnit.kg);
      final lbs = VolumeSettings(unit: WeightUnit.lbs);

      expect(kg.convertWeight(0), 0.0);
      expect(lbs.convertWeight(0), 0.0);
    });

    test('common weight: 80 kg converts to ~176.37 lbs', () {
      final settings = VolumeSettings(unit: WeightUnit.lbs);

      expect(settings.convertWeight(80.0), closeTo(176.37, 0.01));
    });
  });

  // ---------------------------------------------------------------------------
  // VolumeSettings.unitSymbol
  // ---------------------------------------------------------------------------
  group('VolumeSettings.unitSymbol', () {
    test('kg unit symbol is "kg"', () {
      final settings = VolumeSettings(unit: WeightUnit.kg);

      expect(settings.unitSymbol, 'kg');
    });

    test('lbs unit symbol is "lbs"', () {
      final settings = VolumeSettings(unit: WeightUnit.lbs);

      expect(settings.unitSymbol, 'lbs');
    });
  });

  // ---------------------------------------------------------------------------
  // VolumeSettings.getDateRange
  // ---------------------------------------------------------------------------
  group('VolumeSettings.getDateRange', () {
    test('week period start is approximately 7 days ago', () {
      final settings = VolumeSettings(period: VolumePeriod.week);
      final range = settings.getDateRange();
      final now = DateTime.now();

      final diff = now.difference(range.start).inDays;

      // Allow 1 day of tolerance for test execution time
      expect(diff, inInclusiveRange(6, 8));
    });

    test('week period end is approximately now', () {
      final settings = VolumeSettings(period: VolumePeriod.week);
      final before = DateTime.now();
      final range = settings.getDateRange();
      final after = DateTime.now();

      expect(
        range.end.millisecondsSinceEpoch,
        inInclusiveRange(
          before.millisecondsSinceEpoch,
          after.millisecondsSinceEpoch,
        ),
      );
    });

    test('month period start is approximately 1 month ago', () {
      final settings = VolumeSettings(period: VolumePeriod.month);
      final range = settings.getDateRange();
      final now = DateTime.now();

      // Check it's around 28-31 days ago
      final diff = now.difference(range.start).inDays;
      expect(diff, inInclusiveRange(27, 32));
    });

    test('year period start is approximately 1 year ago', () {
      final settings = VolumeSettings(period: VolumePeriod.year);
      final range = settings.getDateRange();
      final now = DateTime.now();

      final diff = now.difference(range.start).inDays;
      // ~365 days, allow ±2 days
      expect(diff, inInclusiveRange(363, 367));
    });

    test('allTime period start is before 2021', () {
      final settings = VolumeSettings(period: VolumePeriod.allTime);
      final range = settings.getDateRange();

      expect(range.start.isBefore(DateTime(2021)), isTrue);
    });

    test('start is always before end', () {
      for (final period in VolumePeriod.values) {
        final settings = VolumeSettings(period: period);
        final range = settings.getDateRange();

        expect(
          range.start.isBefore(range.end),
          isTrue,
          reason: 'Period $period: start should be before end',
        );
      }
    });
  });

  // ---------------------------------------------------------------------------
  // WeightUnit enum
  // ---------------------------------------------------------------------------
  group('WeightUnit', () {
    test('has exactly 2 values', () {
      expect(WeightUnit.values.length, 2);
    });
  });

  // ---------------------------------------------------------------------------
  // VolumePeriod enum
  // ---------------------------------------------------------------------------
  group('VolumePeriod', () {
    test('has exactly 4 values', () {
      expect(VolumePeriod.values.length, 4);
    });

    test('contains week, month, year, allTime', () {
      expect(VolumePeriod.values, contains(VolumePeriod.week));
      expect(VolumePeriod.values, contains(VolumePeriod.month));
      expect(VolumePeriod.values, contains(VolumePeriod.year));
      expect(VolumePeriod.values, contains(VolumePeriod.allTime));
    });
  });

  // ---------------------------------------------------------------------------
  // DateRange
  // ---------------------------------------------------------------------------
  group('DateRange', () {
    test('stores start and end correctly', () {
      final start = DateTime(2025, 1, 1);
      final end = DateTime(2025, 12, 31);
      final range = DateRange(start: start, end: end);

      expect(range.start, start);
      expect(range.end, end);
    });
  });
}
