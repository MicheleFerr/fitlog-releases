import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/set.dart';
import 'package:gymbro_flutter_new/features/workout/data/repositories/workout_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Mocks
class MockWorkoutRepository extends Mock implements WorkoutRepository {}
class MockUser extends Mock implements User {}
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  late ProviderContainer container;
  late MockWorkoutRepository mockRepository;
  late MockUser mockUser;
  
  setUp(() {
    mockRepository = MockWorkoutRepository();
    mockUser = MockUser();
    
    when(() => mockUser.uid).thenReturn('test-user-id');
    when(() => mockRepository.saveWorkout(any())).thenAnswer((_) async => 'workout-id');
    when(() => mockRepository.updateWorkout(any())).thenAnswer((_) async {
      return null;
    });
    when(() => mockRepository.deleteWorkout(any())).thenAnswer((_) async {
      return null;
    });
    
    container = ProviderContainer(
      overrides: [
        workoutRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('WorkoutNotifier', () {
    test('initial state should be null', () {
      final workout = container.read(currentWorkoutProvider);
      expect(workout, isNull);
    });

    test('startWorkout should create a new workout', () {
      final notifier = container.read(currentWorkoutProvider.notifier);
      
      notifier.startWorkout('Push Day');
      
      final workout = container.read(currentWorkoutProvider);
      expect(workout, isNotNull);
      expect(workout!.name, 'Push Day');
      expect(workout.isActive, true);
      expect(workout.exercises, isEmpty);
    });

    test('addExercise should add exercise to workout', () {
      final notifier = container.read(currentWorkoutProvider.notifier);
      
      notifier.startWorkout('Pull Day');
      
      final exercise = Exercise(
        id: 'ex1',
        name: 'Pull-ups',
        sets: [],
        orderIndex: 0,
      );
      
      notifier.addExercise(exercise);
      
      final workout = container.read(currentWorkoutProvider);
      expect(workout!.exercises.length, 1);
      expect(workout.exercises.first.name, 'Pull-ups');
    });

    test('addSet should add set to exercise', () {
      final notifier = container.read(currentWorkoutProvider.notifier);
      
      notifier.startWorkout('Leg Day');
      
      final exercise = Exercise(
        id: 'ex1',
        name: 'Squats',
        sets: [],
        orderIndex: 0,
      );
      
      notifier.addExercise(exercise);
      notifier.addSet('ex1');
      
      final workout = container.read(currentWorkoutProvider);
      expect(workout!.exercises.first.sets.length, 1);
      expect(workout.exercises.first.sets.first.setNumber, 1);
    });

    test('updateSet should update set values', () {
      final notifier = container.read(currentWorkoutProvider.notifier);
      
      notifier.startWorkout('Upper Body');
      
      final exercise = Exercise(
        id: 'ex1',
        name: 'Bench Press',
        sets: [
          Set(
            id: 'set1',
            setNumber: 1,
            reps: 10,
            weight: 60.0,
          ),
        ],
        orderIndex: 0,
      );
      
      notifier.addExercise(exercise);
      notifier.updateSet('ex1', 0, reps: 12, weight: 65.0);
      
      final workout = container.read(currentWorkoutProvider);
      final updatedSet = workout!.exercises.first.sets.first;
      expect(updatedSet.reps, 12);
      expect(updatedSet.weight, 65.0);
    });

    test('removeSet should remove set from exercise', () {
      final notifier = container.read(currentWorkoutProvider.notifier);
      
      notifier.startWorkout('Back Day');
      
      final exercise = Exercise(
        id: 'ex1',
        name: 'Deadlifts',
        sets: [
          Set(id: 'set1', setNumber: 1, reps: 5, weight: 100.0),
          Set(id: 'set2', setNumber: 2, reps: 5, weight: 100.0),
        ],
        orderIndex: 0,
      );
      
      notifier.addExercise(exercise);
      notifier.removeSet('ex1', 0);
      
      final workout = container.read(currentWorkoutProvider);
      expect(workout!.exercises.first.sets.length, 1);
      expect(workout.exercises.first.sets.first.setNumber, 1); // Renumbered
    });

    test('removeExercise should remove exercise from workout', () {
      final notifier = container.read(currentWorkoutProvider.notifier);
      
      notifier.startWorkout('Full Body');
      
      notifier.addExercise(Exercise(
        id: 'ex1',
        name: 'Squats',
        sets: [],
        orderIndex: 0,
      ));
      
      notifier.addExercise(Exercise(
        id: 'ex2',
        name: 'Bench Press',
        sets: [],
        orderIndex: 1,
      ));
      
      notifier.removeExercise('ex1');
      
      final workout = container.read(currentWorkoutProvider);
      expect(workout!.exercises.length, 1);
      expect(workout.exercises.first.name, 'Bench Press');
    });

    test('reorderExercises should change exercise order', () {
      final notifier = container.read(currentWorkoutProvider.notifier);
      
      notifier.startWorkout('Circuit');
      
      notifier.addExercise(Exercise(
        id: 'ex1',
        name: 'Exercise A',
        sets: [],
        orderIndex: 0,
      ));
      
      notifier.addExercise(Exercise(
        id: 'ex2',
        name: 'Exercise B',
        sets: [],
        orderIndex: 1,
      ));
      
      notifier.addExercise(Exercise(
        id: 'ex3',
        name: 'Exercise C',
        sets: [],
        orderIndex: 2,
      ));
      
      notifier.reorderExercises(2, 0); // Move C to first position
      
      final workout = container.read(currentWorkoutProvider);
      expect(workout!.exercises[0].name, 'Exercise C');
      expect(workout.exercises[1].name, 'Exercise A');
      expect(workout.exercises[2].name, 'Exercise B');
    });

    test('completeWorkout should mark workout as completed', () async {
      final notifier = container.read(currentWorkoutProvider.notifier);
      
      notifier.startWorkout('Morning Workout');
      
      notifier.addExercise(Exercise(
        id: 'ex1',
        name: 'Push-ups',
        sets: [
          Set(id: 'set1', setNumber: 1, reps: 20, weight: 0),
        ],
        orderIndex: 0,
      ));
      
      notifier.completeWorkout();
      
      final workout = container.read(currentWorkoutProvider);
      expect(workout!.isActive, false);
      expect(workout.endTime, isNotNull);
      
      verify(() => mockRepository.saveWorkout(any())).called(1);
    });

    test('pauseWorkout should pause active workout', () {
      final notifier = container.read(currentWorkoutProvider.notifier);
      
      notifier.startWorkout('HIIT Session');
      notifier.pauseWorkout();
      
      final workout = container.read(currentWorkoutProvider);
      expect(workout!.isPaused, true);
      expect(workout.isActive, false);
    });

    test('resumeWorkout should resume paused workout', () {
      final notifier = container.read(currentWorkoutProvider.notifier);
      
      notifier.startWorkout('Cardio');
      notifier.pauseWorkout();
      notifier.resumeWorkout();
      
      final workout = container.read(currentWorkoutProvider);
      expect(workout!.isPaused, false);
      expect(workout.isActive, true);
    });

    test('clearWorkout should reset state to null', () {
      final notifier = container.read(currentWorkoutProvider.notifier);
      
      notifier.startWorkout('Test Workout');
      notifier.clearWorkout();
      
      final workout = container.read(currentWorkoutProvider);
      expect(workout, isNull);
    });

    test('should calculate total volume correctly', () {
      final notifier = container.read(currentWorkoutProvider.notifier);
      
      notifier.startWorkout('Volume Test');
      
      notifier.addExercise(Exercise(
        id: 'ex1',
        name: 'Bench Press',
        sets: [
          Set(id: 's1', setNumber: 1, reps: 10, weight: 60.0),
          Set(id: 's2', setNumber: 2, reps: 8, weight: 65.0),
        ],
        orderIndex: 0,
      ));
      
      notifier.addExercise(Exercise(
        id: 'ex2',
        name: 'Squats',
        sets: [
          Set(id: 's3', setNumber: 1, reps: 12, weight: 80.0),
        ],
        orderIndex: 1,
      ));
      
      final workout = container.read(currentWorkoutProvider);
      final totalVolume = workout!.totalVolume;
      
      // (10*60) + (8*65) + (12*80) = 600 + 520 + 960 = 2080
      expect(totalVolume, 2080.0);
    });

    test('should calculate workout duration correctly', () async {
      final notifier = container.read(currentWorkoutProvider.notifier);
      
      final startTime = DateTime.now();
      notifier.startWorkout('Duration Test');
      
      // Simulate some time passing
      await Future.delayed(const Duration(seconds: 2));
      
      notifier.completeWorkout();
      
      final workout = container.read(currentWorkoutProvider);
      expect(workout!.duration, isNotNull);
      expect(workout.duration!.inSeconds, greaterThanOrEqualTo(2));
    });

    group('Superset Management', () {
      test('should mark exercises as superset', () {
        final notifier = container.read(currentWorkoutProvider.notifier);
        
        notifier.startWorkout('Superset Test');
        
        notifier.addExercise(Exercise(
          id: 'ex1',
          name: 'Bench Press',
          sets: [],
          orderIndex: 0,
        ));
        
        notifier.addExercise(Exercise(
          id: 'ex2',
          name: 'Bent Over Row',
          sets: [],
          orderIndex: 1,
        ));
        
        notifier.toggleSuperset('ex1', 'ex2');
        
        final workout = container.read(currentWorkoutProvider);
        expect(workout!.exercises[0].supersetWith, 'ex2');
        expect(workout.exercises[1].supersetWith, 'ex1');
      });

      test('should unmark superset when toggled again', () {
        final notifier = container.read(currentWorkoutProvider.notifier);
        
        notifier.startWorkout('Superset Test 2');
        
        notifier.addExercise(Exercise(
          id: 'ex1',
          name: 'Dips',
          sets: [],
          orderIndex: 0,
          supersetWith: 'ex2',
        ));
        
        notifier.addExercise(Exercise(
          id: 'ex2',
          name: 'Pull-ups',
          sets: [],
          orderIndex: 1,
          supersetWith: 'ex1',
        ));
        
        notifier.toggleSuperset('ex1', 'ex2');
        
        final workout = container.read(currentWorkoutProvider);
        expect(workout!.exercises[0].supersetWith, isNull);
        expect(workout.exercises[1].supersetWith, isNull);
      });
    });

    group('Notes Management', () {
      test('should add notes to workout', () {
        final notifier = container.read(currentWorkoutProvider.notifier);
        
        notifier.startWorkout('Notes Test');
        notifier.updateWorkoutNotes('Great session, feeling strong!');
        
        final workout = container.read(currentWorkoutProvider);
        expect(workout!.notes, 'Great session, feeling strong!');
      });

      test('should add notes to exercise', () {
        final notifier = container.read(currentWorkoutProvider.notifier);
        
        notifier.startWorkout('Exercise Notes Test');
        
        notifier.addExercise(Exercise(
          id: 'ex1',
          name: 'Squats',
          sets: [],
          orderIndex: 0,
        ));
        
        notifier.updateExerciseNotes('ex1', 'Focus on depth');
        
        final workout = container.read(currentWorkoutProvider);
        expect(workout!.exercises.first.notes, 'Focus on depth');
      });
    });
  });

  group('Workout Statistics', () {
    test('workoutStatsProvider should calculate correct stats', () {
      final container = ProviderContainer();
      final notifier = container.read(currentWorkoutProvider.notifier);
      
      notifier.startWorkout('Stats Test');
      
      notifier.addExercise(Exercise(
        id: 'ex1',
        name: 'Bench Press',
        sets: [
          Set(id: 's1', setNumber: 1, reps: 10, weight: 60.0),
          Set(id: 's2', setNumber: 2, reps: 8, weight: 65.0),
          Set(id: 's3', setNumber: 3, reps: 6, weight: 70.0),
        ],
        orderIndex: 0,
      ));
      
      final stats = container.read(workoutStatsProvider);
      
      expect(stats['totalSets'], 3);
      expect(stats['totalReps'], 24); // 10 + 8 + 6
      expect(stats['totalVolume'], 1940.0); // (10*60) + (8*65) + (6*70)
      expect(stats['exerciseCount'], 1);
    });
  });

  group('Active Workout Check', () {
    test('hasActiveWorkoutProvider should return correct state', () {
      final container = ProviderContainer();
      final notifier = container.read(currentWorkoutProvider.notifier);
      
      expect(container.read(hasActiveWorkoutProvider), false);
      
      notifier.startWorkout('Active Test');
      expect(container.read(hasActiveWorkoutProvider), true);
      
      notifier.pauseWorkout();
      expect(container.read(hasActiveWorkoutProvider), false);
      
      notifier.resumeWorkout();
      expect(container.read(hasActiveWorkoutProvider), true);
      
      notifier.clearWorkout();
      expect(container.read(hasActiveWorkoutProvider), false);
    });
  });
}