import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/predictive_balance/domain/entities/workout_fingerprint.dart';
import 'package:gymbro_flutter_new/features/predictive_balance/domain/services/pattern_detector_service.dart';
import 'package:gymbro_flutter_new/features/stress_index/presentation/providers/stress_index_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';

void main() {
  group('PatternDetectorService', () {
    // Helper to create workout
    Workout createWorkout({
      required List<Exercise> exercises,
      required int daysAgo,
      String name = 'Test Workout',
      String? templateId,
    }) {
      final date = DateTime.now().subtract(Duration(days: daysAgo));
      return Workout(
        id: 'workout-${date.millisecondsSinceEpoch}',
        name: name,
        templateId: templateId,
        exercises: exercises,
        status: WorkoutStatus.completed,
        endTime: date, // completedAt is a getter for endTime
        createdAt: date,
        updatedAt: date,
      );
    }

    // Helper to create exercise
    Exercise createExercise({
      required String name,
      int sets = 3,
      int reps = 10,
      double weight = 50.0,
    }) {
      return Exercise(
        id: 'exercise-${name.hashCode}',
        name: name,
        type: ExerciseType.single,
        category: ExerciseCategory.other,
        sets: List.generate(
          sets,
          (i) => ExerciseSet(
            id: 'set-$i',
            setNumber: i,
            reps: reps,
            weight: weight,
            isCompleted: true,
          ),
        ),
      );
    }

    // Helper to create muscle map
    Map<String, ExerciseMuscleData> createMuscleMap() {
      return {
        'Bench Press': const ExerciseMuscleData(
          primary: ['PETT'],
          secondary: ['DELT', 'TRIC'],
        ),
        'Shoulder Press': const ExerciseMuscleData(
          primary: ['DELT'],
          secondary: ['TRIC'],
        ),
        'Tricep Extension': const ExerciseMuscleData(
          primary: ['TRIC'],
          secondary: [],
        ),
        'Pull-up': const ExerciseMuscleData(
          primary: ['DORSO'],
          secondary: ['BIC'],
        ),
        'Barbell Row': const ExerciseMuscleData(
          primary: ['DORSO'],
          secondary: ['BIC'],
        ),
        'Bicep Curl': const ExerciseMuscleData(
          primary: ['BIC'],
          secondary: [],
        ),
        'Squat': const ExerciseMuscleData(
          primary: ['QUAD'],
          secondary: ['GLUT'],
        ),
        'Leg Press': const ExerciseMuscleData(
          primary: ['QUAD'],
          secondary: ['GLUT', 'FEMORALI'],
        ),
        'Romanian Deadlift': const ExerciseMuscleData(
          primary: ['FEMORALI'],
          secondary: ['GLUT'],
        ),
        'Deadlift': const ExerciseMuscleData(
          primary: ['DORSO', 'FEMORALI'],
          secondary: ['GLUT', 'QUAD'],
        ),
      };
    }

    group('normalizeMuscle', () {
      test('should normalize Italian muscle codes', () {
        expect(PatternDetectorService.normalizeMuscle('PETT'), equals('chest'));
        expect(
          PatternDetectorService.normalizeMuscle('PETTORALI'),
          equals('chest'),
        );
        expect(
          PatternDetectorService.normalizeMuscle('DELT'),
          equals('shoulders'),
        );
        expect(
          PatternDetectorService.normalizeMuscle('DELTOIDI'),
          equals('shoulders'),
        );
        expect(
          PatternDetectorService.normalizeMuscle('DORSO'),
          equals('back'),
        );
        expect(
          PatternDetectorService.normalizeMuscle('LAT'),
          equals('back'),
        );
        expect(
          PatternDetectorService.normalizeMuscle('QUAD'),
          equals('quadriceps'),
        );
        expect(
          PatternDetectorService.normalizeMuscle('FEMORALI'),
          equals('hamstrings'),
        );
        expect(
          PatternDetectorService.normalizeMuscle('GLUT'),
          equals('glutes'),
        );
      });

      test('should normalize English muscle codes', () {
        expect(PatternDetectorService.normalizeMuscle('CHEST'), equals('chest'));
        expect(
          PatternDetectorService.normalizeMuscle('SHOULDERS'),
          equals('shoulders'),
        );
        expect(PatternDetectorService.normalizeMuscle('BACK'), equals('back'));
        expect(
          PatternDetectorService.normalizeMuscle('QUADRICEPS'),
          equals('quadriceps'),
        );
        expect(
          PatternDetectorService.normalizeMuscle('HAMSTRINGS'),
          equals('hamstrings'),
        );
        expect(
          PatternDetectorService.normalizeMuscle('GLUTES'),
          equals('glutes'),
        );
      });

      test('should be case insensitive', () {
        expect(PatternDetectorService.normalizeMuscle('pett'), equals('chest'));
        expect(PatternDetectorService.normalizeMuscle('Pett'), equals('chest'));
        expect(PatternDetectorService.normalizeMuscle('PETT'), equals('chest'));
      });

      test('should return lowercase original for unknown codes', () {
        expect(
          PatternDetectorService.normalizeMuscle('UNKNOWN'),
          equals('unknown'),
        );
        expect(
          PatternDetectorService.normalizeMuscle('Custom Muscle'),
          equals('custom muscle'),
        );
      });
    });

    group('inferCategory', () {
      test('should identify push workouts', () {
        expect(
          PatternDetectorService.inferCategory(
              ['chest', 'shoulders', 'triceps']),
          equals(WorkoutCategory.push),
        );
        expect(
          PatternDetectorService.inferCategory(['chest', 'shoulders']),
          equals(WorkoutCategory.push),
        );
      });

      test('should identify pull workouts', () {
        expect(
          PatternDetectorService.inferCategory(['back', 'biceps']),
          equals(WorkoutCategory.pull),
        );
      });

      test('should identify legs workouts', () {
        expect(
          PatternDetectorService.inferCategory(
              ['quadriceps', 'hamstrings', 'glutes']),
          equals(WorkoutCategory.legs),
        );
        expect(
          PatternDetectorService.inferCategory(['quadriceps', 'hamstrings']),
          equals(WorkoutCategory.legs),
        );
      });

      test('should identify upper body workouts', () {
        expect(
          PatternDetectorService.inferCategory(['chest', 'back']),
          equals(WorkoutCategory.upper),
        );
        expect(
          PatternDetectorService.inferCategory(['shoulders', 'biceps']),
          equals(WorkoutCategory.upper),
        );
      });

      test('should identify full body workouts', () {
        expect(
          PatternDetectorService.inferCategory(
              ['chest', 'back', 'quadriceps']),
          equals(WorkoutCategory.fullBody),
        );
        expect(
          PatternDetectorService.inferCategory(
              ['shoulders', 'hamstrings', 'triceps']),
          equals(WorkoutCategory.fullBody),
        );
      });

      test('should identify lower body workouts', () {
        expect(
          PatternDetectorService.inferCategory(['quadriceps']),
          equals(WorkoutCategory.lower),
        );
        expect(
          PatternDetectorService.inferCategory(['glutes']),
          equals(WorkoutCategory.lower),
        );
      });

      test('should return other for unclassified', () {
        expect(
          PatternDetectorService.inferCategory(['core']),
          equals(WorkoutCategory.other),
        );
        expect(
          PatternDetectorService.inferCategory(['forearms']),
          equals(WorkoutCategory.other),
        );
        expect(
          PatternDetectorService.inferCategory([]),
          equals(WorkoutCategory.other),
        );
      });
    });

    group('generateId', () {
      test('should generate consistent IDs for same inputs', () {
        final id1 = PatternDetectorService.generateId(
          ['chest', 'shoulders', 'triceps'],
          WorkoutCategory.push,
        );
        final id2 = PatternDetectorService.generateId(
          ['chest', 'shoulders', 'triceps'],
          WorkoutCategory.push,
        );

        expect(id1, equals(id2));
      });

      test('should generate different IDs for different inputs', () {
        final pushId = PatternDetectorService.generateId(
          ['chest', 'shoulders', 'triceps'],
          WorkoutCategory.push,
        );
        final pullId = PatternDetectorService.generateId(
          ['back', 'biceps'],
          WorkoutCategory.pull,
        );

        expect(pushId, isNot(equals(pullId)));
      });

      test('should return 8 character ID', () {
        final id = PatternDetectorService.generateId(
          ['chest', 'shoulders'],
          WorkoutCategory.push,
        );
        expect(id.length, equals(8));
      });
    });

    group('detect', () {
      test('should return null for insufficient data', () {
        final muscleMap = createMuscleMap();

        // Less than 6 workouts
        final result = PatternDetectorService.detect(
          history: [
            createWorkout(
              daysAgo: 1,
              exercises: [createExercise(name: 'Bench Press')],
            ),
            createWorkout(
              daysAgo: 3,
              exercises: [createExercise(name: 'Pull-up')],
            ),
          ],
          muscleMap: muscleMap,
        );

        expect(result, isNull);
      });

      test('should return null for empty history', () {
        final muscleMap = createMuscleMap();

        final result = PatternDetectorService.detect(
          history: [],
          muscleMap: muscleMap,
        );

        expect(result, isNull);
      });

      test('should return null for workouts older than analysis window', () {
        final muscleMap = createMuscleMap();

        // All workouts older than 3 weeks
        final result = PatternDetectorService.detect(
          history: List.generate(
            10,
            (i) => createWorkout(
              daysAgo: 30 + i,
              exercises: [createExercise(name: 'Bench Press')],
            ),
          ),
          muscleMap: muscleMap,
        );

        expect(result, isNull);
      });

      test('should detect push/pull/legs pattern', () {
        final muscleMap = createMuscleMap();

        // Create consistent PPL pattern over 3 weeks
        final history = <Workout>[];

        // Week 1
        history.add(createWorkout(
          daysAgo: 2,
          name: 'Push',
          exercises: [
            createExercise(name: 'Bench Press'),
            createExercise(name: 'Shoulder Press'),
            createExercise(name: 'Tricep Extension'),
          ],
        ));
        history.add(createWorkout(
          daysAgo: 4,
          name: 'Pull',
          exercises: [
            createExercise(name: 'Pull-up'),
            createExercise(name: 'Barbell Row'),
            createExercise(name: 'Bicep Curl'),
          ],
        ));
        history.add(createWorkout(
          daysAgo: 6,
          name: 'Legs',
          exercises: [
            createExercise(name: 'Squat'),
            createExercise(name: 'Leg Press'),
            createExercise(name: 'Romanian Deadlift'),
          ],
        ));

        // Week 2
        history.add(createWorkout(
          daysAgo: 9,
          name: 'Push',
          exercises: [
            createExercise(name: 'Bench Press'),
            createExercise(name: 'Shoulder Press'),
          ],
        ));
        history.add(createWorkout(
          daysAgo: 11,
          name: 'Pull',
          exercises: [
            createExercise(name: 'Pull-up'),
            createExercise(name: 'Barbell Row'),
          ],
        ));
        history.add(createWorkout(
          daysAgo: 13,
          name: 'Legs',
          exercises: [
            createExercise(name: 'Squat'),
            createExercise(name: 'Leg Press'),
          ],
        ));

        // Week 3
        history.add(createWorkout(
          daysAgo: 16,
          name: 'Push',
          exercises: [
            createExercise(name: 'Bench Press'),
          ],
        ));
        history.add(createWorkout(
          daysAgo: 18,
          name: 'Pull',
          exercises: [
            createExercise(name: 'Pull-up'),
          ],
        ));

        final result = PatternDetectorService.detect(
          history: history,
          muscleMap: muscleMap,
        );

        expect(result, isNotNull);
        expect(result!.isValid, isTrue);
        expect(result.weeksAnalyzed, greaterThanOrEqualTo(2));
      });

      test('should return pattern with confidence', () {
        final muscleMap = createMuscleMap();

        // Create workouts
        final history = <Workout>[];
        for (var week = 0; week < 3; week++) {
          final baseDay = week * 7;
          history.add(createWorkout(
            daysAgo: baseDay + 1,
            name: 'Push',
            exercises: [createExercise(name: 'Bench Press')],
          ));
          history.add(createWorkout(
            daysAgo: baseDay + 3,
            name: 'Pull',
            exercises: [createExercise(name: 'Pull-up')],
          ));
        }

        final result = PatternDetectorService.detect(
          history: history,
          muscleMap: muscleMap,
        );

        expect(result, isNotNull);
        expect(result!.confidence, greaterThan(0));
        expect(result.confidence, lessThanOrEqualTo(1.0));
      });
    });
  });
}
