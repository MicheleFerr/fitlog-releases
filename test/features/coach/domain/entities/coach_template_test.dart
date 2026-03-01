/// CoachTemplate unit tests.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/coach/domain/entities/coach_template.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout_template.dart';

void main() {
  final now = DateTime(2024, 6, 15, 10, 0);

  ExerciseTemplate _makeExercise({String name = 'Bench Press'}) {
    return ExerciseTemplate(
      exerciseId: 'e-1',
      exerciseName: name,
      category: ExerciseCategory.chest,
      type: ExerciseType.single,
      sets: [
        SetTemplate(setNumber: 1, targetReps: 10),
        SetTemplate(setNumber: 2, targetReps: 10),
      ],
    );
  }

  CoachTemplate _make({
    List<ExerciseTemplate>? exercises,
    List<String> assignedTo = const [],
    bool isArchived = false,
  }) {
    return CoachTemplate(
      id: 't-1',
      coachId: 'coach-1',
      name: 'Push Day',
      exercises: exercises ?? [_makeExercise()],
      assignedTo: assignedTo,
      isArchived: isArchived,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('CoachTemplate - assignedCount', () {
    test('0 when no assignments', () {
      expect(_make().assignedCount, 0);
    });

    test('returns count of assigned athletes', () {
      expect(
        _make(assignedTo: ['a1', 'a2', 'a3']).assignedCount,
        3,
      );
    });
  });

  group('CoachTemplate - hasAssignments', () {
    test('false when no assignments', () {
      expect(_make().hasAssignments, false);
    });

    test('true when has assignments', () {
      expect(_make(assignedTo: ['a1']).hasAssignments, true);
    });
  });

  group('CoachTemplate - isAssignedTo', () {
    test('true when athlete is assigned', () {
      expect(_make(assignedTo: ['a1', 'a2']).isAssignedTo('a1'), true);
    });

    test('false when athlete not assigned', () {
      expect(_make(assignedTo: ['a1']).isAssignedTo('a3'), false);
    });

    test('false when no assignments', () {
      expect(_make().isAssignedTo('a1'), false);
    });
  });

  group('CoachTemplate - toWorkoutTemplate', () {
    test('converts to WorkoutTemplate correctly', () {
      final coach = _make(exercises: [_makeExercise(name: 'Squat')]);
      final wt = coach.toWorkoutTemplate();

      expect(wt.id, coach.id);
      expect(wt.name, coach.name);
      expect(wt.exercises.length, coach.exercises.length);
      expect(wt.isCustom, true);
      expect(wt.userId, coach.coachId);
      expect(wt.createdAt, coach.createdAt);
      expect(wt.updatedAt, coach.updatedAt);
    });

    test('handles null description', () {
      final coach = _make();
      final wt = coach.toWorkoutTemplate();
      expect(wt.description, '');
    });

    test('preserves estimatedDuration and tags', () {
      final coach = CoachTemplate(
        id: 't-1',
        coachId: 'c-1',
        name: 'Full Body',
        exercises: [],
        estimatedDuration: 60,
        tags: ['push', 'pull'],
        difficulty: 'advanced',
        createdAt: now,
        updatedAt: now,
      );
      final wt = coach.toWorkoutTemplate();
      expect(wt.estimatedDuration, 60);
      expect(wt.tags, ['push', 'pull']);
      expect(wt.difficulty, 'advanced');
    });
  });

  group('CoachTemplate.fromWorkoutTemplate', () {
    test('creates CoachTemplate from WorkoutTemplate', () {
      final wt = WorkoutTemplate(
        id: 'wt-1',
        name: 'Leg Day',
        description: 'Focus on quads',
        exercises: [_makeExercise(name: 'Squat')],
        estimatedDuration: 50,
        tags: ['legs'],
        difficulty: 'intermediate',
        createdAt: now,
        updatedAt: now,
        userId: 'u-1',
      );

      final ct = CoachTemplate.fromWorkoutTemplate(
        template: wt,
        coachId: 'coach-x',
      );

      expect(ct.id, wt.id);
      expect(ct.coachId, 'coach-x');
      expect(ct.name, wt.name);
      expect(ct.description, wt.description);
      expect(ct.exercises.length, wt.exercises.length);
      expect(ct.estimatedDuration, wt.estimatedDuration);
      expect(ct.tags, wt.tags);
      expect(ct.difficulty, wt.difficulty);
    });
  });

  group('ExerciseTemplateListConverter', () {
    test('fromJson converts list of maps to ExerciseTemplate list', () {
      const converter = ExerciseTemplateListConverter();
      final exercise = _makeExercise();
      final jsonList = [exercise.toJson()];

      final result = converter.fromJson(jsonList);
      expect(result.length, 1);
      expect(result.first.exerciseName, 'Bench Press');
    });

    test('toJson converts ExerciseTemplate list to list of maps', () {
      const converter = ExerciseTemplateListConverter();
      final exercises = [_makeExercise()];

      final result = converter.toJson(exercises);
      expect(result.length, 1);
      expect(result.first, isA<Map<String, dynamic>>());
    });
  });
}
