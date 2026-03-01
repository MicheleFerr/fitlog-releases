/// ExperienceLevel entity tests - fromString parsing, emoji, suggestedExerciseCount.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/experience_level.dart';

void main() {
  group('ExperienceLevel', () {
    test('has 3 values', () {
      expect(ExperienceLevel.values.length, 3);
    });
  });

  group('ExperienceLevel.fromString', () {
    test('parses English names', () {
      expect(ExperienceLevel.fromString('beginner'), ExperienceLevel.beginner);
      expect(ExperienceLevel.fromString('intermediate'),
          ExperienceLevel.intermediate);
      expect(ExperienceLevel.fromString('advanced'), ExperienceLevel.advanced);
    });

    test('parses Italian names', () {
      expect(
          ExperienceLevel.fromString('principiante'), ExperienceLevel.beginner);
      expect(
          ExperienceLevel.fromString('intermedio'), ExperienceLevel.intermediate);
      expect(ExperienceLevel.fromString('avanzato'), ExperienceLevel.advanced);
    });

    test('case-insensitive', () {
      expect(ExperienceLevel.fromString('BEGINNER'), ExperienceLevel.beginner);
      expect(ExperienceLevel.fromString('Intermediate'),
          ExperienceLevel.intermediate);
    });

    test('trims whitespace', () {
      expect(ExperienceLevel.fromString('  beginner  '),
          ExperienceLevel.beginner);
    });

    test('returns null for invalid', () {
      expect(ExperienceLevel.fromString(null), isNull);
      expect(ExperienceLevel.fromString(''), isNull);
      expect(ExperienceLevel.fromString('unknown'), isNull);
    });
  });

  group('ExperienceLevel.emoji', () {
    test('each level has unique emoji', () {
      final emojis = ExperienceLevel.values.map((e) => e.emoji).toSet();
      expect(emojis.length, 3);
    });
  });

  group('ExperienceLevel.suggestedExerciseCount', () {
    test('beginner suggests 3', () {
      expect(ExperienceLevel.beginner.suggestedExerciseCount, 3);
    });

    test('intermediate suggests 4', () {
      expect(ExperienceLevel.intermediate.suggestedExerciseCount, 4);
    });

    test('advanced suggests 5', () {
      expect(ExperienceLevel.advanced.suggestedExerciseCount, 5);
    });
  });
}
