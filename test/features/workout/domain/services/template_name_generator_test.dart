import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/template_name_generator.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';

void main() {
  group('TemplateNameGenerator', () {
    test('uses the first unique exercise names for the generated title', () {
      final exercises = [
        Exercise(
          name: 'Bench Press',
          type: ExerciseType.single,
          category: ExerciseCategory.other,
        ),
        Exercise(
          name: 'Incline Dumbbell Press',
          type: ExerciseType.single,
          category: ExerciseCategory.other,
        ),
        Exercise(
          name: 'Bench Press',
          type: ExerciseType.single,
          category: ExerciseCategory.other,
        ),
      ];

      final result = TemplateNameGenerator.generateFromExercises(exercises);

      expect(result, 'Bench Press + Incline Dumbbell Press');
    });

    test('removes advanced-technique suffixes from generated names', () {
      final result = TemplateNameGenerator.generateFromExerciseNames([
        'Lateral Raise - Drop Set',
        'Cable Row - Rest-Pause',
      ]);

      expect(result, 'Lateral Raise + Cable Row');
    });

    test('falls back when no exercise names are usable', () {
      final result = TemplateNameGenerator.generateFromExerciseNames(const [
        '   ',
        '',
      ], fallbackName: 'Template personalizzato');

      expect(result, 'Template personalizzato');
    });
  });
}
