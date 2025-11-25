import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_template.dart';

void main() {
  group('ExerciseTemplate', () {
    test('should create template with default sets and reps', () {
      const template = ExerciseTemplate(
        exerciseName: 'Squat',
        defaultWeight: 80.0,
        defaultReps: 5,
        defaultSets: 5,
      );

      expect(template.exerciseName, 'Squat');
      expect(template.defaultWeight, 80.0);
      expect(template.defaultReps, 5);
      expect(template.defaultSets, 5);
    });

    test('should apply template to create exercise sets', () {
      const template = ExerciseTemplate(
        exerciseName: 'Bench Press',
        defaultWeight: 60.0,
        defaultReps: 8,
        defaultSets: 4,
      );

      final sets = template.createSets();

      expect(sets.length, 4);
      expect(sets.first.weight, 60.0);
      expect(sets.first.reps, 8);
      expect(sets.first.isCompleted, false);
      expect(sets.first.isWarmup, false);
    });

    test('should create sets with sequential set numbers', () {
      const template = ExerciseTemplate(
        exerciseName: 'Deadlift',
        defaultWeight: 100.0,
        defaultReps: 5,
        defaultSets: 3,
      );

      final sets = template.createSets();

      expect(sets[0].setNumber, 1);
      expect(sets[1].setNumber, 2);
      expect(sets[2].setNumber, 3);
    });
  });
}
