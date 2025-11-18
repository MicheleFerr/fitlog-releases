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
}
