import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/timer/domain/entities/rest_timer.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

/// 🔗 INTEGRATION TEST
/// Testa l'integrazione tra Timer, Workout e Firebase
/// Verifica che i componenti funzionino correttamente insieme
class IntegrationTestSuite {
  static void run() {
    group('🔗 Timer + Workout Integration Tests', () {
      late FakeFirebaseFirestore firestore;
      late ProviderContainer container;
      
      setUp(() {
        firestore = FakeFirebaseFirestore();
        container = ProviderContainer();
      });
      
      tearDown(() {
        container.dispose();
      });
      
      test('Starting workout should initialize timer correctly', () async {
        // 1. Crea un workout con esercizi
        final workout = Workout(
          name: 'Morning Workout',
          exercises: [
            Exercise(
              name: 'Bench Press',
              type: ExerciseType.single,
              category: ExerciseCategory.chest,
              sets: [
                ExerciseSet(setNumber: 1, weight: 60, reps: 10),
                ExerciseSet(setNumber: 2, weight: 60, reps: 10),
                ExerciseSet(setNumber: 3, weight: 60, reps: 10),
              ],
              restTime: 180, // 3 minuti di riposo
            ),
          ],
        );
        
        // 2. Salva il workout in Firestore
        await firestore.collection('workouts').doc(workout.id).set(workout.toJson());
        
        // 3. Avvia il workout
        final startedWorkout = workout.startWorkout();
        expect(startedWorkout.status, WorkoutStatus.inProgress);
        expect(startedWorkout.startTime, isNotNull);
        
        // 4. Dopo il primo set, crea un timer di riposo
        final restTimer = RestTimer(
          type: TimerType.rest,
          totalDurationSeconds: workout.exercises.first.restTime ?? 120,
          exerciseName: workout.exercises.first.name,
          currentSet: 1,
          totalSets: workout.exercises.first.sets.length,
          workoutId: workout.id,
        );
        
        // 5. Verifica che il timer sia configurato correttamente
        expect(restTimer.totalDurationSeconds, 180);
        expect(restTimer.exerciseName, 'Bench Press');
        expect(restTimer.currentSet, 1);
        expect(restTimer.totalSets, 3);
        expect(restTimer.workoutId, workout.id);
        
        // 6. Avvia il timer
        final runningTimer = restTimer.start();
        expect(runningTimer.status, TimerStatus.running);
        
        // 7. Salva lo stato del timer in Firestore
        await firestore
            .collection('timers')
            .doc(runningTimer.id)
            .set(runningTimer.toJson());
        
        // 8. Verifica che sia stato salvato correttamente
        final savedTimer = await firestore
            .collection('timers')
            .doc(runningTimer.id)
            .get();
        expect(savedTimer.exists, true);
        expect(savedTimer.data()!['workoutId'], workout.id);
      });
      
      test('Completing exercise set should update workout progress', () async {
        // Setup workout with exercises
        final exercise = Exercise(
          id: 'ex-1',
          name: 'Squats',
          type: ExerciseType.single,
          category: ExerciseCategory.legs,
          sets: [
            ExerciseSet(setNumber: 1, weight: 100, reps: 10, isCompleted: false),
            ExerciseSet(setNumber: 2, weight: 100, reps: 10, isCompleted: false),
            ExerciseSet(setNumber: 3, weight: 100, reps: 10, isCompleted: false),
          ],
        );
        
        final workout = Workout(
          name: 'Leg Day',
          exercises: [exercise],
          status: WorkoutStatus.inProgress,
        );
        
        // Save to Firestore
        await firestore.collection('workouts').doc(workout.id).set(workout.toJson());
        
        // Complete first set
        final updatedSets = [...exercise.sets];
        updatedSets[0] = ExerciseSet(
          setNumber: 1,
          weight: 100,
          reps: 10,
          isCompleted: true,
        );
        
        final updatedExercise = exercise.copyWith(sets: updatedSets);
        final updatedWorkout = workout.updateExercise(exercise.id, updatedExercise);
        
        // Verify progress calculation
        expect(updatedWorkout.completedSets, 1);
        expect(updatedWorkout.totalSets, 3);
        expect(updatedWorkout.progressPercentage, closeTo(0.33, 0.01));
        
        // Start rest timer after completing set
        final restTimer = RestTimer(
          type: TimerType.rest,
          totalDurationSeconds: 120,
          exerciseName: exercise.name,
          currentSet: 1,
          totalSets: 3,
          workoutId: workout.id,
        ).start();
        
        // Save both to Firestore
        await firestore.collection('workouts').doc(workout.id).update(updatedWorkout.toJson());
        await firestore.collection('timers').doc(restTimer.id).set(restTimer.toJson());
        
        // Verify both are linked correctly
        final savedWorkout = await firestore.collection('workouts').doc(workout.id).get();
        final savedTimer = await firestore.collection('timers').doc(restTimer.id).get();
        
        expect(savedWorkout.data()!['id'], savedTimer.data()!['workoutId']);
      });
      
      test('Timer completion should trigger next set preparation', () async {
        // Create timer for rest between sets
        final timer = RestTimer(
          type: TimerType.rest,
          totalDurationSeconds: 10, // Short for testing
          remainingSeconds: 1,
          exerciseName: 'Bench Press',
          currentSet: 1,
          totalSets: 3,
          workoutId: 'workout-123',
          status: TimerStatus.running,
        );
        
        // Simulate timer tick to completion
        final completedTimer = timer.tick();
        
        expect(completedTimer.status, TimerStatus.completed);
        expect(completedTimer.remainingSeconds, 0);
        expect(completedTimer.endTime, isNotNull);
        
        // After timer completes, prepare for next set
        final nextSetTimer = RestTimer(
          type: TimerType.rest,
          totalDurationSeconds: 120,
          exerciseName: 'Bench Press',
          currentSet: 2, // Next set
          totalSets: 3,
          workoutId: 'workout-123',
        );
        
        expect(nextSetTimer.currentSet, 2);
        expect(nextSetTimer.status, TimerStatus.idle);
      });
      
      test('Full workout flow with timer integration', () async {
        // 1. Create workout
        final workout = Workout(
          name: 'Full Body',
          exercises: [
            Exercise(
              id: 'ex-1',
              name: 'Push-ups',
              type: ExerciseType.single,
              category: ExerciseCategory.chest,
              sets: [
                ExerciseSet(setNumber: 1, weight: 0, reps: 20),
                ExerciseSet(setNumber: 2, weight: 0, reps: 20),
              ],
              restTime: 60,
            ),
            Exercise(
              id: 'ex-2',
              name: 'Pull-ups',
              type: ExerciseType.single,
              category: ExerciseCategory.back,
              sets: [
                ExerciseSet(setNumber: 1, weight: 0, reps: 10),
                ExerciseSet(setNumber: 2, weight: 0, reps: 10),
              ],
              restTime: 90,
            ),
          ],
        );
        
        // 2. Start workout
        var currentWorkout = workout.startWorkout();
        await firestore.collection('workouts').doc(workout.id).set(currentWorkout.toJson());
        
        // 3. Complete first set of first exercise
        var updatedExercise = currentWorkout.exercises[0].copyWith(
          sets: [
            ExerciseSet(setNumber: 1, weight: 0, reps: 20, isCompleted: true),
            ExerciseSet(setNumber: 2, weight: 0, reps: 20, isCompleted: false),
          ],
        );
        currentWorkout = currentWorkout.updateExercise('ex-1', updatedExercise);
        
        // 4. Start rest timer
        final restTimer1 = RestTimer(
          type: TimerType.rest,
          totalDurationSeconds: 60,
          exerciseName: 'Push-ups',
          currentSet: 1,
          totalSets: 2,
          workoutId: workout.id,
        ).start();
        
        await firestore.collection('timers').doc(restTimer1.id).set(restTimer1.toJson());
        
        // 5. Simulate timer completion
        final completedTimer1 = restTimer1.copyWith(
          remainingSeconds: 0,
          status: TimerStatus.completed,
        ).complete();
        
        await firestore.collection('timers').doc(restTimer1.id).update(completedTimer1.toJson());
        
        // 6. Complete second set
        updatedExercise = currentWorkout.exercises[0].copyWith(
          sets: [
            ExerciseSet(setNumber: 1, weight: 0, reps: 20, isCompleted: true),
            ExerciseSet(setNumber: 2, weight: 0, reps: 20, isCompleted: true),
          ],
        );
        currentWorkout = currentWorkout.updateExercise('ex-1', updatedExercise);
        
        // 7. Verify first exercise is complete
        expect(currentWorkout.exercises[0].sets.every((s) => s.isCompleted), true);
        
        // 8. Move to second exercise...
        // (continua con il flusso completo)
        
        // 9. Complete workout
        currentWorkout = currentWorkout.completeWorkout();
        expect(currentWorkout.status, WorkoutStatus.completed);
        expect(currentWorkout.endTime, isNotNull);
        
        // 10. Save final state
        await firestore.collection('workouts').doc(workout.id).update(currentWorkout.toJson());
        
        // Verify final state in Firestore
        final savedWorkout = await firestore.collection('workouts').doc(workout.id).get();
        expect(savedWorkout.data()!['status'], 'completed');
      });
    });
  }
}

void main() {
  IntegrationTestSuite.run();
}