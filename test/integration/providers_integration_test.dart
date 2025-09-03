import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/timer/domain/entities/rest_timer.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';

/// 🔗 PROVIDER INTEGRATION TEST
/// Testa l'integrazione tra diversi Provider Riverpod
/// Verifica che lo stato sia sincronizzato correttamente

// Provider simulati per il test
final workoutProvider = StateNotifierProvider<WorkoutNotifier, Workout?>((ref) {
  return WorkoutNotifier();
});

final timerProvider = StateNotifierProvider<TimerNotifier, RestTimer?>((ref) {
  // Il timer dipende dal workout corrente
  final workout = ref.watch(workoutProvider);
  return TimerNotifier(workout);
});

final workoutStatsProvider = Provider<WorkoutStats>((ref) {
  // Le statistiche dipendono da workout e timer
  final workout = ref.watch(workoutProvider);
  final timer = ref.watch(timerProvider);
  
  if (workout == null) {
    return const WorkoutStats();
  }
  
  return WorkoutStats(
    totalSets: workout.totalSets,
    completedSets: workout.completedSets,
    progress: workout.progressPercentage,
    isTimerActive: timer != null && timer.isActive,
    currentExercise: timer?.exerciseName,
  );
});

// Notifier classes
class WorkoutNotifier extends StateNotifier<Workout?> {
  WorkoutNotifier() : super(null);
  
  void startWorkout(Workout workout) {
    state = workout.startWorkout();
  }
  
  void completeSet(String exerciseId, int setIndex) {
    if (state == null) return;
    
    final exercise = state!.exercises.firstWhere((e) => e.id == exerciseId);
    final updatedSets = [...exercise.sets];
    updatedSets[setIndex] = updatedSets[setIndex].copyWith(isCompleted: true);
    
    final updatedExercise = exercise.copyWith(sets: updatedSets);
    state = state!.updateExercise(exerciseId, updatedExercise);
  }
  
  void finishWorkout() {
    if (state != null) {
      state = state!.completeWorkout();
    }
  }
}

class TimerNotifier extends StateNotifier<RestTimer?> {
  final Workout? workout;
  
  TimerNotifier(this.workout) : super(null);
  
  void startRestTimer(String exerciseName, int currentSet, int totalSets) {
    state = RestTimer(
      type: TimerType.rest,
      totalDurationSeconds: 120,
      exerciseName: exerciseName,
      currentSet: currentSet,
      totalSets: totalSets,
      workoutId: workout?.id,
    ).start();
  }
  
  void pauseTimer() {
    if (state != null && state!.isRunning) {
      state = state!.pause();
    }
  }
  
  void resumeTimer() {
    if (state != null && state!.isPaused) {
      state = state!.resume();
    }
  }
  
  void tick() {
    if (state != null && state!.isRunning) {
      state = state!.tick();
    }
  }
  
  void skipTimer() {
    if (state != null) {
      state = state!.skip();
    }
  }
}

class WorkoutStats {
  final int totalSets;
  final int completedSets;
  final double progress;
  final bool isTimerActive;
  final String? currentExercise;
  
  const WorkoutStats({
    this.totalSets = 0,
    this.completedSets = 0,
    this.progress = 0,
    this.isTimerActive = false,
    this.currentExercise,
  });
}

