/// DifficultyLevel unit tests.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/difficulty_level.dart';

void main() {
  group('DifficultyLevel.fromString', () {
    test('null returns null', () {
      expect(DifficultyLevel.fromString(null), isNull);
    });

    test('empty returns null', () {
      expect(DifficultyLevel.fromString(''), isNull);
    });

    test('unknown returns null', () {
      expect(DifficultyLevel.fromString('godlike'), isNull);
    });

    test('beginner (English)', () {
      expect(DifficultyLevel.fromString('beginner'), DifficultyLevel.beginner);
    });

    test('principiante (Italian)', () {
      expect(DifficultyLevel.fromString('principiante'),
          DifficultyLevel.beginner);
    });

    test('intermediate', () {
      expect(DifficultyLevel.fromString('intermediate'),
          DifficultyLevel.intermediate);
    });

    test('intermedio', () {
      expect(DifficultyLevel.fromString('intermedio'),
          DifficultyLevel.intermediate);
    });

    test('advanced', () {
      expect(DifficultyLevel.fromString('advanced'), DifficultyLevel.advanced);
    });

    test('avanzato', () {
      expect(
          DifficultyLevel.fromString('avanzato'), DifficultyLevel.advanced);
    });

    test('expert', () {
      expect(DifficultyLevel.fromString('expert'), DifficultyLevel.expert);
    });

    test('esperto', () {
      expect(DifficultyLevel.fromString('esperto'), DifficultyLevel.expert);
    });

    test('case insensitive', () {
      expect(
          DifficultyLevel.fromString('ADVANCED'), DifficultyLevel.advanced);
    });

    test('trims whitespace', () {
      expect(DifficultyLevel.fromString('  expert  '), DifficultyLevel.expert);
    });
  });

  group('DifficultyLevel - badgeColor', () {
    test('beginner has different dark/light colors', () {
      final dark = DifficultyLevel.beginner.badgeColor(true);
      final light = DifficultyLevel.beginner.badgeColor(false);
      expect(dark, isNot(equals(light)));
    });

    test('intermediate has different dark/light colors', () {
      final dark = DifficultyLevel.intermediate.badgeColor(true);
      final light = DifficultyLevel.intermediate.badgeColor(false);
      expect(dark, isNot(equals(light)));
    });

    test('advanced has different dark/light colors', () {
      final dark = DifficultyLevel.advanced.badgeColor(true);
      final light = DifficultyLevel.advanced.badgeColor(false);
      expect(dark, isNot(equals(light)));
    });

    test('expert has different dark/light colors', () {
      final dark = DifficultyLevel.expert.badgeColor(true);
      final light = DifficultyLevel.expert.badgeColor(false);
      expect(dark, isNot(equals(light)));
    });
  });

  group('DifficultyLevel - badgeColorWithOpacity', () {
    test('default opacity is 0.15', () {
      final color = DifficultyLevel.beginner.badgeColorWithOpacity(false);
      expect(color.a, closeTo(0.15, 0.01));
    });

    test('custom opacity', () {
      final color =
          DifficultyLevel.expert.badgeColorWithOpacity(true, opacity: 0.3);
      expect(color.a, closeTo(0.3, 0.01));
    });
  });

  group('DifficultyLevel values', () {
    test('has 4 values', () {
      expect(DifficultyLevel.values.length, 4);
    });

    test('ordering: beginner < intermediate < advanced < expert', () {
      expect(DifficultyLevel.beginner.index, 0);
      expect(DifficultyLevel.intermediate.index, 1);
      expect(DifficultyLevel.advanced.index, 2);
      expect(DifficultyLevel.expert.index, 3);
    });
  });
}
