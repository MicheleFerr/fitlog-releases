import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/home/presentation/providers/home_state.dart';

void main() {
  test('HomeState has all required sections', () {
    final state = HomeState(
      greeting: 'Hello',
      workoutSection: WorkoutSection.empty(),
      aiCoachSection: AICoachSection.empty(),
      streakSection: StreakSection.empty(),
      loadingPhase: LoadingPhase.initial,
    );

    expect(state.greeting, equals('Hello'));
    expect(state.loadingPhase, equals(LoadingPhase.initial));
  });

  test('Section empty factories have correct defaults', () {
    final workout = WorkoutSection.empty();
    expect(workout.hasActiveWorkout, equals(false));
    expect(workout.workoutName, isNull);

    final aiCoach = AICoachSection.empty();
    expect(aiCoach.message, equals(''));

    final streak = StreakSection.empty();
    expect(streak.currentStreak, equals(0));
    expect(streak.bestStreak, equals(0));
  });

  test('HomeState copyWith creates new instance with updated values', () {
    final state = HomeState(
      greeting: 'Hello',
      workoutSection: WorkoutSection.empty(),
      aiCoachSection: AICoachSection.empty(),
      streakSection: StreakSection.empty(),
    );

    final updated = state.copyWith(greeting: 'Goodbye');
    expect(updated.greeting, equals('Goodbye'));
    expect(updated.workoutSection, equals(state.workoutSection));
  });

  test('LoadingPhase enum has all expected phases', () {
    expect(LoadingPhase.values.length, equals(6));
    expect(LoadingPhase.values, contains(LoadingPhase.initial));
    expect(LoadingPhase.values, contains(LoadingPhase.complete));
    expect(LoadingPhase.values, contains(LoadingPhase.error));
  });

  test('Section empty factories return const instances', () {
    // Verify that calling .empty() multiple times returns the same instance
    final workout1 = WorkoutSection.empty();
    final workout2 = WorkoutSection.empty();
    expect(identical(workout1, workout2), isTrue);

    final aiCoach1 = AICoachSection.empty();
    final aiCoach2 = AICoachSection.empty();
    expect(identical(aiCoach1, aiCoach2), isTrue);

    final streak1 = StreakSection.empty();
    final streak2 = StreakSection.empty();
    expect(identical(streak1, streak2), isTrue);
  });
}
