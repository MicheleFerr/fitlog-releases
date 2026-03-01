/// ExperienceLevel unit tests.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/experience_level.dart';

void main() {
  group('ExperienceLevel.fromString', () {
    test('null returns null', () {
      expect(ExperienceLevel.fromString(null), isNull);
    });

    test('empty returns null', () {
      expect(ExperienceLevel.fromString(''), isNull);
    });

    test('unknown returns null', () {
      expect(ExperienceLevel.fromString('elite'), isNull);
    });

    test('beginner (English)', () {
      expect(ExperienceLevel.fromString('beginner'), ExperienceLevel.beginner);
    });

    test('principiante (Italian)', () {
      expect(ExperienceLevel.fromString('principiante'),
          ExperienceLevel.beginner);
    });

    test('intermediate (English)', () {
      expect(ExperienceLevel.fromString('intermediate'),
          ExperienceLevel.intermediate);
    });

    test('intermedio (Italian)', () {
      expect(ExperienceLevel.fromString('intermedio'),
          ExperienceLevel.intermediate);
    });

    test('advanced (English)', () {
      expect(ExperienceLevel.fromString('advanced'), ExperienceLevel.advanced);
    });

    test('avanzato (Italian)', () {
      expect(
          ExperienceLevel.fromString('avanzato'), ExperienceLevel.advanced);
    });

    test('case insensitive', () {
      expect(ExperienceLevel.fromString('BEGINNER'), ExperienceLevel.beginner);
      expect(ExperienceLevel.fromString('Intermediate'),
          ExperienceLevel.intermediate);
    });

    test('trims whitespace', () {
      expect(
          ExperienceLevel.fromString('  beginner  '), ExperienceLevel.beginner);
    });
  });

  group('ExperienceLevel - emoji', () {
    test('beginner emoji', () {
      expect(ExperienceLevel.beginner.emoji, '🌱');
    });

    test('intermediate emoji', () {
      expect(ExperienceLevel.intermediate.emoji, '💪');
    });

    test('advanced emoji', () {
      expect(ExperienceLevel.advanced.emoji, '🏆');
    });
  });

  group('ExperienceLevel - suggestedExerciseCount', () {
    test('beginner => 3', () {
      expect(ExperienceLevel.beginner.suggestedExerciseCount, 3);
    });

    test('intermediate => 4', () {
      expect(ExperienceLevel.intermediate.suggestedExerciseCount, 4);
    });

    test('advanced => 5', () {
      expect(ExperienceLevel.advanced.suggestedExerciseCount, 5);
    });
  });

  group('ExperienceLevel - badgeColor', () {
    test('beginner has different dark/light colors', () {
      final dark = ExperienceLevel.beginner.badgeColor(true);
      final light = ExperienceLevel.beginner.badgeColor(false);
      expect(dark, isNot(equals(light)));
    });

    test('intermediate has different dark/light colors', () {
      final dark = ExperienceLevel.intermediate.badgeColor(true);
      final light = ExperienceLevel.intermediate.badgeColor(false);
      expect(dark, isNot(equals(light)));
    });

    test('advanced has different dark/light colors', () {
      final dark = ExperienceLevel.advanced.badgeColor(true);
      final light = ExperienceLevel.advanced.badgeColor(false);
      expect(dark, isNot(equals(light)));
    });
  });

  group('ExperienceLevel - badgeColorWithOpacity', () {
    test('returns color with reduced opacity', () {
      final color = ExperienceLevel.beginner.badgeColorWithOpacity(false);
      expect(color.a, closeTo(0.15, 0.01));
    });

    test('custom opacity', () {
      final color =
          ExperienceLevel.advanced.badgeColorWithOpacity(true, opacity: 0.5);
      expect(color.a, closeTo(0.5, 0.01));
    });
  });

  group('ExperienceLevel values', () {
    test('has 3 values', () {
      expect(ExperienceLevel.values.length, 3);
    });
  });
}
