import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';

void main() {
  group('💪 Workout Core Logic Tests', () {
    
    test('✅ TEST 1: Create new workout', () {
      final workout = Workout(
      id: 'test-id',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        id: 'test-workout-1',
        name: 'Chest Day',
        exercises: [],
        status: WorkoutStatus.planned,
      );
      
      expect(workout.name, 'Chest Day');
      expect(workout.exercises, isEmpty);
      expect(workout.status, WorkoutStatus.planned);
      expect(workout.isCompleted, false);
      expect(workout.isActive, false);
    });
    
    test('✅ TEST 2: Add exercise to workout', () {
      final exercise = Exercise(
        id: 'ex-1',
        name: 'Bench Press',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        sets: [],
      );
      
      final workout = Workout(
      id: 'test-id',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        id: 'test-workout-1',
        name: 'Chest Day',
        exercises: [],
      );
      
      final updatedWorkout = workout.addExercise(exercise);
      
      expect(updatedWorkout.exercises.length, 1);
      expect(updatedWorkout.exercises.first.name, 'Bench Press');
    });
    
    test('✅ TEST 3: Calculate workout progress', () {
      final sets1 = [
        ExerciseSet(setNumber: 1, weight: 50.0, reps: 10, isCompleted: true),
        ExerciseSet(setNumber: 2, weight: 50.0, reps: 10, isCompleted: true),
        ExerciseSet(setNumber: 3, weight: 55.0, reps: 8, isCompleted: false),
      ];
      
      final sets2 = [
        ExerciseSet(setNumber: 1, weight: 30.0, reps: 12, isCompleted: true),
        ExerciseSet(setNumber: 2, weight: 30.0, reps: 12, isCompleted: false),
      ];
      
      final exercise1 = Exercise(
        name: 'Bench Press',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        sets: sets1,
      );
      
      final exercise2 = Exercise(
        name: 'Dumbbell Flyes',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        sets: sets2,
      );
      
      final workout = Workout(
      id: 'test-id',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        name: 'Chest Day',
        exercises: [exercise1, exercise2],
        status: WorkoutStatus.inProgress,
      );
      
      expect(workout.totalSets, 5);
      expect(workout.completedSets, 3);
      expect(workout.progressPercentage, 0.6); // 3/5 = 0.6
    });
    
    test('✅ TEST 4: Workout status transitions', () {
      var workout = Workout(
        id: 'test-id',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        name: 'Chest Day',
        status: WorkoutStatus.planned,
      );
      
      expect(workout.isActive, false);
      expect(workout.isCompleted, false);
      
      // Start workout
      workout = workout.copyWith(
        status: WorkoutStatus.inProgress,
        startTime: DateTime.now(),
      );
      
      expect(workout.status, WorkoutStatus.inProgress);
      expect(workout.isActive, true);
      expect(workout.startTime, isNotNull);
      
      // Complete workout
      workout = workout.copyWith(
        status: WorkoutStatus.completed,
        endTime: DateTime.now(),
      );
      
      expect(workout.status, WorkoutStatus.completed);
      expect(workout.isCompleted, true);
      expect(workout.isActive, false);
    });
    
    test('✅ TEST 5: Calculate workout duration', () {
      final startTime = DateTime.now().subtract(const Duration(minutes: 45));
      final endTime = DateTime.now();
      
      final workout = Workout(
      id: 'test-id',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        name: 'Chest Day',
        status: WorkoutStatus.completed,
        startTime: startTime,
        endTime: endTime,
      );
      
      final duration = workout.duration;
      expect(duration, isNotNull);
      expect(duration!.inMinutes, greaterThanOrEqualTo(44));
      expect(duration.inMinutes, lessThanOrEqualTo(46));
    });
    
    test('✅ TEST 6: Remove exercise from workout', () {
      final exercise1 = Exercise(
        id: 'ex-1',
        name: 'Bench Press',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
      );
      
      final exercise2 = Exercise(
        id: 'ex-2',
        name: 'Incline Press',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
      );
      
      final workout = Workout(
      id: 'test-id',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        name: 'Chest Day',
        exercises: [exercise1, exercise2],
      );
      
      final updatedWorkout = workout.removeExercise('ex-1');
      
      expect(updatedWorkout.exercises.length, 1);
      expect(updatedWorkout.exercises.first.id, 'ex-2');
    });
    
    test('✅ TEST 7: Count completed exercises', () {
      final completedSets = [
        ExerciseSet(setNumber: 1, weight: 50.0, reps: 10, isCompleted: true),
        ExerciseSet(setNumber: 2, weight: 50.0, reps: 10, isCompleted: true),
      ];
      
      final incompleteSets = [
        ExerciseSet(setNumber: 1, weight: 30.0, reps: 12, isCompleted: true),
        ExerciseSet(setNumber: 2, weight: 30.0, reps: 12, isCompleted: false),
      ];
      
      final exercise1 = Exercise(
        name: 'Bench Press',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        sets: completedSets,
      );
      
      final exercise2 = Exercise(
        name: 'Dumbbell Flyes',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        sets: incompleteSets,
      );
      
      final workout = Workout(
      id: 'test-id',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        name: 'Chest Day',
        exercises: [exercise1, exercise2],
      );
      
      expect(workout.completedExercises, 1); // Only Bench Press is fully completed
    });
    
    test('✅ TEST 8: Workout with paused status', () {
      final workout = Workout(
      id: 'test-id',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        name: 'Chest Day',
        status: WorkoutStatus.paused,
        startTime: DateTime.now().subtract(const Duration(minutes: 30)),
      );
      
      expect(workout.status, WorkoutStatus.paused);
      expect(workout.isActive, false);
      expect(workout.isCompleted, false);
      expect(workout.duration, isNotNull);
    });
    
    test('✅ TEST 9: Empty workout progress', () {
      final workout = Workout(
      id: 'test-id',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        name: 'Rest Day',
        exercises: [],
      );
      
      expect(workout.totalSets, 0);
      expect(workout.completedSets, 0);
      expect(workout.progressPercentage, 0.0);
      expect(workout.completedExercises, 0);
    });
    
    test('✅ TEST 10: Workout with notes', () {
      final workout = Workout(
      id: 'test-id',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        name: 'Chest Day',
        notes: 'Feeling strong today! Increased weight on bench press.',
      );
      
      expect(workout.notes, isNotNull);
      expect(workout.notes, contains('strong'));
      
      final updatedWorkout = workout.copyWith(
        notes: 'Updated: Hit new PR on bench press!',
      );
      
      expect(updatedWorkout.notes, contains('PR'));
    });
  });
}