/// WorkoutTemplate entity tests - constructor, fromJson, toJson, copyWith, incrementUsage.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';

void main() {
  group('WorkoutTemplate', () {
    test('constructor with defaults', () {
      final template = WorkoutTemplate(name: 'Test', description: 'Desc');
      expect(template.id, isNotEmpty);
      expect(template.name, 'Test');
      expect(template.description, 'Desc');
      expect(template.exercises, isEmpty);
      expect(template.tags, isEmpty);
      expect(template.estimatedDuration, 45);
      expect(template.isCustom, true);
      expect(template.usageCount, 0);
      expect(template.isPublic, false);
      expect(template.downloadCount, 0);
      expect(template.averageRating, 0.0);
      expect(template.reviewCount, 0);
      expect(template.isAnonymous, false);
    });

    test('constructor with custom id', () {
      final template = WorkoutTemplate(
        id: 'custom-id',
        name: 'Test',
        description: 'Desc',
      );
      expect(template.id, 'custom-id');
    });

    test('fromJson minimal', () {
      final json = {
        'id': 'tmpl-1',
        'name': 'Push Day',
        'description': 'Upper push',
      };
      final template = WorkoutTemplate.fromJson(json);
      expect(template.id, 'tmpl-1');
      expect(template.name, 'Push Day');
      expect(template.description, 'Upper push');
      expect(template.exercises, isEmpty);
      expect(template.tags, isEmpty);
      expect(template.estimatedDuration, 45);
      expect(template.isCustom, true);
      expect(template.usageCount, 0);
    });

    test('fromJson full', () {
      final json = {
        'id': 'tmpl-1',
        'name': 'Push Day',
        'description': 'Chest focused',
        'imageUrl': 'https://example.com/img.jpg',
        'exercises': [
          {
            'exerciseId': 'ex-1',
            'exerciseName': 'Bench Press',
            'category': 'chest',
            'type': 'single',
            'sets': [
              {'setNumber': 1, 'targetWeight': 80.0, 'targetReps': 10}
            ],
          }
        ],
        'estimatedDuration': 60,
        'tags': ['push', 'chest'],
        'createdAt': '2024-01-01T10:00:00.000',
        'updatedAt': '2024-01-15T10:00:00.000',
        'isCustom': true,
        'usageCount': 5,
        'isPublic': true,
        'userId': 'user-1',
        'authorName': 'John',
        'downloadCount': 100,
        'averageRating': 4.5,
        'reviewCount': 20,
        'difficulty': 'intermediate',
        'category': 'strength',
        'defaultAutoAdjustmentType': 'rpe',
        'defaultApreProtocol': 3,
        'isAnonymous': false,
        'forkedFromTemplateId': 'original-1',
        'originalAuthorName': 'Jane',
      };
      final template = WorkoutTemplate.fromJson(json);
      expect(template.exercises.length, 1);
      expect(template.exercises[0].exerciseName, 'Bench Press');
      expect(template.exercises[0].sets.length, 1);
      expect(template.tags, ['push', 'chest']);
      expect(template.estimatedDuration, 60);
      expect(template.usageCount, 5);
      expect(template.isPublic, true);
      expect(template.authorName, 'John');
      expect(template.downloadCount, 100);
      expect(template.averageRating, 4.5);
      expect(template.reviewCount, 20);
      expect(template.difficulty, 'intermediate');
      expect(template.defaultAutoAdjustmentType, AutoAdjustmentType.rpe);
      expect(template.defaultApreProtocol, 3);
      expect(template.forkedFromTemplateId, 'original-1');
      expect(template.originalAuthorName, 'Jane');
    });

    test('fromJson skips malformed exercises', () {
      final json = {
        'name': 'Test',
        'description': 'Test',
        'exercises': [
          {'exerciseId': 'ex-1', 'exerciseName': 'Good', 'category': 'chest'},
          'not-a-map',
        ],
      };
      final template = WorkoutTemplate.fromJson(json);
      expect(template.exercises.length, 1);
    });

    test('fromJson with null exercises', () {
      final json = {
        'name': 'Test',
        'description': 'Test',
        'exercises': null,
      };
      final template = WorkoutTemplate.fromJson(json);
      expect(template.exercises, isEmpty);
    });

    test('fromJson with invalid autoAdjustmentType', () {
      final json = {
        'name': 'Test',
        'description': 'Test',
        'defaultAutoAdjustmentType': 'invalid',
      };
      final template = WorkoutTemplate.fromJson(json);
      expect(template.defaultAutoAdjustmentType, isNull);
    });

    test('toJson round-trip', () {
      final template = WorkoutTemplate(
        id: 'tmpl-1',
        name: 'Push',
        description: 'Desc',
        tags: ['push'],
        usageCount: 3,
        isPublic: true,
        authorName: 'John',
        forkedFromTemplateId: 'orig-1',
        originalAuthorName: 'Jane',
      );
      final json = template.toJson();
      expect(json['id'], 'tmpl-1');
      expect(json['name'], 'Push');
      expect(json['tags'], ['push']);
      expect(json['usageCount'], 3);
      expect(json['isPublic'], true);
      expect(json['forkedFromTemplateId'], 'orig-1');
      expect(json['originalAuthorName'], 'Jane');
    });

    test('copyWith', () {
      final original = WorkoutTemplate(name: 'A', description: 'B');
      final copy = original.copyWith(name: 'C', usageCount: 5);
      expect(copy.name, 'C');
      expect(copy.usageCount, 5);
      expect(copy.description, 'B');
    });

    test('incrementUsage', () {
      final template = WorkoutTemplate(name: 'A', description: 'B', usageCount: 3);
      final incremented = template.incrementUsage();
      expect(incremented.usageCount, 4);
      expect(incremented.name, 'A');
    });

    test('toWorkoutExercises', () {
      final template = WorkoutTemplate(
        name: 'Test',
        description: 'Test',
        exercises: [
          const ExerciseTemplate(
            exerciseId: 'ex-1',
            exerciseName: 'Bench',
            category: ExerciseCategory.chest,
            sets: [SetTemplate(setNumber: 1, targetWeight: 80.0, targetReps: 10)],
          ),
        ],
      );
      final exercises = template.toWorkoutExercises();
      expect(exercises.length, 1);
      expect(exercises[0].name, 'Bench');
      expect(exercises[0].sets.length, 1);
      expect(exercises[0].sets[0].weight, 80.0);
      expect(exercises[0].sets[0].reps, 10);
    });
  });

  group('ExerciseTemplate', () {
    test('constructor defaults', () {
      const et = ExerciseTemplate(
        exerciseId: 'ex-1',
        exerciseName: 'Bench',
        category: ExerciseCategory.chest,
      );
      expect(et.type, ExerciseType.single);
      expect(et.sets, isEmpty);
    });

    test('fromJson with old format', () {
      final json = {
        'id': 'old-id',
        'name': 'Old Name',
        'category': 'back',
      };
      final et = ExerciseTemplate.fromJson(json);
      expect(et.exerciseId, 'old-id');
      expect(et.exerciseName, 'Old Name');
      expect(et.category, ExerciseCategory.back);
    });

    test('fromJson with new format', () {
      final json = {
        'exerciseId': 'new-id',
        'exerciseName': 'New Name',
        'category': 'chest',
        'type': 'single',
      };
      final et = ExerciseTemplate.fromJson(json);
      expect(et.exerciseId, 'new-id');
      expect(et.exerciseName, 'New Name');
    });

    test('fromJson invalid category defaults to other', () {
      final json = {
        'exerciseId': 'x',
        'exerciseName': 'x',
        'category': 'invalid',
      };
      final et = ExerciseTemplate.fromJson(json);
      expect(et.category, ExerciseCategory.other);
    });

    test('fromJson invalid type defaults to single', () {
      final json = {
        'exerciseId': 'x',
        'exerciseName': 'x',
        'category': 'chest',
        'type': 'invalid',
      };
      final et = ExerciseTemplate.fromJson(json);
      expect(et.type, ExerciseType.single);
    });

    test('fromJson with sub-exercises', () {
      final json = {
        'exerciseId': 'super-1',
        'exerciseName': 'Superset',
        'category': 'chest',
        'type': 'superset',
        'exercises': [
          {'exerciseId': 'sub-1', 'exerciseName': 'Bench', 'category': 'chest'},
          {'exerciseId': 'sub-2', 'exerciseName': 'Fly', 'category': 'chest'},
        ],
      };
      final et = ExerciseTemplate.fromJson(json);
      expect(et.subExercises, isNotNull);
      expect(et.subExercises!.length, 2);
      expect(et.subExercises![0].exerciseName, 'Bench');
    });

    test('fromJson with restTime as double', () {
      final json = {
        'exerciseId': 'x',
        'exerciseName': 'x',
        'category': 'chest',
        'restTime': 90.0,
      };
      final et = ExerciseTemplate.fromJson(json);
      expect(et.restTime, 90);
    });

    test('copyWith', () {
      const original = ExerciseTemplate(
        exerciseId: 'ex-1',
        exerciseName: 'Bench',
        category: ExerciseCategory.chest,
        notes: 'old',
      );
      final copy = original.copyWith(notes: 'new');
      expect(copy.notes, 'new');
      expect(copy.exerciseId, 'ex-1');
    });

    test('toJson', () {
      const et = ExerciseTemplate(
        exerciseId: 'ex-1',
        exerciseName: 'Bench',
        category: ExerciseCategory.chest,
        type: ExerciseType.single,
        sets: [SetTemplate(setNumber: 1, targetWeight: 80.0)],
        notes: 'test',
        restTime: 90,
        tut: '3-1-2-0',
      );
      final json = et.toJson();
      expect(json['exerciseId'], 'ex-1');
      expect(json['category'], 'chest');
      expect(json['type'], 'single');
      expect(json['notes'], 'test');
      expect(json['restTime'], 90);
      expect(json['tut'], '3-1-2-0');
    });

    test('toWorkoutExercise creates standard Exercise', () {
      const et = ExerciseTemplate(
        exerciseId: 'ex-1',
        exerciseName: 'Curl',
        category: ExerciseCategory.arms,
        sets: [SetTemplate(setNumber: 1, targetWeight: 15.0, targetReps: 12)],
      );
      final exercise = et.toWorkoutExercise();
      expect(exercise, isA<Exercise>());
      expect(exercise.id, 'ex-1');
      expect(exercise.name, 'Curl');
      expect(exercise.category, ExerciseCategory.arms);
      expect(exercise.sets.length, 1);
      expect(exercise.sets[0].weight, 15.0);
      expect(exercise.sets[0].reps, 12);
    });

    test('toWorkoutExercise creates DropSetExercise', () {
      const et = ExerciseTemplate(
        exerciseId: 'ex-1',
        exerciseName: 'Drop Bench',
        category: ExerciseCategory.chest,
        type: ExerciseType.dropset,
        sets: [
          SetTemplate(setNumber: 1, targetWeight: 80.0, targetReps: 10),
          SetTemplate(setNumber: 2, targetWeight: 60.0, targetReps: 12),
        ],
      );
      final exercise = et.toWorkoutExercise();
      expect(exercise, isA<DropSetExercise>());
      final dropSet = exercise as DropSetExercise;
      expect(dropSet.stages.length, 2);
      expect(dropSet.stages[0].weight, 80.0);
      expect(dropSet.stages[1].weight, 60.0);
    });

    test('toWorkoutExercise creates RestPauseExercise', () {
      const et = ExerciseTemplate(
        exerciseId: 'ex-1',
        exerciseName: 'RP Curl',
        category: ExerciseCategory.arms,
        type: ExerciseType.restPause,
        sets: [
          SetTemplate(setNumber: 1, targetWeight: 20.0, targetReps: 10, restSeconds: 15),
          SetTemplate(setNumber: 2, targetWeight: 20.0, targetReps: 6, restSeconds: 15),
        ],
      );
      final exercise = et.toWorkoutExercise();
      expect(exercise, isA<RestPauseExercise>());
      final rp = exercise as RestPauseExercise;
      expect(rp.weight, 20.0);
      expect(rp.targetReps, 10);
      expect(rp.restPauseSets.length, 2);
      expect(rp.restPauseSets[0].restSeconds, 15);
    });

    test('toWorkoutExercise creates SupersetExercise', () {
      const et = ExerciseTemplate(
        exerciseId: 'super-1',
        exerciseName: 'Chest Superset',
        category: ExerciseCategory.chest,
        type: ExerciseType.superset,
        sets: [
          SetTemplate(setNumber: 1, targetWeight: 80.0, targetReps: 10),
        ],
        subExercises: [
          ExerciseTemplate(
            exerciseId: 'sub-1',
            exerciseName: 'Bench',
            category: ExerciseCategory.chest,
          ),
          ExerciseTemplate(
            exerciseId: 'sub-2',
            exerciseName: 'Fly',
            category: ExerciseCategory.chest,
          ),
        ],
      );
      final exercise = et.toWorkoutExercise();
      expect(exercise, isA<SupersetExercise>());
      final superset = exercise as SupersetExercise;
      expect(superset.exercises.length, 2);
      expect(superset.supersetSets.length, 1);
    });
  });

  group('SetTemplate', () {
    test('constructor', () {
      const st = SetTemplate(
        setNumber: 1,
        targetWeight: 80.0,
        targetReps: 10,
        targetMinReps: 8,
        targetMaxReps: 12,
        targetRpe: 8,
        targetSeconds: 60,
        restSeconds: 15,
        notes: 'test',
      );
      expect(st.setNumber, 1);
      expect(st.targetWeight, 80.0);
      expect(st.targetReps, 10);
      expect(st.targetMinReps, 8);
      expect(st.targetMaxReps, 12);
      expect(st.targetRpe, 8);
      expect(st.targetSeconds, 60);
      expect(st.restSeconds, 15);
      expect(st.notes, 'test');
    });

    test('fromJson with new format', () {
      final json = {
        'setNumber': 1,
        'targetWeight': 80.0,
        'targetReps': 10,
        'targetMinReps': 8,
        'targetMaxReps': 12,
        'targetRpe': 8,
        'targetSeconds': 60,
        'restSeconds': 15,
        'notes': 'test',
      };
      final st = SetTemplate.fromJson(json);
      expect(st.setNumber, 1);
      expect(st.targetWeight, 80.0);
      expect(st.targetReps, 10);
      expect(st.targetMinReps, 8);
      expect(st.targetMaxReps, 12);
      expect(st.targetRpe, 8);
      expect(st.targetSeconds, 60);
      expect(st.restSeconds, 15);
    });

    test('fromJson with old format fallback', () {
      final json = {
        'setNumber': 1,
        'weight': 80.0,
        'reps': 10,
        'rpe': 8,
        'seconds': 30,
        'minReps': 8,
        'maxReps': 12,
      };
      final st = SetTemplate.fromJson(json);
      expect(st.targetWeight, 80.0);
      expect(st.targetReps, 10);
      expect(st.targetRpe, 8);
      expect(st.targetSeconds, 30);
      expect(st.targetMinReps, 8);
      expect(st.targetMaxReps, 12);
    });

    test('fromJson handles string values', () {
      final json = {
        'setNumber': '2',
        'targetWeight': '75.5',
        'targetReps': '10',
        'targetRpe': '8',
      };
      final st = SetTemplate.fromJson(json);
      expect(st.setNumber, 2);
      expect(st.targetWeight, 75.5);
      expect(st.targetReps, 10);
      expect(st.targetRpe, 8);
    });

    test('hasRepRange', () {
      const range = SetTemplate(setNumber: 1, targetMinReps: 8, targetMaxReps: 12);
      expect(range.hasRepRange, true);

      const same = SetTemplate(setNumber: 1, targetMinReps: 10, targetMaxReps: 10);
      expect(same.hasRepRange, false);

      const none = SetTemplate(setNumber: 1);
      expect(none.hasRepRange, false);
    });

    test('repsDisplay', () {
      const range = SetTemplate(setNumber: 1, targetMinReps: 8, targetMaxReps: 12);
      expect(range.repsDisplay, '8-12');

      const single = SetTemplate(setNumber: 1, targetReps: 10);
      expect(single.repsDisplay, '10');

      const empty = SetTemplate(setNumber: 1);
      expect(empty.repsDisplay, '-');
    });

    test('toJson round-trip', () {
      const st = SetTemplate(
        setNumber: 1,
        targetWeight: 80.0,
        targetReps: 10,
        targetMinReps: 8,
        targetMaxReps: 12,
        restSeconds: 15,
      );
      final json = st.toJson();
      expect(json['setNumber'], 1);
      expect(json['targetWeight'], 80.0);
      expect(json['targetReps'], 10);
      expect(json['targetMinReps'], 8);
      expect(json['targetMaxReps'], 12);
      expect(json['restSeconds'], 15);
    });

    test('toExerciseSet', () {
      const st = SetTemplate(
        setNumber: 1,
        targetWeight: 80.0,
        targetReps: 10,
        targetMinReps: 8,
        targetMaxReps: 12,
        targetSeconds: 60,
        notes: 'test',
      );
      final set = st.toExerciseSet();
      expect(set.setNumber, 1);
      expect(set.weight, 80.0);
      expect(set.reps, 10);
      expect(set.minReps, 8);
      expect(set.maxReps, 12);
      expect(set.seconds, 60);
      expect(set.notes, 'test');
    });
  });
}
