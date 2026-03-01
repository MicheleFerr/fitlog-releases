/// WorkoutTemplateExtensions unit tests.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/difficulty_level.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/template_category.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template_extensions.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout_template.dart';

void main() {
  ExerciseTemplate _makeExercise({
    ExerciseCategory category = ExerciseCategory.chest,
    int setCount = 3,
    ExerciseType type = ExerciseType.single,
    List<ExerciseTemplate>? subExercises,
  }) {
    return ExerciseTemplate(
      exerciseId: 'e-1',
      exerciseName: 'Test Exercise',
      category: category,
      type: type,
      sets: List.generate(
        setCount,
        (i) => SetTemplate(setNumber: i + 1, targetReps: 10),
      ),
      subExercises: subExercises,
    );
  }

  WorkoutTemplate _makeTemplate({
    List<ExerciseTemplate>? exercises,
    String? difficulty,
  }) {
    return WorkoutTemplate(
      id: 't-1',
      name: 'Test Template',
      description: '',
      exercises: exercises ?? [],
      createdAt: DateTime(2024, 6, 15),
      updatedAt: DateTime(2024, 6, 15),
      userId: 'u1',
      difficulty: difficulty,
    );
  }

  group('detectDifficulty', () {
    test('empty template => beginner', () {
      final t = _makeTemplate();
      expect(t.detectDifficulty(), DifficultyLevel.beginner);
    });

    test('3 exercises with 3 sets each (9 sets) => beginner', () {
      final t = _makeTemplate(exercises: [
        _makeExercise(setCount: 3),
        _makeExercise(setCount: 3),
        _makeExercise(setCount: 3),
      ]);
      expect(t.detectDifficulty(), DifficultyLevel.beginner);
    });

    test('4 exercises with 4 sets each (16 sets) => intermediate', () {
      final t = _makeTemplate(exercises: [
        _makeExercise(setCount: 4),
        _makeExercise(setCount: 4),
        _makeExercise(setCount: 4),
        _makeExercise(setCount: 4),
      ]);
      expect(t.detectDifficulty(), DifficultyLevel.intermediate);
    });

    test('6 exercises with 4 sets each (24 sets) => advanced', () {
      final t = _makeTemplate(exercises: [
        _makeExercise(setCount: 4),
        _makeExercise(setCount: 4),
        _makeExercise(setCount: 4),
        _makeExercise(setCount: 4),
        _makeExercise(setCount: 4),
        _makeExercise(setCount: 4),
      ]);
      expect(t.detectDifficulty(), DifficultyLevel.advanced);
    });

    test('10 exercises (9+ exercises) => expert by exercise count', () {
      final t = _makeTemplate(
        exercises: List.generate(10, (_) => _makeExercise(setCount: 2)),
      );
      expect(t.detectDifficulty(), DifficultyLevel.expert);
    });

    test('3 exercises with 11 sets each (33 sets) => expert by set count', () {
      final t = _makeTemplate(exercises: [
        _makeExercise(setCount: 11),
        _makeExercise(setCount: 11),
        _makeExercise(setCount: 11),
      ]);
      expect(t.detectDifficulty(), DifficultyLevel.expert);
    });

    test('counts superset sub-exercise sets', () {
      final t = _makeTemplate(exercises: [
        _makeExercise(
          type: ExerciseType.superset,
          setCount: 3,
          subExercises: [
            _makeExercise(setCount: 3),
          ],
        ),
        // 3 + 3 = 6 from superset, need more for intermediate
        _makeExercise(setCount: 4),
        _makeExercise(setCount: 4),
        _makeExercise(setCount: 4),
      ]);
      // 6 + 4 + 4 + 4 = 18 sets, 4 exercises => intermediate
      expect(t.detectDifficulty(), DifficultyLevel.intermediate);
    });
  });

  group('detectCategory', () {
    test('empty => hybrid', () {
      final t = _makeTemplate();
      expect(t.detectCategory(), TemplateCategory.hybrid);
    });

    test('all chest => strength', () {
      final t = _makeTemplate(exercises: [
        _makeExercise(category: ExerciseCategory.chest),
        _makeExercise(category: ExerciseCategory.chest),
        _makeExercise(category: ExerciseCategory.chest),
      ]);
      expect(t.detectCategory(), TemplateCategory.strength);
    });

    test('all cardio => cardio', () {
      final t = _makeTemplate(exercises: [
        _makeExercise(category: ExerciseCategory.cardio),
        _makeExercise(category: ExerciseCategory.cardio),
        _makeExercise(category: ExerciseCategory.cardio),
      ]);
      expect(t.detectCategory(), TemplateCategory.cardio);
    });

    test('all abs => flexibility', () {
      final t = _makeTemplate(exercises: [
        _makeExercise(category: ExerciseCategory.abs),
        _makeExercise(category: ExerciseCategory.abs),
        _makeExercise(category: ExerciseCategory.abs),
      ]);
      expect(t.detectCategory(), TemplateCategory.flexibility);
    });

    test('mixed categories => hybrid', () {
      final t = _makeTemplate(exercises: [
        _makeExercise(category: ExerciseCategory.chest),
        _makeExercise(category: ExerciseCategory.cardio),
        _makeExercise(category: ExerciseCategory.abs),
      ]);
      expect(t.detectCategory(), TemplateCategory.hybrid);
    });

    test('70% strength threshold', () {
      // 7 out of 10 exercises are strength
      final t = _makeTemplate(exercises: [
        _makeExercise(category: ExerciseCategory.chest),
        _makeExercise(category: ExerciseCategory.back),
        _makeExercise(category: ExerciseCategory.legs),
        _makeExercise(category: ExerciseCategory.shoulders),
        _makeExercise(category: ExerciseCategory.arms),
        _makeExercise(category: ExerciseCategory.chest),
        _makeExercise(category: ExerciseCategory.back),
        _makeExercise(category: ExerciseCategory.cardio),
        _makeExercise(category: ExerciseCategory.cardio),
        _makeExercise(category: ExerciseCategory.cardio),
      ]);
      expect(t.detectCategory(), TemplateCategory.strength);
    });
  });

  group('detectMuscleGroups', () {
    test('empty => empty list', () {
      final t = _makeTemplate();
      expect(t.detectMuscleGroups(), isEmpty);
    });

    test('excludes other and cardio', () {
      final t = _makeTemplate(exercises: [
        _makeExercise(category: ExerciseCategory.other),
        _makeExercise(category: ExerciseCategory.cardio),
        _makeExercise(category: ExerciseCategory.chest),
      ]);
      final groups = t.detectMuscleGroups();
      expect(groups, contains(ExerciseCategory.chest));
      expect(groups, isNot(contains(ExerciseCategory.other)));
      expect(groups, isNot(contains(ExerciseCategory.cardio)));
    });

    test('sorted by frequency', () {
      final t = _makeTemplate(exercises: [
        _makeExercise(category: ExerciseCategory.chest),
        _makeExercise(category: ExerciseCategory.chest),
        _makeExercise(category: ExerciseCategory.chest),
        _makeExercise(category: ExerciseCategory.back),
        _makeExercise(category: ExerciseCategory.shoulders),
      ]);
      final groups = t.detectMuscleGroups();
      expect(groups.first, ExerciseCategory.chest);
    });
  });

  group('effectiveDifficulty', () {
    test('uses manual difficulty when set', () {
      final t = _makeTemplate(
        difficulty: 'advanced',
        exercises: [_makeExercise(setCount: 3)],
      );
      expect(t.effectiveDifficulty, DifficultyLevel.advanced);
    });

    test('auto-detects when no manual difficulty', () {
      final t = _makeTemplate(
        difficulty: null,
        exercises: [_makeExercise(setCount: 3)],
      );
      expect(t.effectiveDifficulty, DifficultyLevel.beginner);
    });
  });

  group('effectiveCategory', () {
    test('returns auto-detected category', () {
      final t = _makeTemplate(exercises: [
        _makeExercise(category: ExerciseCategory.cardio),
        _makeExercise(category: ExerciseCategory.cardio),
        _makeExercise(category: ExerciseCategory.cardio),
      ]);
      expect(t.effectiveCategory, TemplateCategory.cardio);
    });
  });

  group('effectiveMuscleGroups', () {
    test('returns auto-detected muscle groups', () {
      final t = _makeTemplate(exercises: [
        _makeExercise(category: ExerciseCategory.chest),
        _makeExercise(category: ExerciseCategory.back),
      ]);
      expect(t.effectiveMuscleGroups, hasLength(2));
    });
  });
}
