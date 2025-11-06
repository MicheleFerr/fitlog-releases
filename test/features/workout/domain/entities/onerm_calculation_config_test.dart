import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/onerm_calculation_config.dart';

/// Tests for OneRMCalculationConfig enum
///
/// TDD PHASE 1: RED - These tests MUST fail initially
///
/// This test suite verifies:
/// 1. All 4 enum values exist
/// 2. Display names are correct
/// 3. Descriptions are meaningful
/// 4. Use cases are defined
/// 5. Default config is topFiveSets
/// 6. Service integration accepts config parameter
void main() {
  group('OneRMCalculationConfig Enum', () {
    // TEST 1: Enum values exist
    test('has all 4 calculation config options', () {
      expect(OneRMCalculationConfig.values.length, equals(4));
      expect(
        OneRMCalculationConfig.values,
        contains(OneRMCalculationConfig.topThreeSets),
      );
      expect(
        OneRMCalculationConfig.values,
        contains(OneRMCalculationConfig.topFiveSets),
      );
      expect(
        OneRMCalculationConfig.values,
        contains(OneRMCalculationConfig.allSetsInWindow),
      );
      expect(
        OneRMCalculationConfig.values,
        contains(OneRMCalculationConfig.medianOfTop5),
      );
    });

    // TEST 2: Display names are correct
    test('provides correct display names', () {
      expect(
        OneRMCalculationConfig.topThreeSets.displayName,
        equals('Top 3 Sets (Recency)'),
      );
      expect(
        OneRMCalculationConfig.topFiveSets.displayName,
        equals('Top 5 Sets (Balanced)'),
      );
      expect(
        OneRMCalculationConfig.allSetsInWindow.displayName,
        equals('All Recent Sets (Comprehensive)'),
      );
      expect(
        OneRMCalculationConfig.medianOfTop5.displayName,
        equals('Median Top 5 (Stable)'),
      );
    });

    // TEST 3: Descriptions are meaningful
    test('provides descriptions for each config', () {
      for (final config in OneRMCalculationConfig.values) {
        expect(config.description.isNotEmpty, isTrue);
        expect(
          config.description.length,
          greaterThan(20),
          reason: 'Description should be meaningful (>20 chars)',
        );
      }
    });

    // TEST 4: Use cases are defined
    test('provides use cases for each config', () {
      expect(
        OneRMCalculationConfig.topThreeSets.useCase,
        equals('Train 5-7x/week'),
      );
      expect(
        OneRMCalculationConfig.topFiveSets.useCase,
        equals('Train 3-5x/week (Default)'),
      );
      expect(
        OneRMCalculationConfig.allSetsInWindow.useCase,
        equals('Want full data picture'),
      );
      expect(
        OneRMCalculationConfig.medianOfTop5.useCase,
        equals('Prefer stable estimates'),
      );
    });

    // TEST 5: Default config is topFiveSets
    test('default configuration is topFiveSets', () {
      expect(
        OneRMCalculationConfigExtension.defaultConfig,
        equals(OneRMCalculationConfig.topFiveSets),
      );
    });
  });

  group('OneRMCalculationConfig Extension Methods', () {
    test('displayName returns non-empty string for all configs', () {
      for (final config in OneRMCalculationConfig.values) {
        expect(config.displayName.isNotEmpty, isTrue);
        expect(config.displayName.length, greaterThan(5));
      }
    });

    test('description returns non-empty string for all configs', () {
      for (final config in OneRMCalculationConfig.values) {
        expect(config.description.isNotEmpty, isTrue);
        expect(config.description.contains('Uses'), isTrue);
      }
    });

    test('useCase returns non-empty string for all configs', () {
      for (final config in OneRMCalculationConfig.values) {
        expect(config.useCase.isNotEmpty, isTrue);
      }
    });
  });
}
