/// OnboardingState entity tests - JSON round-trip, computed properties,
/// OnboardingStep enum, copyWith.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/entities/onboarding_state.dart';

void main() {
  group('OnboardingState JSON round-trip', () {
    test('all fields', () {
      final state = OnboardingState(
        hasSeenGlobalOnboarding: true,
        currentStep: 3,
        completedSteps: [0, 1, 2],
        canResume: true,
        onboardingVersion: 2,
        lastInteraction: DateTime(2025, 3, 1, 10, 0),
        stepData: {'goal': 'buildMuscle'},
        userExperienceLevel: 'beginner',
        seenOverlays: ['createWorkoutCTA'],
        overlayVersionSeen: 2,
        quickStartCompletedAt: DateTime(2025, 2, 28),
        hasCompletedFirstWorkout: true,
        firstExerciseAddedAt: DateTime(2025, 3, 1, 11, 0),
        firstSetCompletedAt: DateTime(2025, 3, 1, 11, 5),
        hasSeenRestTimerExplanation: true,
        userGoal: 'buildMuscle',
        weeklyWorkoutTarget: 4,
        hasAcceptedLegalDisclaimer: true,
        legalDisclaimerAcceptedAt: DateTime(2025, 2, 27),
      );

      final json = state.toJson();
      final restored = OnboardingState.fromJson(json);

      expect(restored.hasSeenGlobalOnboarding, isTrue);
      expect(restored.currentStep, 3);
      expect(restored.completedSteps, [0, 1, 2]);
      expect(restored.canResume, isTrue);
      expect(restored.onboardingVersion, 2);
      expect(restored.lastInteraction, DateTime(2025, 3, 1, 10, 0));
      expect(restored.stepData, {'goal': 'buildMuscle'});
      expect(restored.userExperienceLevel, 'beginner');
      expect(restored.seenOverlays, ['createWorkoutCTA']);
      expect(restored.overlayVersionSeen, 2);
      expect(restored.quickStartCompletedAt, DateTime(2025, 2, 28));
      expect(restored.hasCompletedFirstWorkout, isTrue);
      expect(restored.firstExerciseAddedAt, DateTime(2025, 3, 1, 11, 0));
      expect(restored.firstSetCompletedAt, DateTime(2025, 3, 1, 11, 5));
      expect(restored.hasSeenRestTimerExplanation, isTrue);
      expect(restored.userGoal, 'buildMuscle');
      expect(restored.weeklyWorkoutTarget, 4);
      expect(restored.hasAcceptedLegalDisclaimer, isTrue);
      expect(restored.legalDisclaimerAcceptedAt, DateTime(2025, 2, 27));
    });

    test('defaults', () {
      final state = const OnboardingState();
      final restored = OnboardingState.fromJson(state.toJson());

      expect(restored.hasSeenGlobalOnboarding, isFalse);
      expect(restored.currentStep, 0);
      expect(restored.completedSteps, isEmpty);
      expect(restored.canResume, isFalse);
      expect(restored.onboardingVersion, 1);
      expect(restored.lastInteraction, isNull);
      expect(restored.stepData, isEmpty);
      expect(restored.userExperienceLevel, isNull);
      expect(restored.seenOverlays, isEmpty);
      expect(restored.overlayVersionSeen, 1);
      expect(restored.quickStartCompletedAt, isNull);
      expect(restored.hasCompletedFirstWorkout, isFalse);
      expect(restored.firstExerciseAddedAt, isNull);
      expect(restored.firstSetCompletedAt, isNull);
      expect(restored.hasSeenRestTimerExplanation, isFalse);
      expect(restored.userGoal, isNull);
      expect(restored.weeklyWorkoutTarget, isNull);
      expect(restored.hasAcceptedLegalDisclaimer, isFalse);
      expect(restored.legalDisclaimerAcceptedAt, isNull);
    });
  });

  group('OnboardingState computed properties', () {
    test('isCompleted when 8+ steps', () {
      final completed = OnboardingState(
        completedSteps: [0, 1, 2, 3, 4, 5, 6, 7],
      );
      expect(completed.isCompleted, isTrue);

      final notCompleted = OnboardingState(
        completedSteps: [0, 1, 2],
      );
      expect(notCompleted.isCompleted, isFalse);
    });

    test('hasStarted', () {
      expect(
        const OnboardingState(completedSteps: [0]).hasStarted,
        isTrue,
      );
      expect(
        const OnboardingState(currentStep: 1).hasStarted,
        isTrue,
      );
      expect(const OnboardingState().hasStarted, isFalse);
    });

    test('isStepCompleted', () {
      final state = OnboardingState(completedSteps: [0, 2, 4]);
      expect(state.isStepCompleted(0), isTrue);
      expect(state.isStepCompleted(1), isFalse);
      expect(state.isStepCompleted(2), isTrue);
    });

    test('progress', () {
      expect(const OnboardingState().progress, 0.0);
      expect(
        OnboardingState(completedSteps: [0, 1, 2, 3]).progress,
        0.5,
      );
      expect(
        OnboardingState(completedSteps: [0, 1, 2, 3, 4, 5, 6, 7]).progress,
        1.0,
      );
    });

    test('hasCompletedQuickStart', () {
      expect(
        OnboardingState(quickStartCompletedAt: DateTime(2025, 1, 1))
            .hasCompletedQuickStart,
        isTrue,
      );
      expect(
        const OnboardingState(userExperienceLevel: 'beginner')
            .hasCompletedQuickStart,
        isTrue,
      );
      expect(const OnboardingState().hasCompletedQuickStart, isFalse);
    });

    test('isBeginner and isExpert', () {
      expect(
        const OnboardingState(userExperienceLevel: 'beginner').isBeginner,
        isTrue,
      );
      expect(
        const OnboardingState(userExperienceLevel: 'expert').isExpert,
        isTrue,
      );
      expect(const OnboardingState().isBeginner, isFalse);
      expect(const OnboardingState().isExpert, isFalse);
    });

    test('hasSeenOverlay', () {
      final state = OnboardingState(seenOverlays: ['addFirstExercise']);
      expect(state.hasSeenOverlay('addFirstExercise'), isTrue);
      expect(state.hasSeenOverlay('otherOverlay'), isFalse);
    });

    test('phase 2 helpers', () {
      expect(
        OnboardingState(firstExerciseAddedAt: DateTime(2025, 1, 1))
            .hasAddedFirstExercise,
        isTrue,
      );
      expect(const OnboardingState().hasAddedFirstExercise, isFalse);

      expect(
        OnboardingState(firstSetCompletedAt: DateTime(2025, 1, 1))
            .hasCompletedFirstSet,
        isTrue,
      );
      expect(const OnboardingState().hasCompletedFirstSet, isFalse);
    });

    test('isInGuidedFirstWorkout', () {
      expect(
        const OnboardingState(userExperienceLevel: 'beginner')
            .isInGuidedFirstWorkout,
        isTrue,
      );
      expect(
        const OnboardingState(
          userExperienceLevel: 'beginner',
          hasCompletedFirstWorkout: true,
        ).isInGuidedFirstWorkout,
        isFalse,
      );
      expect(
        const OnboardingState(userExperienceLevel: 'expert')
            .isInGuidedFirstWorkout,
        isFalse,
      );
    });

    test('shouldShowAddFirstExercise', () {
      expect(
        const OnboardingState(userExperienceLevel: 'beginner')
            .shouldShowAddFirstExercise,
        isTrue,
      );
      // Already added
      expect(
        OnboardingState(
          userExperienceLevel: 'beginner',
          firstExerciseAddedAt: DateTime(2025, 1, 1),
        ).shouldShowAddFirstExercise,
        isFalse,
      );
      // Already seen overlay
      expect(
        const OnboardingState(
          userExperienceLevel: 'beginner',
          seenOverlays: ['addFirstExercise'],
        ).shouldShowAddFirstExercise,
        isFalse,
      );
    });

    test('shouldShowCompleteWorkout', () {
      expect(
        OnboardingState(
          userExperienceLevel: 'beginner',
          firstSetCompletedAt: DateTime(2025, 1, 1),
        ).shouldShowCompleteWorkout,
        isTrue,
      );
      // Already seen
      expect(
        OnboardingState(
          userExperienceLevel: 'beginner',
          firstSetCompletedAt: DateTime(2025, 1, 1),
          seenOverlays: ['completeFirstWorkout'],
        ).shouldShowCompleteWorkout,
        isFalse,
      );
    });

    test('P4 goal helpers', () {
      final withGoal = const OnboardingState(
        userGoal: 'buildMuscle',
        weeklyWorkoutTarget: 4,
      );
      expect(withGoal.hasSelectedGoal, isTrue);
      expect(withGoal.selectedGoalType, 'buildMuscle');
      expect(withGoal.isBuildMuscleGoal, isTrue);
      expect(withGoal.isLoseWeightGoal, isFalse);
      expect(withGoal.isGetStrongerGoal, isFalse);
      expect(withGoal.isStayFitGoal, isFalse);
      expect(withGoal.targetWorkoutsPerWeek, 4);

      expect(const OnboardingState().hasSelectedGoal, isFalse);
      expect(const OnboardingState().targetWorkoutsPerWeek, 3);
    });
  });

  group('OnboardingState copyWith', () {
    test('changes specified fields', () {
      final original = const OnboardingState();
      final copy = original.copyWith(
        hasSeenGlobalOnboarding: true,
        currentStep: 5,
        userGoal: 'loseWeight',
      );
      expect(copy.hasSeenGlobalOnboarding, isTrue);
      expect(copy.currentStep, 5);
      expect(copy.userGoal, 'loseWeight');
      expect(copy.canResume, original.canResume);
    });
  });

  group('OnboardingState equality', () {
    test('equal states', () {
      final a = const OnboardingState(currentStep: 3);
      final b = const OnboardingState(currentStep: 3);
      expect(a, equals(b));
    });

    test('different states', () {
      final a = const OnboardingState(currentStep: 3);
      final b = const OnboardingState(currentStep: 5);
      expect(a, isNot(equals(b)));
    });
  });

  group('OnboardingStep enum', () {
    test('has 8 values', () {
      expect(OnboardingStep.values.length, 8);
    });

    test('fromIndex returns correct step', () {
      expect(OnboardingStep.fromIndex(0), OnboardingStep.welcome);
      expect(OnboardingStep.fromIndex(3), OnboardingStep.createWorkout);
      expect(OnboardingStep.fromIndex(7), OnboardingStep.advancedFeatures);
    });

    test('fromIndex returns welcome for invalid index', () {
      expect(OnboardingStep.fromIndex(99), OnboardingStep.welcome);
      expect(OnboardingStep.fromIndex(-1), OnboardingStep.welcome);
    });

    test('stepIndex and title', () {
      expect(OnboardingStep.welcome.stepIndex, 0);
      expect(OnboardingStep.welcome.title, 'Welcome');
      expect(OnboardingStep.addExercise.stepIndex, 4);
      expect(OnboardingStep.addExercise.title, 'Add Exercise');
    });
  });
}
