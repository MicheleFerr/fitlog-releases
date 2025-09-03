import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_auto_save_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart' as wt;
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/auth/data/auth_service.dart';
import 'package:gymbro_flutter_new/features/auth/domain/entities/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:mocktail/mocktail.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_draft.dart';

// Mock classes
class MockAuthService extends Mock implements AuthService {}
class MockFirebaseUser extends Mock implements firebase_auth.User {}
class MockRef extends Mock implements Ref {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  late ProviderContainer container;
  late MockAuthService mockAuthService;
  late Directory tempDir;
  
  setUpAll(() async {
    registerFallbackValue(ExerciseCategory.chest);
    registerFallbackValue(ExerciseType.single);
    
    // Initialize Hive for tests
    tempDir = await Directory.systemTemp.createTemp();
    Hive.init(tempDir.path);
    
    // Register adapters
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(WorkoutDraftAdapter());
    }
  });

  setUp(() {
    mockAuthService = MockAuthService();
    
    container = ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(mockAuthService),
      ],
    );
  });

  tearDown(() async {
    // Ensure auto-save is stopped before disposing container
    try {
      final autoSave = container.read(workoutAutoSaveProvider.notifier);
      autoSave.stopAutoSave();
    } catch (_) {
      // Ignore if already disposed
    }
    
    // Small delay to ensure auto-save timer is cancelled
    await Future.delayed(const Duration(milliseconds: 100));
    
    container.dispose();
    // Clean up Hive boxes
    await Hive.deleteFromDisk();
  });
  
  tearDownAll(() async {
    // Clean up temp directory
    await tempDir.delete(recursive: true);
  });

  group('CurrentWorkoutNotifier', () {
    test('initial state is null', () {
      final workout = container.read(currentWorkoutProvider);
      expect(workout, isNull);
    });

    test('createWorkout creates new workout with name', () {
      final notifier = container.read(currentWorkoutProvider.notifier);
      
      notifier.createWorkout('Morning Workout');
      
      final workout = container.read(currentWorkoutProvider);
      expect(workout, isNotNull);
      expect(workout!.name, 'Morning Workout');
      expect(workout.exercises, isEmpty);
      expect(workout.status, WorkoutStatus.planned);
      expect(workout.isCompleted, false);
    });

    test('startFromTemplate creates workout from template', () {
      final notifier = container.read(currentWorkoutProvider.notifier);
      
      // Create a template
      final template = wt.WorkoutTemplate(
        name: 'Push Day',
        description: 'Upper body push workout',
        exercises: [
          wt.ExerciseTemplate(
            exerciseId: 'ex-1',
            exerciseName: 'Bench Press',
            type: ExerciseType.single,
            category: ExerciseCategory.chest,
            sets: [
              wt.SetTemplate(setNumber: 1, targetWeight: 60, targetReps: 10),
              wt.SetTemplate(setNumber: 2, targetWeight: 65, targetReps: 8),
            ],
          ),
          wt.ExerciseTemplate(
            exerciseId: 'ex-2',
            exerciseName: 'Shoulder Press',
            type: ExerciseType.single,
            category: ExerciseCategory.shoulders,
            sets: [
              wt.SetTemplate(setNumber: 1, targetWeight: 30, targetReps: 12),
            ],
          ),
        ],
      );
      
      notifier.startFromTemplate(template);
      
      final workout = container.read(currentWorkoutProvider);
      expect(workout, isNotNull);
      expect(workout!.name, 'Push Day');
      expect(workout.exercises.length, 2);
      expect(workout.exercises[0].name, 'Bench Press');
      expect(workout.exercises[0].sets.length, 2);
      expect(workout.exercises[1].name, 'Shoulder Press');
      expect(workout.status, WorkoutStatus.inProgress); // Template workouts start automatically
    });

    test('startWorkout starts the workout timer', () {
      final notifier = container.read(currentWorkoutProvider.notifier);
      
      notifier.createWorkout('Test Workout');
      notifier.startWorkout();
      
      final workout = container.read(currentWorkoutProvider);
      expect(workout!.status, WorkoutStatus.inProgress);
      expect(workout.startTime, isNotNull);
    });

    test('pauseWorkout pauses the workout', () {
      final notifier = container.read(currentWorkoutProvider.notifier);
      
      notifier.createWorkout('Test Workout');
      notifier.startWorkout();
      notifier.pauseWorkout();
      
      final workout = container.read(currentWorkoutProvider);
      expect(workout!.status, WorkoutStatus.paused);
    });

    test('resumeWorkout resumes paused workout', () {
      final notifier = container.read(currentWorkoutProvider.notifier);
      
      notifier.createWorkout('Test Workout');
      notifier.startWorkout();
      notifier.pauseWorkout();
      notifier.resumeWorkout();
      
      final workout = container.read(currentWorkoutProvider);
      expect(workout!.status, WorkoutStatus.inProgress);
    });

    test('addExercise adds exercise to workout', () {
      final notifier = container.read(currentWorkoutProvider.notifier);
      
      notifier.createWorkout('Test Workout');
      
      final exercise = Exercise(
        name: 'Squat',
        type: ExerciseType.single,
        category: ExerciseCategory.legs,
        sets: [
          ExerciseSet(setNumber: 1, weight: 80, reps: 10),
        ],
      );
      
      notifier.addExercise(exercise);
      
      final workout = container.read(currentWorkoutProvider);
      expect(workout!.exercises.length, 1);
      expect(workout.exercises[0].name, 'Squat');
    });

    test('removeExercise removes exercise from workout', () {
      final notifier = container.read(currentWorkoutProvider.notifier);
      
      notifier.createWorkout('Test Workout');
      
      final exercise = Exercise(
        id: 'ex-1',
        name: 'Squat',
        type: ExerciseType.single,
        category: ExerciseCategory.legs,
        sets: [],
      );
      
      notifier.addExercise(exercise);
      notifier.removeExercise('ex-1');
      
      final workout = container.read(currentWorkoutProvider);
      expect(workout!.exercises, isEmpty);
    });

    test('updateExercise updates existing exercise', () {
      final notifier = container.read(currentWorkoutProvider.notifier);
      
      notifier.createWorkout('Test Workout');
      
      final exercise = Exercise(
        id: 'ex-1',
        name: 'Squat',
        type: ExerciseType.single,
        category: ExerciseCategory.legs,
        sets: [
          ExerciseSet(setNumber: 1, weight: 80, reps: 10),
        ],
      );
      
      notifier.addExercise(exercise);
      
      final updatedExercise = exercise.copyWith(
        name: 'Front Squat',
        sets: [
          ExerciseSet(setNumber: 1, weight: 70, reps: 12),
        ],
      );
      
      notifier.updateExercise('ex-1', updatedExercise);
      
      final workout = container.read(currentWorkoutProvider);
      expect(workout!.exercises[0].name, 'Front Squat');
      expect(workout.exercises[0].sets[0].weight, 70);
    });

    test('updateExerciseOnly updates exercise without id parameter', () {
      final notifier = container.read(currentWorkoutProvider.notifier);
      
      notifier.createWorkout('Test Workout');
      
      final exercise = Exercise(
        id: 'ex-1',
        name: 'Squat',
        type: ExerciseType.single,
        category: ExerciseCategory.legs,
        sets: [],
      );
      
      notifier.addExercise(exercise);
      
      final updatedExercise = exercise.copyWith(name: 'Back Squat');
      notifier.updateExerciseOnly(updatedExercise);
      
      final workout = container.read(currentWorkoutProvider);
      expect(workout!.exercises[0].name, 'Back Squat');
    });

    test('completeSet marks set as completed', () {
      final notifier = container.read(currentWorkoutProvider.notifier);
      
      notifier.createWorkout('Test Workout');
      
      final set = ExerciseSet(
        id: 'set-1',
        setNumber: 1,
        weight: 100,
        reps: 10,
        isCompleted: false,
      );
      
      final exercise = Exercise(
        id: 'ex-1',
        name: 'Deadlift',
        type: ExerciseType.single,
        category: ExerciseCategory.back,
        sets: [set],
      );
      
      notifier.addExercise(exercise);
      notifier.completeSet('ex-1', 'set-1');
      
      final workout = container.read(currentWorkoutProvider);
      expect(workout!.exercises[0].sets[0].isCompleted, true);
    });

    test('updateExerciseSet updates specific set', () {
      final notifier = container.read(currentWorkoutProvider.notifier);
      
      notifier.createWorkout('Test Workout');
      
      final set = ExerciseSet(
        id: 'set-1',
        setNumber: 1,
        weight: 100,
        reps: 10,
      );
      
      final exercise = Exercise(
        id: 'ex-1',
        name: 'Deadlift',
        type: ExerciseType.single,
        category: ExerciseCategory.back,
        sets: [set],
      );
      
      notifier.addExercise(exercise);
      
      final updatedSet = set.copyWith(
        weight: 110,
        reps: 8,
        isCompleted: true,
      );
      
      notifier.updateExerciseSet('ex-1', updatedSet);
      
      final workout = container.read(currentWorkoutProvider);
      expect(workout!.exercises[0].sets[0].weight, 110);
      expect(workout.exercises[0].sets[0].reps, 8);
      expect(workout.exercises[0].sets[0].isCompleted, true);
    });

    test('addSetToExercise adds new set with previous values', () {
      final notifier = container.read(currentWorkoutProvider.notifier);
      
      notifier.createWorkout('Test Workout');
      
      final exercise = Exercise(
        id: 'ex-1',
        name: 'Bench Press',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        sets: [
          ExerciseSet(setNumber: 1, weight: 60, reps: 10),
        ],
      );
      
      notifier.addExercise(exercise);
      notifier.addSetToExercise('ex-1');
      
      final workout = container.read(currentWorkoutProvider);
      expect(workout!.exercises[0].sets.length, 2);
      expect(workout.exercises[0].sets[1].setNumber, 2);
      expect(workout.exercises[0].sets[1].weight, 60); // Uses previous weight
      expect(workout.exercises[0].sets[1].reps, 10); // Uses previous reps
    });

    test('addSetToExercise uses defaults when no previous sets', () {
      final notifier = container.read(currentWorkoutProvider.notifier);
      
      notifier.createWorkout('Test Workout');
      
      final exercise = Exercise(
        id: 'ex-1',
        name: 'Bench Press',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        sets: [],
      );
      
      notifier.addExercise(exercise);
      notifier.addSetToExercise('ex-1');
      
      final workout = container.read(currentWorkoutProvider);
      expect(workout!.exercises[0].sets.length, 1);
      expect(workout.exercises[0].sets[0].weight, 0); // Default weight
      expect(workout.exercises[0].sets[0].reps, 10); // Default reps
    });

    test('removeSetFromExercise removes and renumbers sets', () {
      final notifier = container.read(currentWorkoutProvider.notifier);
      
      notifier.createWorkout('Test Workout');
      
      final exercise = Exercise(
        id: 'ex-1',
        name: 'Bench Press',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        sets: [
          ExerciseSet(id: 'set-1', setNumber: 1, weight: 60, reps: 10),
          ExerciseSet(id: 'set-2', setNumber: 2, weight: 65, reps: 8),
          ExerciseSet(id: 'set-3', setNumber: 3, weight: 70, reps: 6),
        ],
      );
      
      notifier.addExercise(exercise);
      notifier.removeSetFromExercise('ex-1', 'set-2');
      
      final workout = container.read(currentWorkoutProvider);
      expect(workout!.exercises[0].sets.length, 2);
      expect(workout.exercises[0].sets[0].setNumber, 1);
      expect(workout.exercises[0].sets[1].setNumber, 2); // Renumbered
      expect(workout.exercises[0].sets[1].weight, 70); // Was set-3
    });

    test('clearWorkout resets state to null', () {
      final notifier = container.read(currentWorkoutProvider.notifier);
      
      notifier.createWorkout('Test Workout');
      notifier.clearWorkout();
      
      final workout = container.read(currentWorkoutProvider);
      expect(workout, isNull);
    });

    test('completeWorkout marks workout as completed', () async {
      final mockUser = MockFirebaseUser();
      when(() => mockUser.email).thenReturn('test@example.com');
      when(() => mockUser.uid).thenReturn('test-uid');
      when(() => mockUser.displayName).thenReturn('Test User');
      when(() => mockAuthService.currentUser).thenReturn(mockUser);
      
      final notifier = container.read(currentWorkoutProvider.notifier);
      
      notifier.createWorkout('Test Workout');
      notifier.startWorkout();
      
      // Add an exercise with completed sets
      final exercise = Exercise(
        name: 'Squat',
        type: ExerciseType.single,
        category: ExerciseCategory.legs,
        sets: [
          ExerciseSet(setNumber: 1, weight: 100, reps: 10, isCompleted: true),
        ],
      );
      notifier.addExercise(exercise);
      
      notifier.completeWorkout();
      
      final workout = container.read(currentWorkoutProvider);
      expect(workout!.isCompleted, true);
      expect(workout.endTime, isNotNull);
    });

    test('handles null state gracefully', () {
      final notifier = container.read(currentWorkoutProvider.notifier);
      
      // These should not throw when state is null
      expect(() => notifier.startWorkout(), returnsNormally);
      expect(() => notifier.pauseWorkout(), returnsNormally);
      expect(() => notifier.resumeWorkout(), returnsNormally);
      expect(() => notifier.completeWorkout(), returnsNormally);
      expect(() => notifier.addExercise(Exercise(
        name: 'Test',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        sets: [],
      )), returnsNormally);
      expect(() => notifier.removeExercise('id'), returnsNormally);
      expect(() => notifier.updateExercise('id', Exercise(
        name: 'Test',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        sets: [],
      )), returnsNormally);
      expect(() => notifier.updateExerciseOnly(Exercise(
        name: 'Test',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        sets: [],
      )), returnsNormally);
      expect(() => notifier.completeSet('ex', 'set'), returnsNormally);
      expect(() => notifier.updateExerciseSet('ex', ExerciseSet(setNumber: 1)), returnsNormally);
      expect(() => notifier.addSetToExercise('ex'), returnsNormally);
      expect(() => notifier.removeSetFromExercise('ex', 'set'), returnsNormally);
    });
  });

  group('WorkoutHistoryNotifier', () {
    test('initial state is empty list', () {
      final history = container.read(workoutHistoryProvider);
      expect(history, isEmpty);
    });

    test('addCompletedWorkout adds only completed workouts', () {
      final notifier = container.read(workoutHistoryProvider.notifier);
      
      final incompleteWorkout = Workout(name: 'Incomplete');
      final completedWorkout = Workout(name: 'Complete')
        .startWorkout()
        .completeWorkout();
      
      notifier.addCompletedWorkout(incompleteWorkout);
      notifier.addCompletedWorkout(completedWorkout);
      
      final history = container.read(workoutHistoryProvider);
      expect(history.length, 1);
      expect(history[0].name, 'Complete');
    });

    test('removeWorkout removes by id', () {
      final notifier = container.read(workoutHistoryProvider.notifier);
      
      final workout1 = Workout(id: 'w1', name: 'Workout 1')
        .startWorkout()
        .completeWorkout();
      final workout2 = Workout(id: 'w2', name: 'Workout 2')
        .startWorkout()
        .completeWorkout();
      
      notifier.addCompletedWorkout(workout1);
      notifier.addCompletedWorkout(workout2);
      notifier.removeWorkout('w1');
      
      final history = container.read(workoutHistoryProvider);
      expect(history.length, 1);
      expect(history[0].id, 'w2');
    });

    test('getWorkoutsByDateRange filters by date', () {
      final notifier = container.read(workoutHistoryProvider.notifier);
      
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final tomorrow = now.add(const Duration(days: 1));
      final lastWeek = now.subtract(const Duration(days: 7));
      
      // Create workouts with specific dates
      final recentWorkout = Workout(name: 'Recent')
        .copyWith(startTime: now)
        .completeWorkout();
      
      final oldWorkout = Workout(name: 'Old')
        .copyWith(startTime: lastWeek)
        .completeWorkout();
      
      notifier.addCompletedWorkout(recentWorkout);
      notifier.addCompletedWorkout(oldWorkout);
      
      final filtered = notifier.getWorkoutsByDateRange(yesterday, tomorrow);
      expect(filtered.length, 1);
      expect(filtered[0].name, 'Recent');
    });
  });

  group('Exercise Providers', () {
    test('exerciseTemplatesProvider provides exercise database', () {
      final templates = container.read(exerciseTemplatesProvider);
      
      expect(templates, isNotEmpty);
      expect(templates[ExerciseCategory.chest], isNotNull);
      // Check for an Italian exercise name since the database is in Italian
      expect(templates[ExerciseCategory.chest], contains('Panca Piana'));
    });

    test('exerciseSearchProvider updates search query', () {
      final initialQuery = container.read(exerciseSearchProvider);
      expect(initialQuery, '');
      
      container.read(exerciseSearchProvider.notifier).state = 'Squat';
      
      final updatedQuery = container.read(exerciseSearchProvider);
      expect(updatedQuery, 'Squat');
    });

    test('filteredExercisesProvider filters by search query', () {
      // Initially empty when no search
      final initialFiltered = container.read(filteredExercisesProvider);
      expect(initialFiltered, isEmpty);
      
      // Update search query with an Italian term
      container.read(exerciseSearchProvider.notifier).state = 'Panca';
      
      final filtered = container.read(filteredExercisesProvider);
      expect(filtered, isNotEmpty);
      expect(filtered.any((e) => e.contains('Panca')), true);
    });

    test('selectedExerciseCategoryProvider defaults to chest', () {
      final category = container.read(selectedExerciseCategoryProvider);
      expect(category, ExerciseCategory.chest);
    });

    test('selectedExerciseCategoryProvider can be updated', () {
      container.read(selectedExerciseCategoryProvider.notifier).state = 
        ExerciseCategory.legs;
      
      final category = container.read(selectedExerciseCategoryProvider);
      expect(category, ExerciseCategory.legs);
    });

    test('selectedExerciseTypeProvider defaults to single', () {
      final type = container.read(selectedExerciseTypeProvider);
      expect(type, ExerciseType.single);
    });

    test('selectedExerciseTypeProvider can be updated', () {
      container.read(selectedExerciseTypeProvider.notifier).state = 
        ExerciseType.superset;
      
      final type = container.read(selectedExerciseTypeProvider);
      expect(type, ExerciseType.superset);
    });
  });

  group('Edge Cases', () {
    test('handles exercise without id gracefully', () {
      final notifier = container.read(currentWorkoutProvider.notifier);
      
      notifier.createWorkout('Test');
      
      final exerciseWithoutId = Exercise(
        name: 'No ID Exercise',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        sets: [],
      );
      
      notifier.addExercise(exerciseWithoutId);
      expect(container.read(currentWorkoutProvider)!.exercises.length, 1);
      
      // Try to update with mismatched id
      notifier.updateExercise('wrong-id', exerciseWithoutId);
      expect(container.read(currentWorkoutProvider)!.exercises.length, 1);
    });

    test('handles sets without id gracefully', () {
      final notifier = container.read(currentWorkoutProvider.notifier);
      
      notifier.createWorkout('Test');
      
      final exercise = Exercise(
        id: 'ex-1',
        name: 'Test Exercise',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        sets: [
          ExerciseSet(setNumber: 1, weight: 50, reps: 10),
        ],
      );
      
      notifier.addExercise(exercise);
      notifier.completeSet('ex-1', 'non-existent-id');
      
      // Should not crash, set should remain unchanged
      final workout = container.read(currentWorkoutProvider);
      expect(workout!.exercises[0].sets[0].isCompleted, false);
    });

    test('maintains state consistency during rapid updates', () {
      final notifier = container.read(currentWorkoutProvider.notifier);
      
      notifier.createWorkout('Rapid Test');
      
      // Rapid fire updates
      for (int i = 0; i < 10; i++) {
        final exercise = Exercise(
          id: 'ex-$i',
          name: 'Exercise $i',
          type: ExerciseType.single,
          category: ExerciseCategory.chest,
          sets: [],
        );
        notifier.addExercise(exercise);
      }
      
      final workout = container.read(currentWorkoutProvider);
      expect(workout!.exercises.length, 10);
      
      // Remove every other exercise
      for (int i = 0; i < 10; i += 2) {
        notifier.removeExercise('ex-$i');
      }
      
      final updatedWorkout = container.read(currentWorkoutProvider);
      expect(updatedWorkout!.exercises.length, 5);
    });
  });
}