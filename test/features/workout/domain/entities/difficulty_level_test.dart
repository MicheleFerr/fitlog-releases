/// DifficultyLevel entity tests - fromString parsing, enum values.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/difficulty_level.dart';

void main() {
  group('DifficultyLevel', () {
    test('has 4 values', () {
      expect(DifficultyLevel.values.length, 4);
    });
  });

  group('DifficultyLevel.fromString', () {
    test('parses English names', () {
      expect(DifficultyLevel.fromString('beginner'), DifficultyLevel.beginner);
      expect(DifficultyLevel.fromString('intermediate'),
          DifficultyLevel.intermediate);
      expect(DifficultyLevel.fromString('advanced'), DifficultyLevel.advanced);
      expect(DifficultyLevel.fromString('expert'), DifficultyLevel.expert);
    });

    test('parses Italian names', () {
      expect(
          DifficultyLevel.fromString('principiante'), DifficultyLevel.beginner);
      expect(
          DifficultyLevel.fromString('intermedio'), DifficultyLevel.intermediate);
      expect(DifficultyLevel.fromString('avanzato'), DifficultyLevel.advanced);
      expect(DifficultyLevel.fromString('esperto'), DifficultyLevel.expert);
    });

    test('case-insensitive', () {
      expect(DifficultyLevel.fromString('BEGINNER'), DifficultyLevel.beginner);
      expect(
          DifficultyLevel.fromString('Expert'), DifficultyLevel.expert);
    });

    test('trims whitespace', () {
      expect(
          DifficultyLevel.fromString('  advanced  '), DifficultyLevel.advanced);
    });

    test('returns null for invalid', () {
      expect(DifficultyLevel.fromString(null), isNull);
      expect(DifficultyLevel.fromString(''), isNull);
      expect(DifficultyLevel.fromString('unknown'), isNull);
    });
  });
}
