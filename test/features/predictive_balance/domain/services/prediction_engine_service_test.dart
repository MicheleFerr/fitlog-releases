import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/predictive_balance/domain/entities/weekly_pattern.dart';
import 'package:gymbro_flutter_new/features/predictive_balance/domain/entities/workout_fingerprint.dart';
import 'package:gymbro_flutter_new/features/predictive_balance/domain/services/prediction_engine_service.dart';
import 'package:gymbro_flutter_new/features/stress_index/presentation/providers/stress_index_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';

void main() {
  group('PredictionEngineService', () {
    // Helper to create workout fingerprint
    WorkoutFingerprint createFingerprint({
      required String id,
      required List<String> dominantMuscles,
      required WorkoutCategory category,
      String? templateName,
      String? templateId,
    }) {
      return WorkoutFingerprint(
        id: id,
        templateName: templateName,
        templateId: templateId,
        dominantMuscles: dominantMuscles,
        category: category,
        totalVolume: 5000.0,
      );
    }

    // Helper to create weekly pattern
    WeeklyPattern createPattern({
      required List<WorkoutFingerprint> cycle,
      double confidence = 0.80,
    }) {
      return WeeklyPattern(
        cycle: cycle,
        confidence: confidence,
        weeksAnalyzed: 3,
        weeksMatched: 2,
        analyzedAt: DateTime.now(),
        avgWorkoutsPerWeek: cycle.length,
      );
    }

    // Helper to create workout
    Workout createWorkout({
      required String name,
      required List<Exercise> exercises,
      int daysAgo = 1,
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
        'Bench Press': ExerciseMuscleData(
          primary: ['PETT'],
          secondary: ['DELT', 'TRIC'],
        ),
        'Shoulder Press': ExerciseMuscleData(
          primary: ['DELT'],
          secondary: ['TRIC'],
        ),
        'Pull-up': ExerciseMuscleData(
          primary: ['DORSO'],
          secondary: ['BIC'],
        ),
        'Barbell Row': ExerciseMuscleData(
          primary: ['DORSO'],
          secondary: ['BIC'],
        ),
        'Squat': ExerciseMuscleData(
          primary: ['QUAD'],
          secondary: ['GLUT'],
        ),
        'Leg Press': ExerciseMuscleData(
          primary: ['QUAD'],
          secondary: ['GLUT', 'FEMORALI'],
        ),
      };
    }

    group('predict', () {
      test('should return null for null pattern', () {
        final result = PredictionEngineService.predict(
          pattern: null,
          thisWeekWorkouts: [],
          muscleMap: createMuscleMap(),
        );

        expect(result, isNull);
      });

      test('should return null for invalid pattern', () {
        final pattern = createPattern(
          cycle: [
            createFingerprint(
              id: 'push1',
              dominantMuscles: ['chest', 'shoulders'],
              category: WorkoutCategory.push,
            ),
          ],
          confidence: 0.50, // Below 0.66 threshold
        );

        final result = PredictionEngineService.predict(
          pattern: pattern,
          thisWeekWorkouts: [],
          muscleMap: createMuscleMap(),
        );

        expect(result, isNull);
      });

      test('should return null when all workouts completed', () {
        final pattern = createPattern(
          cycle: [
            createFingerprint(
              id: 'push1',
              templateName: 'Push',
              dominantMuscles: ['chest', 'shoulders', 'triceps'],
              category: WorkoutCategory.push,
            ),
          ],
        );

        final thisWeekWorkouts = [
          createWorkout(
            name: 'Push',
            exercises: [
              createExercise(name: 'Bench Press'),
              createExercise(name: 'Shoulder Press'),
            ],
          ),
        ];

        final result = PredictionEngineService.predict(
          pattern: pattern,
          thisWeekWorkouts: thisWeekWorkouts,
          muscleMap: createMuscleMap(),
        );

        expect(result, isNull);
      });

      test('should predict missing workout', () {
        final pattern = createPattern(
          cycle: [
            createFingerprint(
              id: 'push1',
              templateName: 'Push',
              dominantMuscles: ['chest', 'shoulders', 'triceps'],
              category: WorkoutCategory.push,
            ),
            createFingerprint(
              id: 'pull1',
              templateName: 'Pull',
              dominantMuscles: ['back', 'biceps'],
              category: WorkoutCategory.pull,
            ),
            createFingerprint(
              id: 'legs1',
              templateName: 'Legs',
              dominantMuscles: ['quadriceps', 'hamstrings', 'glutes'],
              category: WorkoutCategory.legs,
            ),
          ],
        );

        // Only completed Push and Pull
        final thisWeekWorkouts = [
          createWorkout(
            name: 'Push',
            exercises: [createExercise(name: 'Bench Press')],
          ),
          createWorkout(
            name: 'Pull',
            exercises: [createExercise(name: 'Pull-up')],
          ),
        ];

        final result = PredictionEngineService.predict(
          pattern: pattern,
          thisWeekWorkouts: thisWeekWorkouts,
          muscleMap: createMuscleMap(),
        );

        expect(result, isNotNull);
        expect(result!.displayName, equals('Legs'));
        expect(result.musclesCovered, contains('quadriceps'));
        expect(result.musclesCovered, contains('hamstrings'));
        expect(result.musclesCovered, contains('glutes'));
      });

      test('should return first missing workout in order', () {
        final pattern = createPattern(
          cycle: [
            createFingerprint(
              id: 'push1',
              templateName: 'Push',
              dominantMuscles: ['chest', 'shoulders', 'triceps'],
              category: WorkoutCategory.push,
            ),
            createFingerprint(
              id: 'pull1',
              templateName: 'Pull',
              dominantMuscles: ['back', 'biceps'],
              category: WorkoutCategory.pull,
            ),
            createFingerprint(
              id: 'legs1',
              templateName: 'Legs',
              dominantMuscles: ['quadriceps', 'hamstrings', 'glutes'],
              category: WorkoutCategory.legs,
            ),
          ],
        );

        // Nothing completed this week
        final result = PredictionEngineService.predict(
          pattern: pattern,
          thisWeekWorkouts: [],
          muscleMap: createMuscleMap(),
        );

        expect(result, isNotNull);
        expect(result!.displayName, equals('Push'));
        expect(result.missingCount, equals(3));
      });

      test('should include pattern confidence', () {
        final pattern = createPattern(
          cycle: [
            createFingerprint(
              id: 'push1',
              templateName: 'Push',
              dominantMuscles: ['chest', 'shoulders'],
              category: WorkoutCategory.push,
            ),
          ],
          confidence: 0.85,
        );

        final result = PredictionEngineService.predict(
          pattern: pattern,
          thisWeekWorkouts: [],
          muscleMap: createMuscleMap(),
        );

        expect(result, isNotNull);
        expect(result!.patternConfidence, equals(0.85));
      });

      test('should use fingerprint templateId when no templates provided', () {
        final pattern = createPattern(
          cycle: [
            createFingerprint(
              id: 'push1',
              templateName: 'Push Day',
              templateId: 'template-123',
              dominantMuscles: ['chest', 'shoulders'],
              category: WorkoutCategory.push,
            ),
          ],
        );

        final result = PredictionEngineService.predict(
          pattern: pattern,
          thisWeekWorkouts: [],
          muscleMap: createMuscleMap(),
        );

        expect(result, isNotNull);
        expect(result!.hasTemplate, isTrue);
        expect(result.suggestedTemplateId, equals('template-123'));
        expect(result.suggestedTemplateName, equals('Push Day'));
      });
    });

    group('predictAll', () {
      test('should return empty list for null pattern', () {
        final result = PredictionEngineService.predictAll(
          pattern: null,
          thisWeekWorkouts: [],
          muscleMap: createMuscleMap(),
        );

        expect(result, isEmpty);
      });

      test('should return empty list for invalid pattern', () {
        final pattern = createPattern(
          cycle: [
            createFingerprint(
              id: 'push1',
              dominantMuscles: ['chest'],
              category: WorkoutCategory.push,
            ),
          ],
          confidence: 0.50,
        );

        final result = PredictionEngineService.predictAll(
          pattern: pattern,
          thisWeekWorkouts: [],
          muscleMap: createMuscleMap(),
        );

        expect(result, isEmpty);
      });

      test('should return all missing workouts', () {
        final pattern = createPattern(
          cycle: [
            createFingerprint(
              id: 'push1',
              templateName: 'Push',
              dominantMuscles: ['chest', 'shoulders', 'triceps'],
              category: WorkoutCategory.push,
            ),
            createFingerprint(
              id: 'pull1',
              templateName: 'Pull',
              dominantMuscles: ['back', 'biceps'],
              category: WorkoutCategory.pull,
            ),
            createFingerprint(
              id: 'legs1',
              templateName: 'Legs',
              dominantMuscles: ['quadriceps', 'hamstrings', 'glutes'],
              category: WorkoutCategory.legs,
            ),
          ],
        );

        final result = PredictionEngineService.predictAll(
          pattern: pattern,
          thisWeekWorkouts: [],
          muscleMap: createMuscleMap(),
        );

        expect(result.length, equals(3));
        expect(result[0].displayName, equals('Push'));
        expect(result[1].displayName, equals('Pull'));
        expect(result[2].displayName, equals('Legs'));
      });

      test('should return empty list when all completed', () {
        final pattern = createPattern(
          cycle: [
            createFingerprint(
              id: 'push1',
              templateName: 'Push',
              dominantMuscles: ['chest', 'shoulders', 'triceps'],
              category: WorkoutCategory.push,
            ),
          ],
        );

        final thisWeekWorkouts = [
          createWorkout(
            name: 'Push',
            exercises: [createExercise(name: 'Bench Press')],
          ),
        ];

        final result = PredictionEngineService.predictAll(
          pattern: pattern,
          thisWeekWorkouts: thisWeekWorkouts,
          muscleMap: createMuscleMap(),
        );

        expect(result, isEmpty);
      });
    });

    group('wouldResolveMuscle', () {
      test('should return true when muscle is in missing workout', () {
        final pattern = createPattern(
          cycle: [
            createFingerprint(
              id: 'legs1',
              templateName: 'Legs',
              dominantMuscles: ['quadriceps', 'hamstrings', 'glutes'],
              category: WorkoutCategory.legs,
            ),
          ],
        );

        final result = PredictionEngineService.wouldResolveMuscle(
          pattern: pattern,
          thisWeekWorkouts: [],
          muscleMap: createMuscleMap(),
          muscleName: 'quadriceps',
        );

        expect(result, isTrue);
      });

      test('should return false when muscle is not in missing workout', () {
        final pattern = createPattern(
          cycle: [
            createFingerprint(
              id: 'push1',
              templateName: 'Push',
              dominantMuscles: ['chest', 'shoulders', 'triceps'],
              category: WorkoutCategory.push,
            ),
          ],
        );

        final result = PredictionEngineService.wouldResolveMuscle(
          pattern: pattern,
          thisWeekWorkouts: [],
          muscleMap: createMuscleMap(),
          muscleName: 'quadriceps',
        );

        expect(result, isFalse);
      });

      test('should return false when no pattern', () {
        final result = PredictionEngineService.wouldResolveMuscle(
          pattern: null,
          thisWeekWorkouts: [],
          muscleMap: createMuscleMap(),
          muscleName: 'chest',
        );

        expect(result, isFalse);
      });

      test('should return false when all workouts completed', () {
        final pattern = createPattern(
          cycle: [
            createFingerprint(
              id: 'push1',
              templateName: 'Push',
              dominantMuscles: ['chest', 'shoulders', 'triceps'],
              category: WorkoutCategory.push,
            ),
          ],
        );

        final thisWeekWorkouts = [
          createWorkout(
            name: 'Push',
            exercises: [createExercise(name: 'Bench Press')],
          ),
        ];

        final result = PredictionEngineService.wouldResolveMuscle(
          pattern: pattern,
          thisWeekWorkouts: thisWeekWorkouts,
          muscleMap: createMuscleMap(),
          muscleName: 'chest',
        );

        expect(result, isFalse);
      });
    });

    group('template matching', () {
      test('should match template by ID', () {
        final pattern = createPattern(
          cycle: [
            createFingerprint(
              id: 'push1',
              templateName: 'Push Day',
              templateId: 'template-123',
              dominantMuscles: ['chest', 'shoulders'],
              category: WorkoutCategory.push,
            ),
          ],
        );

        final templates = <WorkoutTemplate>[
          WorkoutTemplate(
            id: 'template-123',
            name: 'Push Day v2',
            description: 'Push workout template',
          ),
        ];

        final result = PredictionEngineService.predict(
          pattern: pattern,
          thisWeekWorkouts: [],
          muscleMap: createMuscleMap(),
          templates: templates,
        );

        expect(result, isNotNull);
        expect(result!.hasTemplate, isTrue);
        expect(result.suggestedTemplateId, equals('template-123'));
      });

      test('should match template by name', () {
        final pattern = createPattern(
          cycle: [
            createFingerprint(
              id: 'push1',
              templateName: 'Push Day',
              dominantMuscles: ['chest', 'shoulders'],
              category: WorkoutCategory.push,
            ),
          ],
        );

        final templates = <WorkoutTemplate>[
          WorkoutTemplate(
            id: 'other-id',
            name: 'Push Day',
            description: 'Push workout template',
          ),
        ];

        final result = PredictionEngineService.predict(
          pattern: pattern,
          thisWeekWorkouts: [],
          muscleMap: createMuscleMap(),
          templates: templates,
        );

        expect(result, isNotNull);
        expect(result!.hasTemplate, isTrue);
        expect(result.suggestedTemplateId, equals('other-id'));
      });
    });
  });
}
