import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/predictive_balance/domain/entities/weekly_pattern.dart';
import 'package:gymbro_flutter_new/features/predictive_balance/domain/entities/workout_fingerprint.dart';

void main() {
  group('WeeklyPattern', () {
    WeeklyPattern createPattern({
      List<WorkoutFingerprint>? cycle,
      double confidence = 0.75,
      int weeksAnalyzed = 3,
      int weeksMatched = 2,
      DateTime? analyzedAt,
      int avgWorkoutsPerWeek = 3,
    }) {
      return WeeklyPattern(
        cycle: cycle ??
            [
              const WorkoutFingerprint(
                id: 'push1',
                templateName: 'Push',
                dominantMuscles: ['chest', 'shoulders', 'triceps'],
                category: WorkoutCategory.push,
                totalVolume: 5000.0,
              ),
              const WorkoutFingerprint(
                id: 'pull1',
                templateName: 'Pull',
                dominantMuscles: ['back', 'biceps'],
                category: WorkoutCategory.pull,
                totalVolume: 4500.0,
              ),
              const WorkoutFingerprint(
                id: 'legs1',
                templateName: 'Legs',
                dominantMuscles: ['quadriceps', 'hamstrings', 'glutes'],
                category: WorkoutCategory.legs,
                totalVolume: 6000.0,
              ),
            ],
        confidence: confidence,
        weeksAnalyzed: weeksAnalyzed,
        weeksMatched: weeksMatched,
        analyzedAt: analyzedAt ?? DateTime.now(),
        avgWorkoutsPerWeek: avgWorkoutsPerWeek,
      );
    }

    group('isValid', () {
      test('should return true when confidence >= 0.66', () {
        final pattern = createPattern(confidence: 0.66);
        expect(pattern.isValid, isTrue);
      });

      test('should return true when confidence > 0.66', () {
        final pattern = createPattern(confidence: 0.80);
        expect(pattern.isValid, isTrue);
      });

      test('should return false when confidence < 0.66', () {
        final pattern = createPattern(confidence: 0.65);
        expect(pattern.isValid, isFalse);
      });

      test('should return false when confidence is very low', () {
        final pattern = createPattern(confidence: 0.33);
        expect(pattern.isValid, isFalse);
      });
    });

    group('isStrong', () {
      test('should return true when confidence >= 0.80', () {
        final pattern = createPattern(confidence: 0.80);
        expect(pattern.isStrong, isTrue);
      });

      test('should return true when confidence > 0.80', () {
        final pattern = createPattern(confidence: 0.95);
        expect(pattern.isStrong, isTrue);
      });

      test('should return false when confidence < 0.80', () {
        final pattern = createPattern(confidence: 0.79);
        expect(pattern.isStrong, isFalse);
      });
    });

    group('cycleLength', () {
      test('should return number of items in cycle', () {
        final pattern = createPattern();
        expect(pattern.cycleLength, equals(3));
      });

      test('should return 0 for empty cycle', () {
        final pattern = createPattern(cycle: []);
        expect(pattern.cycleLength, equals(0));
      });

      test('should return 1 for single item cycle', () {
        final pattern = createPattern(cycle: [
          const WorkoutFingerprint(
            id: 'push1',
            dominantMuscles: ['chest', 'shoulders'],
            category: WorkoutCategory.push,
            totalVolume: 5000.0,
          ),
        ]);
        expect(pattern.cycleLength, equals(1));
      });
    });

    group('isStale', () {
      test('should return false when analyzed within 7 days', () {
        final pattern = createPattern(
          analyzedAt: DateTime.now().subtract(const Duration(days: 5)),
        );
        expect(pattern.isStale, isFalse);
      });

      test('should return false when analyzed exactly 7 days ago', () {
        final pattern = createPattern(
          analyzedAt: DateTime.now().subtract(const Duration(days: 7)),
        );
        expect(pattern.isStale, isFalse);
      });

      test('should return true when analyzed more than 7 days ago', () {
        final pattern = createPattern(
          analyzedAt: DateTime.now().subtract(const Duration(days: 8)),
        );
        expect(pattern.isStale, isTrue);
      });

      test('should return true when analyzed long ago', () {
        final pattern = createPattern(
          analyzedAt: DateTime.now().subtract(const Duration(days: 30)),
        );
        expect(pattern.isStale, isTrue);
      });
    });

    group('allMusclesCovered', () {
      test('should return all unique muscles from cycle', () {
        final pattern = createPattern();
        final muscles = pattern.allMusclesCovered;

        expect(muscles, contains('chest'));
        expect(muscles, contains('shoulders'));
        expect(muscles, contains('triceps'));
        expect(muscles, contains('back'));
        expect(muscles, contains('biceps'));
        expect(muscles, contains('quadriceps'));
        expect(muscles, contains('hamstrings'));
        expect(muscles, contains('glutes'));
      });

      test('should deduplicate muscles', () {
        final pattern = createPattern(cycle: [
          const WorkoutFingerprint(
            id: 'push1',
            dominantMuscles: ['chest', 'shoulders', 'triceps'],
            category: WorkoutCategory.push,
            totalVolume: 5000.0,
          ),
          const WorkoutFingerprint(
            id: 'upper1',
            dominantMuscles: ['chest', 'back', 'shoulders'],
            category: WorkoutCategory.upper,
            totalVolume: 5500.0,
          ),
        ]);

        final muscles = pattern.allMusclesCovered;

        // chest and shoulders appear twice but should only be in set once
        expect(muscles.length, equals(4)); // chest, shoulders, triceps, back
      });

      test('should return empty set for empty cycle', () {
        final pattern = createPattern(cycle: []);
        expect(pattern.allMusclesCovered, isEmpty);
      });
    });

    group('description', () {
      test('should return formatted pattern description', () {
        final pattern = createPattern();
        expect(
          pattern.description,
          equals('Push \u2192 Pull \u2192 Legs (3 workouts/week)'),
        );
      });

      test('should work with single workout cycle', () {
        final pattern = createPattern(cycle: [
          const WorkoutFingerprint(
            id: 'push1',
            templateName: 'Push Day',
            dominantMuscles: ['chest', 'shoulders'],
            category: WorkoutCategory.push,
            totalVolume: 5000.0,
          ),
        ]);

        expect(pattern.description, equals('Push Day (1 workouts/week)'));
      });

      test('should use category name when template name is missing', () {
        final pattern = createPattern(cycle: [
          const WorkoutFingerprint(
            id: 'push1',
            dominantMuscles: ['chest', 'shoulders'],
            category: WorkoutCategory.push,
            totalVolume: 5000.0,
          ),
          const WorkoutFingerprint(
            id: 'pull1',
            dominantMuscles: ['back', 'biceps'],
            category: WorkoutCategory.pull,
            totalVolume: 4500.0,
          ),
        ]);

        expect(pattern.description, equals('push \u2192 pull (2 workouts/week)'));
      });
    });

    group('JSON serialization', () {
      test('should serialize to JSON and back', () {
        final original = createPattern();
        final json = original.toJson();
        final restored = WeeklyPattern.fromJson(json);

        expect(restored.confidence, equals(original.confidence));
        expect(restored.weeksAnalyzed, equals(original.weeksAnalyzed));
        expect(restored.weeksMatched, equals(original.weeksMatched));
        expect(restored.avgWorkoutsPerWeek, equals(original.avgWorkoutsPerWeek));
        expect(restored.cycleLength, equals(original.cycleLength));
      });
    });
  });
}
