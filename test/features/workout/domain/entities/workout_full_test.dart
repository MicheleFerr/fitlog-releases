import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';

void main() {
  group('💪 Workout Complete Tests', () {
    // Helper function to create test exercises
    Exercise createTestExercise({
      String? id,
      String name = 'Test Exercise',
      ExerciseType type = ExerciseType.single,
      ExerciseCategory category = ExerciseCategory.chest,
      List<ExerciseSet>? sets,
    }) {
      return Exercise(
        id: id,
        name: name,
        type: type,
        category: category,
        sets: sets ?? [
          ExerciseSet(
            setNumber: 1,
            weight: 50,
            reps: 10,
            isCompleted: true,
          ),
          ExerciseSet(
            setNumber: 2,
            weight: 50,
            reps: 10,
            isCompleted: false,
          ),
        ],
      );
    }

    group('✅ Constructor', () {
      test('creates workout with all parameters', () {
        final now = DateTime.now();
        final exercises = [
          createTestExercise(name: 'Bench Press'),
          createTestExercise(name: 'Squats'),
        ];
        
        final workout = Workout(
          id: 'workout-123',
          name: 'Morning Workout',
          exercises: exercises,
          status: WorkoutStatus.inProgress,
          startTime: now,
          endTime: now.add(const Duration(hours: 1)),
          notes: 'Great workout!',
          createdAt: now,
          updatedAt: now,
        );

        expect(workout.id, 'workout-123');
        expect(workout.name, 'Morning Workout');
        expect(workout.exercises.length, 2);
        expect(workout.status, WorkoutStatus.inProgress);
        expect(workout.startTime, now);
        expect(workout.endTime, now.add(const Duration(hours: 1)));
        expect(workout.notes, 'Great workout!');
        expect(workout.createdAt, now);
        expect(workout.updatedAt, now);
      });

      test('creates workout with default values', () {
        final workout = Workout(name: 'Test Workout');

        expect(workout.id, isNotEmpty);
        expect(workout.name, 'Test Workout');
        expect(workout.exercises, isEmpty);
        expect(workout.status, WorkoutStatus.planned);
        expect(workout.startTime, isNull);
        expect(workout.endTime, isNull);
        expect(workout.notes, isNull);
        expect(workout.createdAt, isNotNull);
        expect(workout.updatedAt, isNotNull);
      });

      test('auto-generates UUID when id is null', () {
        final workout1 = Workout(name: 'Workout 1');
        final workout2 = Workout(name: 'Workout 2');

        expect(workout1.id, isNotEmpty);
        expect(workout2.id, isNotEmpty);
        expect(workout1.id, isNot(equals(workout2.id)));
      });

      test('uses provided exercises list', () {
        final exercises = [
          createTestExercise(name: 'Pull-ups'),
          createTestExercise(name: 'Push-ups'),
        ];
        
        final workout = Workout(
          name: 'Bodyweight Workout',
          exercises: exercises,
        );

        expect(workout.exercises.length, 2);
        expect(workout.exercises[0].name, 'Pull-ups');
        expect(workout.exercises[1].name, 'Push-ups');
      });
    });

    group('📊 Computed Properties', () {
      test('duration calculation', () {
        final start = DateTime(2024, 1, 1, 10, 0);
        final end = DateTime(2024, 1, 1, 11, 30);
        
        final workout = Workout(
          name: 'Test',
          startTime: start,
          endTime: end,
        );

        expect(workout.duration, const Duration(hours: 1, minutes: 30));
      });

      test('duration with no start time', () {
        final workout = Workout(name: 'Test');
        expect(workout.duration, isNull);
      });

      test('duration with start time but no end time uses current time', () {
        final workout = Workout(
          name: 'Test',
          startTime: DateTime.now().subtract(const Duration(minutes: 30)),
        );

        expect(workout.duration, isNotNull);
        expect(workout.duration!.inMinutes, greaterThanOrEqualTo(29));
        expect(workout.duration!.inMinutes, lessThanOrEqualTo(31));
      });

      test('completedExercises count', () {
        final exercises = [
          Exercise(
            name: 'Exercise 1',
            type: ExerciseType.single,
            category: ExerciseCategory.chest,
            sets: [
              ExerciseSet(setNumber: 1, weight: 50, reps: 10, isCompleted: true),
              ExerciseSet(setNumber: 2, weight: 50, reps: 10, isCompleted: true),
            ],
          ),
          Exercise(
            name: 'Exercise 2',
            type: ExerciseType.single,
            category: ExerciseCategory.chest,
            sets: [
              ExerciseSet(setNumber: 1, weight: 50, reps: 10, isCompleted: true),
              ExerciseSet(setNumber: 2, weight: 50, reps: 10, isCompleted: false),
            ],
          ),
          Exercise(
            name: 'Exercise 3',
            type: ExerciseType.single,
            category: ExerciseCategory.chest,
            sets: [],
          ),
        ];

        final workout = Workout(name: 'Test', exercises: exercises);
        expect(workout.completedExercises, 1);
      });

      test('totalSets count', () {
        final exercises = [
          Exercise(
            name: 'Exercise 1',
            type: ExerciseType.single,
            category: ExerciseCategory.chest,
            sets: [
              ExerciseSet(setNumber: 1, weight: 50, reps: 10),
              ExerciseSet(setNumber: 2, weight: 50, reps: 10),
              ExerciseSet(setNumber: 3, weight: 50, reps: 10),
            ],
          ),
          Exercise(
            name: 'Exercise 2',
            type: ExerciseType.single,
            category: ExerciseCategory.back,
            sets: [
              ExerciseSet(setNumber: 1, weight: 30, reps: 12),
              ExerciseSet(setNumber: 2, weight: 30, reps: 12),
            ],
          ),
        ];

        final workout = Workout(name: 'Test', exercises: exercises);
        expect(workout.totalSets, 5);
      });

      test('completedSets count', () {
        final exercises = [
          Exercise(
            name: 'Exercise 1',
            type: ExerciseType.single,
            category: ExerciseCategory.chest,
            sets: [
              ExerciseSet(setNumber: 1, weight: 50, reps: 10, isCompleted: true),
              ExerciseSet(setNumber: 2, weight: 50, reps: 10, isCompleted: true),
              ExerciseSet(setNumber: 3, weight: 50, reps: 10, isCompleted: false),
            ],
          ),
          Exercise(
            name: 'Exercise 2',
            type: ExerciseType.single,
            category: ExerciseCategory.back,
            sets: [
              ExerciseSet(setNumber: 1, weight: 30, reps: 12, isCompleted: true),
              ExerciseSet(setNumber: 2, weight: 30, reps: 12, isCompleted: false),
            ],
          ),
        ];

        final workout = Workout(name: 'Test', exercises: exercises);
        expect(workout.completedSets, 3);
      });

      test('progressPercentage calculation', () {
        final exercises = [
          Exercise(
            name: 'Exercise 1',
            type: ExerciseType.single,
            category: ExerciseCategory.chest,
            sets: [
              ExerciseSet(setNumber: 1, weight: 50, reps: 10, isCompleted: true),
              ExerciseSet(setNumber: 2, weight: 50, reps: 10, isCompleted: true),
              ExerciseSet(setNumber: 3, weight: 50, reps: 10, isCompleted: false),
              ExerciseSet(setNumber: 4, weight: 50, reps: 10, isCompleted: false),
            ],
          ),
        ];

        final workout = Workout(name: 'Test', exercises: exercises);
        expect(workout.progressPercentage, 0.5);
      });

      test('progressPercentage with no sets', () {
        final workout = Workout(name: 'Test', exercises: []);
        expect(workout.progressPercentage, 0.0);
      });

      test('isActive property', () {
        final activeWorkout = Workout(
          name: 'Test',
          status: WorkoutStatus.inProgress,
        );
        expect(activeWorkout.isActive, true);

        final plannedWorkout = Workout(
          name: 'Test',
          status: WorkoutStatus.planned,
        );
        expect(plannedWorkout.isActive, false);
      });

      test('isCompleted property', () {
        final completedWorkout = Workout(
          name: 'Test',
          status: WorkoutStatus.completed,
        );
        expect(completedWorkout.isCompleted, true);

        final inProgressWorkout = Workout(
          name: 'Test',
          status: WorkoutStatus.inProgress,
        );
        expect(inProgressWorkout.isCompleted, false);
      });
    });

    group('🔄 State Transitions', () {
      test('startWorkout', () {
        final workout = Workout(name: 'Test');
        final started = workout.startWorkout();

        expect(started.status, WorkoutStatus.inProgress);
        expect(started.startTime, isNotNull);
        expect(started.updatedAt.isAfter(workout.updatedAt), true);
      });

      test('completeWorkout', () {
        final workout = Workout(
          name: 'Test',
          status: WorkoutStatus.inProgress,
        );
        final completed = workout.completeWorkout();

        expect(completed.status, WorkoutStatus.completed);
        expect(completed.endTime, isNotNull);
        expect(completed.updatedAt.isAfter(workout.updatedAt), true);
      });

      test('pauseWorkout', () {
        final workout = Workout(
          name: 'Test',
          status: WorkoutStatus.inProgress,
        );
        final paused = workout.pauseWorkout();

        expect(paused.status, WorkoutStatus.paused);
        expect(paused.updatedAt.isAfter(workout.updatedAt), true);
      });

      test('resumeWorkout', () {
        final workout = Workout(
          name: 'Test',
          status: WorkoutStatus.paused,
        );
        final resumed = workout.resumeWorkout();

        expect(resumed.status, WorkoutStatus.inProgress);
        expect(resumed.updatedAt.isAfter(workout.updatedAt), true);
      });
    });

    group('📝 Exercise Management', () {
      test('addExercise', () {
        final workout = Workout(
          name: 'Test',
          exercises: [createTestExercise(name: 'Exercise 1')],
        );
        
        final newExercise = createTestExercise(name: 'Exercise 2');
        final updated = workout.addExercise(newExercise);

        expect(updated.exercises.length, 2);
        expect(updated.exercises[1].name, 'Exercise 2');
        expect(updated.updatedAt.isAfter(workout.updatedAt), true);
      });

      test('removeExercise', () {
        final exercise1 = createTestExercise(id: 'ex-1', name: 'Exercise 1');
        final exercise2 = createTestExercise(id: 'ex-2', name: 'Exercise 2');
        final exercise3 = createTestExercise(id: 'ex-3', name: 'Exercise 3');
        
        final workout = Workout(
          name: 'Test',
          exercises: [exercise1, exercise2, exercise3],
        );
        
        final updated = workout.removeExercise('ex-2');

        expect(updated.exercises.length, 2);
        expect(updated.exercises[0].id, 'ex-1');
        expect(updated.exercises[1].id, 'ex-3');
        expect(updated.updatedAt.isAfter(workout.updatedAt), true);
      });

      test('removeExercise with non-existent id', () {
        final workout = Workout(
          name: 'Test',
          exercises: [createTestExercise(id: 'ex-1')],
        );
        
        final updated = workout.removeExercise('non-existent');

        expect(updated.exercises.length, 1);
      });

      test('updateExercise', () {
        final exercise1 = createTestExercise(id: 'ex-1', name: 'Exercise 1');
        final exercise2 = createTestExercise(id: 'ex-2', name: 'Exercise 2');
        
        final workout = Workout(
          name: 'Test',
          exercises: [exercise1, exercise2],
        );
        
        final updatedExercise = Exercise(
          id: 'ex-1',
          name: 'Updated Exercise',
          type: ExerciseType.single,
          category: ExerciseCategory.back,
          sets: [],
        );
        
        final updated = workout.updateExercise('ex-1', updatedExercise);

        expect(updated.exercises[0].name, 'Updated Exercise');
        expect(updated.exercises[0].category, ExerciseCategory.back);
        expect(updated.exercises[1].name, 'Exercise 2');
        expect(updated.updatedAt.isAfter(workout.updatedAt), true);
      });

      test('updateExercise with non-existent id', () {
        final exercise = createTestExercise(id: 'ex-1', name: 'Exercise 1');
        final workout = Workout(
          name: 'Test',
          exercises: [exercise],
        );
        
        final updatedExercise = Exercise(
          id: 'non-existent',
          name: 'Updated',
          type: ExerciseType.single,
          category: ExerciseCategory.back,
          sets: [],
        );
        
        final updated = workout.updateExercise('non-existent', updatedExercise);

        expect(updated.exercises.length, 1);
        expect(updated.exercises[0].name, 'Exercise 1');
      });
    });

    group('🔄 CopyWith', () {
      test('copyWith all fields', () {
        final now = DateTime.now();
        final original = Workout(
          name: 'Original',
          exercises: [],
          status: WorkoutStatus.planned,
        );
        
        final exercises = [createTestExercise()];
        final copied = original.copyWith(
          name: 'Updated',
          exercises: exercises,
          status: WorkoutStatus.inProgress,
          startTime: now,
          endTime: now.add(const Duration(hours: 1)),
          notes: 'Updated notes',
          updatedAt: now,
        );

        expect(copied.id, original.id);
        expect(copied.name, 'Updated');
        expect(copied.exercises, exercises);
        expect(copied.status, WorkoutStatus.inProgress);
        expect(copied.startTime, now);
        expect(copied.endTime, now.add(const Duration(hours: 1)));
        expect(copied.notes, 'Updated notes');
        expect(copied.updatedAt, now);
        expect(copied.createdAt, original.createdAt);
      });

      test('copyWith preserves original values', () {
        final original = Workout(
          name: 'Original',
          notes: 'Original notes',
        );
        
        final copied = original.copyWith(
          name: 'Updated',
        );

        expect(copied.name, 'Updated');
        expect(copied.notes, 'Original notes');
        expect(copied.exercises, original.exercises);
      });
    });

    group('📝 Serialization', () {
      test('toJson', () {
        final now = DateTime(2024, 1, 1, 10, 0);
        final exercises = [
          Exercise(
            id: 'ex-1',
            name: 'Bench Press',
            type: ExerciseType.single,
            category: ExerciseCategory.chest,
            sets: [
              ExerciseSet(setNumber: 1, weight: 50, reps: 10),
            ],
          ),
        ];
        
        final workout = Workout(
          id: 'workout-123',
          name: 'Morning Workout',
          exercises: exercises,
          status: WorkoutStatus.inProgress,
          startTime: now,
          endTime: now.add(const Duration(hours: 1)),
          notes: 'Great workout!',
          createdAt: now,
          updatedAt: now,
        );

        final json = workout.toJson();

        expect(json['id'], 'workout-123');
        expect(json['name'], 'Morning Workout');
        expect(json['exercises'], isA<List>());
        expect((json['exercises'] as List).length, 1);
        expect(json['status'], 'inProgress');
        expect(json['startTime'], now.toIso8601String());
        expect(json['endTime'], now.add(const Duration(hours: 1)).toIso8601String());
        expect(json['notes'], 'Great workout!');
        expect(json['createdAt'], now.toIso8601String());
        expect(json['updatedAt'], now.toIso8601String());
      });

      test('toJson with null fields', () {
        final now = DateTime(2024, 1, 1);
        final workout = Workout(
          name: 'Test',
          createdAt: now,
          updatedAt: now,
        );
        
        final json = workout.toJson();

        expect(json['startTime'], isNull);
        expect(json['endTime'], isNull);
        expect(json['notes'], isNull);
      });

      test('fromJson', () {
        final now = DateTime(2024, 1, 1, 10, 0);
        final json = {
          'id': 'workout-456',
          'name': 'Evening Workout',
          'exercises': [
            {
              'id': 'ex-1',
              'name': 'Squats',
              'type': 'single',
              'category': 'legs',
              'sets': [
                {
                  'setNumber': 1,
                  'weight': 100.0,
                  'reps': 8,
                  'isCompleted': true,
                },
              ],
              'notes': null,
              'restTime': 120,
              'createdAt': now.toIso8601String(),
              'updatedAt': now.toIso8601String(),
            },
          ],
          'status': 'completed',
          'startTime': now.toIso8601String(),
          'endTime': now.add(const Duration(hours: 1)).toIso8601String(),
          'notes': 'Good session',
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        };

        final workout = Workout.fromJson(json);

        expect(workout.id, 'workout-456');
        expect(workout.name, 'Evening Workout');
        expect(workout.exercises.length, 1);
        expect(workout.exercises[0].name, 'Squats');
        expect(workout.status, WorkoutStatus.completed);
        expect(workout.startTime, now);
        expect(workout.endTime, now.add(const Duration(hours: 1)));
        expect(workout.notes, 'Good session');
        expect(workout.createdAt, now);
        expect(workout.updatedAt, now);
      });

      test('fromJson with null fields', () {
        final now = DateTime(2024, 1, 1);
        final json = {
          'id': 'workout-789',
          'name': 'Basic Workout',
          'status': 'planned',
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        };

        final workout = Workout.fromJson(json);

        expect(workout.id, 'workout-789');
        expect(workout.name, 'Basic Workout');
        expect(workout.exercises, isEmpty);
        expect(workout.status, WorkoutStatus.planned);
        expect(workout.startTime, isNull);
        expect(workout.endTime, isNull);
        expect(workout.notes, isNull);
      });

      test('fromJson with invalid status', () {
        final now = DateTime(2024, 1, 1);
        final json = {
          'id': 'workout-invalid',
          'name': 'Test',
          'status': 'invalid_status',
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        };

        final workout = Workout.fromJson(json);
        expect(workout.status, WorkoutStatus.planned);
      });

      test('roundtrip serialization', () {
        final original = Workout(
          id: 'roundtrip-test',
          name: 'Roundtrip Workout',
          exercises: [
            Exercise(
              id: 'ex-rt',
              name: 'Test Exercise',
              type: ExerciseType.single,
              category: ExerciseCategory.chest,
              sets: [
                ExerciseSet(setNumber: 1, weight: 50, reps: 10),
              ],
            ),
          ],
          status: WorkoutStatus.inProgress,
          notes: 'Testing roundtrip',
        );

        final json = original.toJson();
        final deserialized = Workout.fromJson(json);

        expect(deserialized.id, original.id);
        expect(deserialized.name, original.name);
        expect(deserialized.exercises.length, original.exercises.length);
        expect(deserialized.status, original.status);
        expect(deserialized.notes, original.notes);
      });
    });

    group('🎯 WorkoutStatus Enum', () {
      test('all status values are unique', () {
        const statuses = WorkoutStatus.values;
        final uniqueStatuses = statuses.toSet();
        expect(uniqueStatuses.length, statuses.length);
      });

      test('status enum contains expected values', () {
        expect(WorkoutStatus.values, contains(WorkoutStatus.planned));
        expect(WorkoutStatus.values, contains(WorkoutStatus.inProgress));
        expect(WorkoutStatus.values, contains(WorkoutStatus.completed));
        expect(WorkoutStatus.values, contains(WorkoutStatus.paused));
      });
    });

    group('📚 WorkoutTemplate', () {
      test('exerciseDatabase contains all categories', () {
        expect(WorkoutTemplate.exerciseDatabase.containsKey(ExerciseCategory.chest), true);
        expect(WorkoutTemplate.exerciseDatabase.containsKey(ExerciseCategory.back), true);
        expect(WorkoutTemplate.exerciseDatabase.containsKey(ExerciseCategory.shoulders), true);
        expect(WorkoutTemplate.exerciseDatabase.containsKey(ExerciseCategory.arms), true);
        expect(WorkoutTemplate.exerciseDatabase.containsKey(ExerciseCategory.legs), true);
        expect(WorkoutTemplate.exerciseDatabase.containsKey(ExerciseCategory.abs), true);
      });

      test('getExercisesForCategory returns correct exercises', () {
        final chestExercises = WorkoutTemplate.getExercisesForCategory(ExerciseCategory.chest);
        expect(chestExercises, contains('Panca Piana'));
        expect(chestExercises, contains('Panca Inclinata'));
        expect(chestExercises, contains('Dips'));

        final backExercises = WorkoutTemplate.getExercisesForCategory(ExerciseCategory.back);
        expect(backExercises, contains('Trazioni'));
        expect(backExercises, contains('Lat Machine'));
        expect(backExercises, contains('Stacchi'));

        final legExercises = WorkoutTemplate.getExercisesForCategory(ExerciseCategory.legs);
        expect(legExercises, contains('Squat'));
        expect(legExercises, contains('Leg Press'));
        expect(legExercises, contains('Affondi'));
      });

      test('getExercisesForCategory returns empty list for cardio', () {
        final cardioExercises = WorkoutTemplate.getExercisesForCategory(ExerciseCategory.cardio);
        expect(cardioExercises, isEmpty);
      });

      test('searchExercises finds exercises by query', () {
        final results = WorkoutTemplate.searchExercises('squat');
        expect(results, contains('Squat'));

        final pancaResults = WorkoutTemplate.searchExercises('panca');
        expect(pancaResults, contains('Panca Piana'));
        expect(pancaResults, contains('Panca Inclinata'));
        expect(pancaResults, contains('Panca Declinata'));
      });

      test('searchExercises is case insensitive', () {
        final upperResults = WorkoutTemplate.searchExercises('SQUAT');
        expect(upperResults, contains('Squat'));

        final lowerResults = WorkoutTemplate.searchExercises('squat');
        expect(lowerResults, contains('Squat'));

        final mixedResults = WorkoutTemplate.searchExercises('SqUaT');
        expect(mixedResults, contains('Squat'));
      });

      test('searchExercises returns empty list for non-matching query', () {
        final results = WorkoutTemplate.searchExercises('xyz123');
        expect(results, isEmpty);
      });

      test('searchExercises returns partial matches', () {
        final results = WorkoutTemplate.searchExercises('curl');
        expect(results, contains('Curl Bilanciere'));
        expect(results, contains('Hammer Curl'));
        expect(results, contains('Curl Manubri'));
        expect(results, contains('Leg Curl'));
      });

      test('all exercises in database are unique within category', () {
        for (final category in ExerciseCategory.values) {
          final exercises = WorkoutTemplate.getExercisesForCategory(category);
          final uniqueExercises = exercises.toSet();
          expect(uniqueExercises.length, exercises.length,
              reason: 'Category ${category.name} has duplicate exercises');
        }
      });
    });
  });
}