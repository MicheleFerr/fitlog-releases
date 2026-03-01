/// Exercise Mapping Entity Tests
///
/// Tests JSON round-trip, computed properties, enum behaviours, and extensions.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/exercise_mapping.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  ExerciseMapping makeMapping({
    String gymbroId = 'ex-001',
    String gymbroName = 'Panca Piana con Bilanciere',
    String gymbroEquipment = 'Bilanciere',
    String? gymbroFocus = 'PETT, TRIC',
    double confidence = 0.92,
    MappingStatus status = MappingStatus.auto,
    String? standardId = 'barbell_bench_press',
    String? standardName = 'Barbell Bench Press',
    String? standardEquipment = 'Barbell',
    String? dataSource = 'exrx_net',
    String? fallbackReason,
  }) {
    return ExerciseMapping(
      gymbroId: gymbroId,
      gymbroName: gymbroName,
      gymbroEquipment: gymbroEquipment,
      gymbroFocus: gymbroFocus,
      confidence: confidence,
      status: status,
      standardId: standardId,
      standardName: standardName,
      standardEquipment: standardEquipment,
      dataSource: dataSource,
      fallbackReason: fallbackReason,
    );
  }

  // ---------------------------------------------------------------------------
  // MappingStatus enum
  // ---------------------------------------------------------------------------

  group('MappingStatus', () {
    test('isReliable is true for auto and verified', () {
      expect(MappingStatus.auto.isReliable, isTrue);
      expect(MappingStatus.verified.isReliable, isTrue);
      expect(MappingStatus.review.isReliable, isFalse);
      expect(MappingStatus.fallback.isReliable, isFalse);
    });

    test('needsReview is true only for review', () {
      expect(MappingStatus.review.needsReview, isTrue);
      expect(MappingStatus.auto.needsReview, isFalse);
      expect(MappingStatus.fallback.needsReview, isFalse);
      expect(MappingStatus.verified.needsReview, isFalse);
    });

    test('isFallback is true only for fallback', () {
      expect(MappingStatus.fallback.isFallback, isTrue);
      expect(MappingStatus.auto.isFallback, isFalse);
      expect(MappingStatus.review.isFallback, isFalse);
    });

    test('isVerified is true only for verified', () {
      expect(MappingStatus.verified.isVerified, isTrue);
      expect(MappingStatus.auto.isVerified, isFalse);
    });

    test('has 4 values', () {
      expect(MappingStatus.values.length, equals(4));
    });
  });

  // ---------------------------------------------------------------------------
  // ExerciseMappingExtension.canSuggestWeight
  // ---------------------------------------------------------------------------

  group('ExerciseMappingExtension.canSuggestWeight', () {
    test('true for auto status', () {
      final m = makeMapping(status: MappingStatus.auto);
      expect(m.canSuggestWeight, isTrue);
    });

    test('true for review status', () {
      final m = makeMapping(status: MappingStatus.review, confidence: 0.70);
      expect(m.canSuggestWeight, isTrue);
    });

    test('true for verified status', () {
      final m = makeMapping(status: MappingStatus.verified);
      expect(m.canSuggestWeight, isTrue);
    });

    test('false for fallback status', () {
      final m = makeMapping(
        status: MappingStatus.fallback,
        confidence: 0.40,
        standardId: null,
        fallbackReason: 'No semantic match',
      );
      expect(m.canSuggestWeight, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // confidencePercent
  // ---------------------------------------------------------------------------

  group('confidencePercent', () {
    test('converts 0.0 to 0.0', () {
      final m = makeMapping(
        confidence: 0.0,
        status: MappingStatus.fallback,
      );
      expect(m.confidencePercent, equals(0.0));
    });

    test('converts 1.0 to 100.0', () {
      final m = makeMapping(confidence: 1.0);
      expect(m.confidencePercent, equals(100.0));
    });

    test('converts 0.92 to 92.0', () {
      final m = makeMapping(confidence: 0.92);
      expect(m.confidencePercent, closeTo(92.0, 0.001));
    });
  });

  // ---------------------------------------------------------------------------
  // confidenceTier
  // ---------------------------------------------------------------------------

  group('confidenceTier', () {
    test('excellent for confidence >= 0.90', () {
      expect(makeMapping(confidence: 0.95).confidenceTier, ConfidenceTier.excellent);
      expect(makeMapping(confidence: 0.90).confidenceTier, ConfidenceTier.excellent);
    });

    test('good for confidence in [0.80, 0.90)', () {
      expect(makeMapping(confidence: 0.85).confidenceTier, ConfidenceTier.good);
      expect(makeMapping(confidence: 0.80).confidenceTier, ConfidenceTier.good);
    });

    test('fair for confidence in [0.70, 0.80)', () {
      expect(makeMapping(confidence: 0.75).confidenceTier, ConfidenceTier.fair);
      expect(makeMapping(confidence: 0.70).confidenceTier, ConfidenceTier.fair);
    });

    test('low for confidence in [0.60, 0.70)', () {
      expect(makeMapping(confidence: 0.65).confidenceTier, ConfidenceTier.low);
      expect(makeMapping(confidence: 0.60).confidenceTier, ConfidenceTier.low);
    });

    test('veryLow for confidence < 0.60', () {
      expect(makeMapping(confidence: 0.55).confidenceTier, ConfidenceTier.veryLow);
      expect(makeMapping(confidence: 0.0).confidenceTier, ConfidenceTier.veryLow);
    });
  });

  // ---------------------------------------------------------------------------
  // getStatusLabel
  // ---------------------------------------------------------------------------

  group('getStatusLabel', () {
    test('auto returns Automatico for it locale', () {
      final m = makeMapping(status: MappingStatus.auto);
      expect(m.getStatusLabel('it'), equals('Automatico'));
    });

    test('auto returns Auto for en locale', () {
      final m = makeMapping(status: MappingStatus.auto);
      expect(m.getStatusLabel('en'), equals('Auto'));
    });

    test('review returns Da Verificare for it', () {
      final m = makeMapping(status: MappingStatus.review, confidence: 0.70);
      expect(m.getStatusLabel('it'), equals('Da Verificare'));
    });

    test('fallback returns Default for it', () {
      final m = makeMapping(
        status: MappingStatus.fallback,
        confidence: 0.40,
        standardId: null,
      );
      expect(m.getStatusLabel('it'), equals('Default'));
      expect(m.getStatusLabel('en'), equals('Fallback'));
    });

    test('verified returns Verificato for it', () {
      final m = makeMapping(status: MappingStatus.verified);
      expect(m.getStatusLabel('it'), equals('Verificato'));
      expect(m.getStatusLabel('en'), equals('Verified'));
    });
  });

  // ---------------------------------------------------------------------------
  // JSON round-trip
  // ---------------------------------------------------------------------------

  group('ExerciseMapping - JSON round-trip', () {
    test('serialises and deserialises auto mapping', () {
      final original = makeMapping();

      final json = original.toJson();
      final restored = ExerciseMapping.fromJson(json);

      expect(restored.gymbroId, equals(original.gymbroId));
      expect(restored.gymbroName, equals(original.gymbroName));
      expect(restored.gymbroEquipment, equals(original.gymbroEquipment));
      expect(restored.gymbroFocus, equals(original.gymbroFocus));
      expect(restored.confidence, equals(original.confidence));
      expect(restored.status, equals(MappingStatus.auto));
      expect(restored.standardId, equals(original.standardId));
      expect(restored.standardName, equals(original.standardName));
      expect(restored.dataSource, equals(original.dataSource));
    });

    test('serialises fallback mapping correctly', () {
      final original = ExerciseMapping(
        gymbroId: 'ex-fallback',
        gymbroName: 'Unknown Exercise',
        gymbroEquipment: 'Macchina',
        confidence: 0.35,
        status: MappingStatus.fallback,
        fallbackReason: 'No semantic match found above threshold',
      );

      final json = original.toJson();
      final restored = ExerciseMapping.fromJson(json);

      expect(restored.status, equals(MappingStatus.fallback));
      expect(restored.standardId, isNull);
      expect(restored.fallbackReason, equals('No semantic match found above threshold'));
    });

    test('serialises verified mapping correctly', () {
      final original = makeMapping(status: MappingStatus.verified);

      final json = original.toJson();
      final restored = ExerciseMapping.fromJson(json);

      expect(restored.status, equals(MappingStatus.verified));
    });

    test('handles null gymbroFocus', () {
      final original = ExerciseMapping(
        gymbroId: 'ex-nofocus',
        gymbroName: 'Exercise',
        gymbroEquipment: 'Bilanciere',
        confidence: 0.88,
        status: MappingStatus.auto,
      );

      final json = original.toJson();
      final restored = ExerciseMapping.fromJson(json);

      expect(restored.gymbroFocus, isNull);
    });

    test('round-trips all MappingStatus values', () {
      for (final status in MappingStatus.values) {
        final original = ExerciseMapping(
          gymbroId: 'ex-${status.name}',
          gymbroName: 'Test Exercise',
          gymbroEquipment: 'Bilanciere',
          confidence: status == MappingStatus.fallback ? 0.40 : 0.85,
          status: status,
          fallbackReason: status == MappingStatus.fallback ? 'no match' : null,
        );

        final json = original.toJson();
        final restored = ExerciseMapping.fromJson(json);

        expect(restored.status, equals(status));
      }
    });
  });

  // ---------------------------------------------------------------------------
  // Construction and equality
  // ---------------------------------------------------------------------------

  group('ExerciseMapping - equality', () {
    test('two identical mappings are equal', () {
      final a = makeMapping();
      final b = makeMapping();
      expect(a, equals(b));
    });

    test('different gymbroId makes mappings unequal', () {
      final a = makeMapping(gymbroId: 'ex-001');
      final b = makeMapping(gymbroId: 'ex-002');
      expect(a, isNot(equals(b)));
    });
  });

  group('ExerciseMapping - copyWith', () {
    test('updates confidence field', () {
      final original = makeMapping(confidence: 0.92);
      final updated = original.copyWith(confidence: 0.75);

      expect(updated.confidence, equals(0.75));
      expect(updated.gymbroId, equals(original.gymbroId));
    });

    test('updates status field', () {
      final original = makeMapping(status: MappingStatus.auto);
      final updated = original.copyWith(status: MappingStatus.verified);

      expect(updated.status, equals(MappingStatus.verified));
      expect(original.status, equals(MappingStatus.auto)); // immutable
    });
  });
}
