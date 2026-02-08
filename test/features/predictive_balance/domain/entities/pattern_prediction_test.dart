import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/predictive_balance/domain/entities/pattern_prediction.dart';
import 'package:gymbro_flutter_new/features/predictive_balance/domain/entities/workout_fingerprint.dart';

void main() {
  group('PatternPrediction', () {
    PatternPrediction createPrediction({
      WorkoutFingerprint? missing,
      List<String>? musclesCovered,
      String? suggestedTemplateId,
      String? suggestedTemplateName,
      int missingCount = 1,
      double patternConfidence = 0.75,
    }) {
      return PatternPrediction(
        missing: missing ??
            const WorkoutFingerprint(
              id: 'legs1',
              templateName: 'Leg Day',
              dominantMuscles: ['quadriceps', 'hamstrings', 'glutes'],
              category: WorkoutCategory.legs,
              totalVolume: 6000.0,
            ),
        musclesCovered:
            musclesCovered ?? ['quadriceps', 'hamstrings', 'glutes'],
        suggestedTemplateId: suggestedTemplateId,
        suggestedTemplateName: suggestedTemplateName,
        missingCount: missingCount,
        patternConfidence: patternConfidence,
      );
    }

    group('displayName', () {
      test('should return suggestedTemplateName when available', () {
        final prediction = createPrediction(
          suggestedTemplateName: 'My Custom Leg Day',
        );
        expect(prediction.displayName, equals('My Custom Leg Day'));
      });

      test('should fall back to missing fingerprint displayName', () {
        final prediction = createPrediction(
          suggestedTemplateName: null,
        );
        expect(prediction.displayName, equals('Leg Day'));
      });

      test('should use fingerprint category when no template names', () {
        final prediction = createPrediction(
          missing: const WorkoutFingerprint(
            id: 'legs1',
            dominantMuscles: ['quadriceps', 'hamstrings', 'glutes'],
            category: WorkoutCategory.legs,
            totalVolume: 6000.0,
          ),
          suggestedTemplateName: null,
        );
        expect(prediction.displayName, equals('legs'));
      });
    });

    group('hasTemplate', () {
      test('should return true when suggestedTemplateId is set', () {
        final prediction = createPrediction(
          suggestedTemplateId: 'template-123',
        );
        expect(prediction.hasTemplate, isTrue);
      });

      test('should return false when suggestedTemplateId is null', () {
        final prediction = createPrediction(
          suggestedTemplateId: null,
        );
        expect(prediction.hasTemplate, isFalse);
      });
    });

    group('resolvesMuscle', () {
      test('should return true for muscle in musclesCovered', () {
        final prediction = createPrediction(
          musclesCovered: ['quadriceps', 'hamstrings', 'glutes'],
        );

        expect(prediction.resolvesMuscle('quadriceps'), isTrue);
        expect(prediction.resolvesMuscle('hamstrings'), isTrue);
        expect(prediction.resolvesMuscle('glutes'), isTrue);
      });

      test('should return false for muscle not in musclesCovered', () {
        final prediction = createPrediction(
          musclesCovered: ['quadriceps', 'hamstrings', 'glutes'],
        );

        expect(prediction.resolvesMuscle('chest'), isFalse);
        expect(prediction.resolvesMuscle('back'), isFalse);
        expect(prediction.resolvesMuscle('biceps'), isFalse);
      });

      test('should be case-insensitive', () {
        final prediction = createPrediction(
          musclesCovered: ['quadriceps', 'hamstrings', 'glutes'],
        );

        expect(prediction.resolvesMuscle('QUADRICEPS'), isTrue);
        expect(prediction.resolvesMuscle('Hamstrings'), isTrue);
        expect(prediction.resolvesMuscle('GLUTES'), isTrue);
      });

      test('should handle mixed case in musclesCovered', () {
        final prediction = createPrediction(
          musclesCovered: ['Quadriceps', 'HAMSTRINGS', 'Glutes'],
        );

        expect(prediction.resolvesMuscle('quadriceps'), isTrue);
        expect(prediction.resolvesMuscle('hamstrings'), isTrue);
        expect(prediction.resolvesMuscle('glutes'), isTrue);
      });

      test('should return false for empty musclesCovered', () {
        final prediction = createPrediction(
          musclesCovered: [],
        );

        expect(prediction.resolvesMuscle('quadriceps'), isFalse);
      });
    });

    group('missingCount', () {
      test('should default to 1', () {
        final prediction = createPrediction();
        expect(prediction.missingCount, equals(1));
      });

      test('should store custom value', () {
        final prediction = createPrediction(missingCount: 2);
        expect(prediction.missingCount, equals(2));
      });
    });

    group('patternConfidence', () {
      test('should store confidence value', () {
        final prediction = createPrediction(patternConfidence: 0.85);
        expect(prediction.patternConfidence, equals(0.85));
      });
    });

    group('JSON serialization', () {
      test('should serialize to JSON and back', () {
        final original = createPrediction(
          suggestedTemplateId: 'template-123',
          suggestedTemplateName: 'My Leg Day',
          missingCount: 2,
          patternConfidence: 0.80,
        );

        final json = original.toJson();
        final restored = PatternPrediction.fromJson(json);

        expect(restored.displayName, equals(original.displayName));
        expect(restored.hasTemplate, equals(original.hasTemplate));
        expect(restored.suggestedTemplateId, equals(original.suggestedTemplateId));
        expect(restored.missingCount, equals(original.missingCount));
        expect(restored.patternConfidence, equals(original.patternConfidence));
        expect(restored.musclesCovered, equals(original.musclesCovered));
      });

      test('should handle null optional fields', () {
        final original = createPrediction(
          suggestedTemplateId: null,
          suggestedTemplateName: null,
        );

        final json = original.toJson();
        final restored = PatternPrediction.fromJson(json);

        expect(restored.suggestedTemplateId, isNull);
        expect(restored.suggestedTemplateName, isNull);
        expect(restored.hasTemplate, isFalse);
      });
    });
  });
}
