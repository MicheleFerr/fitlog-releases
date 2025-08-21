import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

/// Page Object for Workout screens
class WorkoutPage {
  final PatrolIntegrationTester $;
  
  WorkoutPage(this.$);
  
  // Finders for workout list screen
  Finder get workoutsTab => find.byKey(const Key('workouts_tab'));
  Finder get createWorkoutButton => find.byKey(const Key('create_workout_button'));
  Finder get workoutsList => find.byKey(const Key('workouts_list'));
  Finder workoutCard(String name) => find.byKey(Key('workout_card_$name'));
  
  // Finders for workout creation
  Finder get workoutNameField => find.byKey(const Key('workout_name_field'));
  Finder get addExerciseButton => find.byKey(const Key('add_exercise_button'));
  Finder get exerciseSearchField => find.byKey(const Key('exercise_search'));
  Finder get saveWorkoutButton => find.byKey(const Key('save_workout_button'));
  Finder get cancelWorkoutButton => find.byKey(const Key('cancel_workout_button'));
  
  // Finders for active workout
  Finder get startWorkoutButton => find.byKey(const Key('start_workout_button'));
  Finder get pauseWorkoutButton => find.byKey(const Key('pause_workout_button'));
  Finder get resumeWorkoutButton => find.byKey(const Key('resume_workout_button'));
  Finder get finishWorkoutButton => find.byKey(const Key('finish_workout_button'));
  Finder get workoutTimer => find.byKey(const Key('workout_timer'));
  
  // Finders for exercise execution
  Finder get currentExerciseName => find.byKey(const Key('current_exercise_name'));
  Finder get setNumber => find.byKey(const Key('set_number'));
  Finder get weightInput => find.byKey(const Key('weight_input'));
  Finder get repsInput => find.byKey(const Key('reps_input'));
  Finder get rpeInput => find.byKey(const Key('rpe_input'));
  Finder get completeSetButton => find.byKey(const Key('complete_set_button'));
  Finder get skipSetButton => find.byKey(const Key('skip_set_button'));
  Finder get previousSetsHistory => find.byKey(const Key('previous_sets'));
  
  // Finders for rest timer
  Finder get restTimerDisplay => find.byKey(const Key('rest_timer_display'));
  Finder get skipRestButton => find.byKey(const Key('skip_rest_button'));
  Finder get addThirtySecondsButton => find.byKey(const Key('add_30s_button'));
  
  /// Navigate to workouts tab
  Future<void> navigateToWorkouts() async {
    await $.tap(workoutsTab);
    await $.pumpAndSettle();
  }
  
  /// Create a new workout
  Future<void> createWorkout({
    required String name,
    required List<String> exercises,
  }) async {
    // Tap create workout
    await $.tap(createWorkoutButton);
    await $.pumpAndSettle();
    
    // Enter workout name
    await $.enterText(workoutNameField, name);
    
    // Add exercises
    for (final exercise in exercises) {
      await addExercise(exercise);
    }
    
    // Save workout
    await $.tap(saveWorkoutButton);
    await $.pumpAndSettle();
  }
  
  /// Add an exercise to current workout
  Future<void> addExercise(String exerciseName) async {
    await $.tap(addExerciseButton);
    await $.enterText(exerciseSearchField, exerciseName);
    await $.pumpAndSettle();
    
    // Select first matching exercise
    await $.tap(find.text(exerciseName).first);
    await $.pumpAndSettle();
  }
  
  /// Start a workout by name
  Future<void> startWorkout(String workoutName) async {
    // Find and tap workout card
    await $.tap(workoutCard(workoutName));
    await $.pumpAndSettle();
    
    // Tap start workout
    await $.tap(startWorkoutButton);
    await $.pumpAndSettle();
  }
  
  /// Complete a set with specified parameters
  Future<void> completeSet({
    required double weight,
    required int reps,
    int? rpe,
  }) async {
    // Enter weight
    await $.enterText(weightInput.first, weight.toString());
    
    // Enter reps
    await $.enterText(repsInput.first, reps.toString());
    
    // Enter RPE if provided
    if (rpe != null) {
      await $.enterText(rpeInput.first, rpe.toString());
    }
    
    // Complete the set
    await $.tap(completeSetButton.first);
    await $.pumpAndSettle();
  }
  
  /// Skip current set
  Future<void> skipSet() async {
    await $.tap(skipSetButton.first);
    await $.pumpAndSettle();
  }
  
  /// Skip rest timer
  Future<void> skipRest() async {
    await $.tap(skipRestButton);
    await $.pumpAndSettle();
  }
  
  /// Add 30 seconds to rest timer
  Future<void> addThirtySecondsToRest() async {
    await $.tap(addThirtySecondsButton);
    await $.pumpAndSettle();
  }
  
  /// Pause current workout
  Future<void> pauseWorkout() async {
    await $.tap(pauseWorkoutButton);
    await $.pumpAndSettle();
  }
  
  /// Resume paused workout
  Future<void> resumeWorkout() async {
    await $.tap(resumeWorkoutButton);
    await $.pumpAndSettle();
  }
  
  /// Finish current workout
  Future<void> finishWorkout() async {
    await $.tap(finishWorkoutButton);
    
    // Confirm finish in dialog
    await $.tap(find.text('Finish'));
    await $.pumpAndSettle();
  }
  
  /// Verify workout is active
  Future<bool> isWorkoutActive() async {
    return workoutTimer.evaluate().isNotEmpty;
  }
  
  /// Verify rest timer is running
  Future<bool> isRestTimerRunning() async {
    return restTimerDisplay.evaluate().isNotEmpty;
  }
  
  /// Get current exercise name
  Future<String?> getCurrentExerciseName() async {
    final elements = currentExerciseName.evaluate();
    if (elements.isEmpty) return null;
    
    final widget = elements.first.widget as Text;
    return widget.data;
  }
  
  /// Get rest timer remaining time
  Future<String?> getRestTimerTime() async {
    final elements = restTimerDisplay.evaluate();
    if (elements.isEmpty) return null;
    
    final widget = elements.first.widget as Text;
    return widget.data;
  }
  
  /// Verify workout completed successfully
  Future<bool> isWorkoutCompleted() async {
    // Check for completion message or navigation to summary
    return find.text('Workout Completed').evaluate().isNotEmpty ||
           find.byKey(const Key('workout_summary')).evaluate().isNotEmpty;
  }
}