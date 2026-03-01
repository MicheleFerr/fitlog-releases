/// AIContext entity tests - RecoveryStatus, WorkoutSummary, toPromptString.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_context.dart';

void main() {
  group('RecoveryStatus', () {
    test('has 3 values', () {
      expect(RecoveryStatus.values.length, 3);
      expect(RecoveryStatus.values, contains(RecoveryStatus.green));
      expect(RecoveryStatus.values, contains(RecoveryStatus.amber));
      expect(RecoveryStatus.values, contains(RecoveryStatus.red));
    });
  });

  group('WorkoutSummary', () {
    test('JSON round-trip', () {
      final summary = WorkoutSummary(
        id: 'w1',
        name: 'Push Day',
        completedAt: DateTime(2025, 3, 1, 10, 0),
        durationMinutes: 45,
        exerciseCount: 6,
      );
      final json = summary.toJson();
      final restored = WorkoutSummary.fromJson(json);
      expect(restored.id, 'w1');
      expect(restored.name, 'Push Day');
      expect(restored.durationMinutes, 45);
      expect(restored.exerciseCount, 6);
    });

    test('nullable fields', () {
      final summary = WorkoutSummary(
        id: 'w1',
        name: 'Quick',
        completedAt: DateTime(2025, 3, 1),
      );
      expect(summary.durationMinutes, isNull);
      expect(summary.exerciseCount, isNull);
    });
  });

  group('AIContext', () {
    test('toPromptString with all fields', () {
      final context = AIContext(
        currentStreak: 5,
        lastWorkout: WorkoutSummary(
          id: 'w1',
          name: 'Push Day',
          completedAt: DateTime.now().subtract(const Duration(hours: 12)),
          durationMinutes: 60,
          exerciseCount: 6,
        ),
        top5OneRM: {'Bench Press': 100, 'Squat': 140},
        recoveryStatus: RecoveryStatus.green,
        userTier: 'gold',
        experienceLevel: 'intermediate',
        fitnessGoal: 'muscle|strength',
      );
      final prompt = context.toPromptString();
      expect(prompt, contains('Tier: gold'));
      expect(prompt, contains('Streak: 5 days'));
      expect(prompt, contains('Push Day'));
      expect(prompt, contains('Bench Press: 100kg'));
      expect(prompt, contains('Squat: 140kg'));
      expect(prompt, contains('Recovery: GREEN'));
      expect(prompt, contains('Experience: intermediate'));
      expect(prompt, contains('Goal: muscle, strength'));
    });

    test('toPromptString without lastWorkout', () {
      final context = AIContext(
        currentStreak: 0,
        top5OneRM: {},
        recoveryStatus: RecoveryStatus.red,
        userTier: 'starter',
      );
      final prompt = context.toPromptString();
      expect(prompt, contains('Last workout: Never'));
      expect(prompt, contains('Recovery: RED'));
    });

    test('toPromptString without optional fields', () {
      final context = AIContext(
        currentStreak: 3,
        top5OneRM: {'Deadlift': 180},
        recoveryStatus: RecoveryStatus.amber,
        userTier: 'silver',
      );
      final prompt = context.toPromptString();
      expect(prompt, isNot(contains('Experience:')));
      expect(prompt, isNot(contains('Goal:')));
    });

    test('JSON round-trip', () {
      final context = AIContext(
        currentStreak: 10,
        top5OneRM: {'Bench': 100},
        recoveryStatus: RecoveryStatus.green,
        userTier: 'platinum',
        experienceLevel: 'athlete',
      );
      final json = context.toJson();
      final restored = AIContext.fromJson(json);
      expect(restored.currentStreak, 10);
      expect(restored.userTier, 'platinum');
      expect(restored.experienceLevel, 'athlete');
      expect(restored.recoveryStatus, RecoveryStatus.green);
      expect(restored.top5OneRM['Bench'], 100);
    });
  });
}