// Extension per ExerciseSet
extension ExerciseSetX on ExerciseSet {
  ExerciseSet copyWith({
    int? setNumber,
    double? weight,
    int? reps,
    bool? isCompleted,
  }) {
    return ExerciseSet(
      setNumber: setNumber ?? this.setNumber,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

void main() {
  group('🔗 Provider Integration Tests', () {
    late ProviderContainer container;
    
    setUp(() {
      container = ProviderContainer();
    });
    
    tearDown(() {
      container.dispose();
    });
    
    test('Starting workout updates dependent providers', () {
      // Crea un workout di test
      final workout = Workout(
        name: 'Test Workout',
        exercises: [
          Exercise(
            id: 'ex-1',
            name: 'Bench Press',
            type: ExerciseType.single,
            category: ExerciseCategory.chest,
            sets: [
              ExerciseSet(setNumber: 1, weight: 60, reps: 10),
              ExerciseSet(setNumber: 2, weight: 60, reps: 10),
            ],
          ),
        ],
      );
      
      // Avvia il workout
      container.read(workoutProvider.notifier).startWorkout(workout);
      
      // Verifica che il workout sia attivo
      final activeWorkout = container.read(workoutProvider);
      expect(activeWorkout, isNotNull);
      expect(activeWorkout!.status, WorkoutStatus.inProgress);
      
      // Verifica che le statistiche siano aggiornate
      final stats = container.read(workoutStatsProvider);
      expect(stats.totalSets, 2);
      expect(stats.completedSets, 0);
      expect(stats.progress, 0);
    });
    
    test('Completing set triggers timer and updates stats', () {
      // Setup workout
      final workout = Workout(
        name: 'Test Workout',
        exercises: [
          Exercise(
            id: 'ex-1',
            name: 'Squats',
            type: ExerciseType.single,
            category: ExerciseCategory.legs,
            sets: [
              ExerciseSet(setNumber: 1, weight: 100, reps: 8),
              ExerciseSet(setNumber: 2, weight: 100, reps: 8),
              ExerciseSet(setNumber: 3, weight: 100, reps: 8),
            ],
          ),
        ],
      );
      
      // Start workout
      container.read(workoutProvider.notifier).startWorkout(workout);
      
      // Complete first set
      container.read(workoutProvider.notifier).completeSet('ex-1', 0);
      
      // Start rest timer
      container.read(timerProvider.notifier).startRestTimer('Squats', 1, 3);
      
      // Verify timer is active
      final timer = container.read(timerProvider);
      expect(timer, isNotNull);
      expect(timer!.isRunning, true);
      expect(timer.exerciseName, 'Squats');
      
      // Verify stats are updated
      final stats = container.read(workoutStatsProvider);
      expect(stats.completedSets, 1);
      expect(stats.totalSets, 3);
      expect(stats.progress, closeTo(0.33, 0.01));
      expect(stats.isTimerActive, true);
      expect(stats.currentExercise, 'Squats');
    });
    
    test('Timer lifecycle with workout integration', () {
      // Setup and start workout
      final workout = Workout(
        name: 'Timer Test',
        exercises: [
          Exercise(
            id: 'ex-1',
            name: 'Pull-ups',
            type: ExerciseType.single,
            category: ExerciseCategory.back,
            sets: [
              ExerciseSet(setNumber: 1, weight: 0, reps: 10),
              ExerciseSet(setNumber: 2, weight: 0, reps: 10),
            ],
          ),
        ],
      );
      
      container.read(workoutProvider.notifier).startWorkout(workout);
      
      // Complete set and start timer
      container.read(workoutProvider.notifier).completeSet('ex-1', 0);
      container.read(timerProvider.notifier).startRestTimer('Pull-ups', 1, 2);
      
      // Test timer pause/resume
      container.read(timerProvider.notifier).pauseTimer();
      expect(container.read(timerProvider)!.isPaused, true);
      
      container.read(timerProvider.notifier).resumeTimer();
      expect(container.read(timerProvider)!.isRunning, true);
      
      // Test timer tick
      final initialRemaining = container.read(timerProvider)!.remainingSeconds;
      container.read(timerProvider.notifier).tick();
      expect(container.read(timerProvider)!.remainingSeconds, initialRemaining - 1);
      
      // Skip timer
      container.read(timerProvider.notifier).skipTimer();
      expect(container.read(timerProvider)!.isCompleted, true);
      
      // Verify stats reflect timer completion
      final stats = container.read(workoutStatsProvider);
      expect(stats.isTimerActive, false);
    });
    
    test('Full workout flow with multiple exercises', () {
      // Create complex workout
      final workout = Workout(
        name: 'Full Body',
        exercises: [
          Exercise(
            id: 'ex-1',
            name: 'Bench Press',
            type: ExerciseType.single,
            category: ExerciseCategory.chest,
            sets: [
              ExerciseSet(setNumber: 1, weight: 60, reps: 10),
              ExerciseSet(setNumber: 2, weight: 60, reps: 10),
            ],
          ),
          Exercise(
            id: 'ex-2',
            name: 'Squats',
            type: ExerciseType.single,
            category: ExerciseCategory.legs,
            sets: [
              ExerciseSet(setNumber: 1, weight: 100, reps: 8),
              ExerciseSet(setNumber: 2, weight: 100, reps: 8),
            ],
          ),
        ],
      );
      
      // Start workout
      container.read(workoutProvider.notifier).startWorkout(workout);
      
      // Complete all sets of first exercise
      container.read(workoutProvider.notifier).completeSet('ex-1', 0);
      container.read(timerProvider.notifier).startRestTimer('Bench Press', 1, 2);
      container.read(timerProvider.notifier).skipTimer();
      
      container.read(workoutProvider.notifier).completeSet('ex-1', 1);
      container.read(timerProvider.notifier).startRestTimer('Bench Press', 2, 2);
      container.read(timerProvider.notifier).skipTimer();
      
      // Move to second exercise
      container.read(workoutProvider.notifier).completeSet('ex-2', 0);
      container.read(timerProvider.notifier).startRestTimer('Squats', 1, 2);
      container.read(timerProvider.notifier).skipTimer();
      
      container.read(workoutProvider.notifier).completeSet('ex-2', 1);
      
      // Verify all sets completed
      final stats = container.read(workoutStatsProvider);
      expect(stats.completedSets, 4);
      expect(stats.totalSets, 4);
      expect(stats.progress, 1.0);
      
      // Finish workout
      container.read(workoutProvider.notifier).finishWorkout();
      
      // Verify workout is completed
      final completedWorkout = container.read(workoutProvider);
      expect(completedWorkout!.status, WorkoutStatus.completed);
      expect(completedWorkout.endTime, isNotNull);
    });
  });
}