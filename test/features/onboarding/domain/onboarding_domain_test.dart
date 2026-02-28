// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/entities/onboarding_state.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/entities/initial/initial_onboarding_data.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/entities/onboarding_tour_step.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/entities/onboarding_tour_config.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/entities/tutorial_state.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/services/onboarding_choice_service.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/strength_standard.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/user_fitness_questionnaire.dart';

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

/// Returns a minimal valid [InitialOnboardingData].
InitialOnboardingData _minimalOnboardingData() {
  return const InitialOnboardingData(
    goal: TrainingGoalUI.buildMuscle,
    sex: BiologicalSex.male,
    age: 25,
    heightCm: 175.0,
    bodyweightKg: 75.0,
    experience: ExperienceLevelUI.beginner,
  );
}

/// Returns an [OnboardingTourStep] positioned at the given index within a
/// 5-step tour.
OnboardingTourStep _tourStep({
  required int position,
  TourStepType type = TourStepType.simple,
  List<String> bulletPointKeys = const [],
  BottomSheetPosition bottomSheetPosition = BottomSheetPosition.bottom,
  Duration? autoAdvanceDuration,
}) {
  return OnboardingTourStep(
    id: 'step_$position',
    titleKey: 'title_$position',
    descriptionKey: 'desc_$position',
    bulletPointKeys: bulletPointKeys,
    type: type,
    autoAdvanceDuration: autoAdvanceDuration,
    targetWidgetKey: 'widget_$position',
    position: position,
    totalSteps: 5,
    bottomSheetPosition: bottomSheetPosition,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // =========================================================================
  // OnboardingState
  // =========================================================================
  group('OnboardingState', () {
    group('default values', () {
      test('creates instance with all expected defaults', () {
        const state = OnboardingState();

        expect(state.hasSeenGlobalOnboarding, isFalse);
        expect(state.currentStep, equals(0));
        expect(state.completedSteps, isEmpty);
        expect(state.canResume, isFalse);
        expect(state.onboardingVersion, equals(1));
        expect(state.lastInteraction, isNull);
        expect(state.stepData, isEmpty);
        expect(state.userExperienceLevel, isNull);
        expect(state.seenOverlays, isEmpty);
        expect(state.overlayVersionSeen, equals(1));
        expect(state.quickStartCompletedAt, isNull);
        expect(state.hasCompletedFirstWorkout, isFalse);
        expect(state.firstExerciseAddedAt, isNull);
        expect(state.firstSetCompletedAt, isNull);
        expect(state.hasSeenRestTimerExplanation, isFalse);
        expect(state.userGoal, isNull);
        expect(state.weeklyWorkoutTarget, isNull);
        expect(state.hasAcceptedLegalDisclaimer, isFalse);
        expect(state.legalDisclaimerAcceptedAt, isNull);
      });
    });

    group('totalSteps constant', () {
      test('is 8', () {
        expect(OnboardingState.totalSteps, equals(8));
      });
    });

    group('isCompleted', () {
      test('returns false when no steps completed', () {
        const state = OnboardingState();
        expect(state.isCompleted, isFalse);
      });

      test('returns false when fewer than totalSteps completed', () {
        const state = OnboardingState(completedSteps: [0, 1, 2, 3]);
        expect(state.isCompleted, isFalse);
      });

      test('returns true when exactly totalSteps (8) are completed', () {
        const state = OnboardingState(completedSteps: [0, 1, 2, 3, 4, 5, 6, 7]);
        expect(state.isCompleted, isTrue);
      });

      test('returns true when more than totalSteps are completed', () {
        // Edge case: duplicates or extra steps should still pass
        const state =
            OnboardingState(completedSteps: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
        expect(state.isCompleted, isTrue);
      });
    });

    group('hasStarted', () {
      test('returns false for fresh state', () {
        const state = OnboardingState();
        expect(state.hasStarted, isFalse);
      });

      test('returns true when currentStep > 0', () {
        const state = OnboardingState(currentStep: 1);
        expect(state.hasStarted, isTrue);
      });

      test('returns true when completedSteps is non-empty', () {
        const state = OnboardingState(completedSteps: [0]);
        expect(state.hasStarted, isTrue);
      });

      test('returns true when both currentStep > 0 and completedSteps non-empty', () {
        const state = OnboardingState(currentStep: 2, completedSteps: [0, 1]);
        expect(state.hasStarted, isTrue);
      });
    });

    group('progress', () {
      test('returns 0.0 for fresh state', () {
        const state = OnboardingState();
        expect(state.progress, equals(0.0));
      });

      test('returns 0.5 when 4 of 8 steps completed', () {
        const state = OnboardingState(completedSteps: [0, 1, 2, 3]);
        expect(state.progress, equals(0.5));
      });

      test('returns 1.0 when all 8 steps completed', () {
        const state = OnboardingState(completedSteps: [0, 1, 2, 3, 4, 5, 6, 7]);
        expect(state.progress, equals(1.0));
      });

      test('progress is proportional to completed steps', () {
        for (var i = 0; i <= 8; i++) {
          final completedSteps = List<int>.generate(i, (index) => index);
          final state = OnboardingState(completedSteps: completedSteps);
          expect(state.progress, closeTo(i / 8.0, 1e-10));
        }
      });
    });

    group('isStepCompleted', () {
      test('returns false for step not in completedSteps', () {
        const state = OnboardingState(completedSteps: [0, 2]);
        expect(state.isStepCompleted(1), isFalse);
      });

      test('returns true for step present in completedSteps', () {
        const state = OnboardingState(completedSteps: [0, 2]);
        expect(state.isStepCompleted(0), isTrue);
        expect(state.isStepCompleted(2), isTrue);
      });

      test('returns false for step beyond completedSteps range', () {
        const state = OnboardingState(completedSteps: [0, 1, 2, 3]);
        expect(state.isStepCompleted(5), isFalse);
      });
    });

    group('hasCompletedQuickStart', () {
      test('returns false when neither quickStartCompletedAt nor userExperienceLevel set',
          () {
        const state = OnboardingState();
        expect(state.hasCompletedQuickStart, isFalse);
      });

      test('returns true when quickStartCompletedAt is set', () {
        final state = OnboardingState(
          quickStartCompletedAt: DateTime(2024, 1, 1),
        );
        expect(state.hasCompletedQuickStart, isTrue);
      });

      test('returns true when userExperienceLevel is set', () {
        const state = OnboardingState(userExperienceLevel: 'beginner');
        expect(state.hasCompletedQuickStart, isTrue);
      });

      test('returns true when both are set', () {
        final state = OnboardingState(
          userExperienceLevel: 'expert',
          quickStartCompletedAt: DateTime(2024, 6, 15),
        );
        expect(state.hasCompletedQuickStart, isTrue);
      });
    });

    group('isBeginner / isExpert', () {
      test('isBeginner returns false by default', () {
        const state = OnboardingState();
        expect(state.isBeginner, isFalse);
      });

      test('isBeginner returns true when userExperienceLevel is "beginner"', () {
        const state = OnboardingState(userExperienceLevel: 'beginner');
        expect(state.isBeginner, isTrue);
        expect(state.isExpert, isFalse);
      });

      test('isExpert returns true when userExperienceLevel is "expert"', () {
        const state = OnboardingState(userExperienceLevel: 'expert');
        expect(state.isExpert, isTrue);
        expect(state.isBeginner, isFalse);
      });

      test('neither flag set for unknown experience level', () {
        const state = OnboardingState(userExperienceLevel: 'intermediate');
        expect(state.isBeginner, isFalse);
        expect(state.isExpert, isFalse);
      });
    });

    group('hasSeenOverlay', () {
      test('returns false when seenOverlays is empty', () {
        const state = OnboardingState();
        expect(state.hasSeenOverlay('anyOverlay'), isFalse);
      });

      test('returns true when overlay id is in seenOverlays', () {
        const state = OnboardingState(seenOverlays: ['overlay1', 'overlay2']);
        expect(state.hasSeenOverlay('overlay1'), isTrue);
        expect(state.hasSeenOverlay('overlay2'), isTrue);
      });

      test('returns false when overlay id is not in seenOverlays', () {
        const state = OnboardingState(seenOverlays: ['overlay1']);
        expect(state.hasSeenOverlay('overlay2'), isFalse);
      });
    });

    group('Phase 2: guided first workout helpers', () {
      test('hasAddedFirstExercise is false when firstExerciseAddedAt is null', () {
        const state = OnboardingState();
        expect(state.hasAddedFirstExercise, isFalse);
      });

      test('hasAddedFirstExercise is true when firstExerciseAddedAt is set', () {
        final state = OnboardingState(firstExerciseAddedAt: DateTime(2024, 1, 1));
        expect(state.hasAddedFirstExercise, isTrue);
      });

      test('hasCompletedFirstSet is false when firstSetCompletedAt is null', () {
        const state = OnboardingState();
        expect(state.hasCompletedFirstSet, isFalse);
      });

      test('hasCompletedFirstSet is true when firstSetCompletedAt is set', () {
        final state = OnboardingState(firstSetCompletedAt: DateTime(2024, 1, 1));
        expect(state.hasCompletedFirstSet, isTrue);
      });

      test('isInGuidedFirstWorkout is true for beginner who has not completed first workout',
          () {
        const state = OnboardingState(
          userExperienceLevel: 'beginner',
          hasCompletedFirstWorkout: false,
        );
        expect(state.isInGuidedFirstWorkout, isTrue);
      });

      test('isInGuidedFirstWorkout is false for expert', () {
        const state = OnboardingState(
          userExperienceLevel: 'expert',
          hasCompletedFirstWorkout: false,
        );
        expect(state.isInGuidedFirstWorkout, isFalse);
      });

      test('isInGuidedFirstWorkout is false when first workout completed', () {
        const state = OnboardingState(
          userExperienceLevel: 'beginner',
          hasCompletedFirstWorkout: true,
        );
        expect(state.isInGuidedFirstWorkout, isFalse);
      });
    });

    group('shouldShowAddFirstExercise', () {
      test('true when beginner, in guided workout, has not added exercise, '
          'has not seen addFirstExercise overlay', () {
        const state = OnboardingState(
          userExperienceLevel: 'beginner',
          hasCompletedFirstWorkout: false,
        );
        expect(state.shouldShowAddFirstExercise, isTrue);
      });

      test('false when exercise already added', () {
        final state = OnboardingState(
          userExperienceLevel: 'beginner',
          hasCompletedFirstWorkout: false,
          firstExerciseAddedAt: DateTime(2024, 1, 1),
        );
        expect(state.shouldShowAddFirstExercise, isFalse);
      });

      test('false when overlay already seen', () {
        const state = OnboardingState(
          userExperienceLevel: 'beginner',
          hasCompletedFirstWorkout: false,
          seenOverlays: ['addFirstExercise'],
        );
        expect(state.shouldShowAddFirstExercise, isFalse);
      });

      test('false when not in guided first workout (expert)', () {
        const state = OnboardingState(
          userExperienceLevel: 'expert',
          hasCompletedFirstWorkout: false,
        );
        expect(state.shouldShowAddFirstExercise, isFalse);
      });
    });

    group('shouldShowCompleteWorkout', () {
      test('true when beginner, in guided workout, has completed a set, '
          'has not seen completeFirstWorkout overlay', () {
        final state = OnboardingState(
          userExperienceLevel: 'beginner',
          hasCompletedFirstWorkout: false,
          firstSetCompletedAt: DateTime(2024, 1, 1),
        );
        expect(state.shouldShowCompleteWorkout, isTrue);
      });

      test('false when no set completed yet', () {
        const state = OnboardingState(
          userExperienceLevel: 'beginner',
          hasCompletedFirstWorkout: false,
        );
        expect(state.shouldShowCompleteWorkout, isFalse);
      });

      test('false when overlay already seen', () {
        final state = OnboardingState(
          userExperienceLevel: 'beginner',
          hasCompletedFirstWorkout: false,
          firstSetCompletedAt: DateTime(2024, 1, 1),
          seenOverlays: const ['completeFirstWorkout'],
        );
        expect(state.shouldShowCompleteWorkout, isFalse);
      });

      test('false when first workout already completed', () {
        final state = OnboardingState(
          userExperienceLevel: 'beginner',
          hasCompletedFirstWorkout: true,
          firstSetCompletedAt: DateTime(2024, 1, 1),
        );
        expect(state.shouldShowCompleteWorkout, isFalse);
      });
    });

    group('hasSelectedGoal (P4 retention)', () {
      test('returns false when neither userGoal nor weeklyWorkoutTarget is set', () {
        const state = OnboardingState();
        expect(state.hasSelectedGoal, isFalse);
      });

      test('returns false when only userGoal is set', () {
        const state = OnboardingState(userGoal: 'buildMuscle');
        expect(state.hasSelectedGoal, isFalse);
      });

      test('returns false when only weeklyWorkoutTarget is set', () {
        const state = OnboardingState(weeklyWorkoutTarget: 3);
        expect(state.hasSelectedGoal, isFalse);
      });

      test('returns true when both userGoal and weeklyWorkoutTarget are set', () {
        const state = OnboardingState(
          userGoal: 'buildMuscle',
          weeklyWorkoutTarget: 4,
        );
        expect(state.hasSelectedGoal, isTrue);
      });
    });

    group('selectedGoalType', () {
      test('returns empty string when userGoal is null', () {
        const state = OnboardingState();
        expect(state.selectedGoalType, equals(''));
      });

      test('returns userGoal when set', () {
        const state = OnboardingState(userGoal: 'loseWeight');
        expect(state.selectedGoalType, equals('loseWeight'));
      });
    });

    group('goal type checks', () {
      test('isBuildMuscleGoal is true only for buildMuscle', () {
        const state = OnboardingState(userGoal: 'buildMuscle');
        expect(state.isBuildMuscleGoal, isTrue);
        expect(state.isLoseWeightGoal, isFalse);
        expect(state.isGetStrongerGoal, isFalse);
        expect(state.isStayFitGoal, isFalse);
      });

      test('isLoseWeightGoal is true only for loseWeight', () {
        const state = OnboardingState(userGoal: 'loseWeight');
        expect(state.isLoseWeightGoal, isTrue);
        expect(state.isBuildMuscleGoal, isFalse);
      });

      test('isGetStrongerGoal is true only for getStronger', () {
        const state = OnboardingState(userGoal: 'getStronger');
        expect(state.isGetStrongerGoal, isTrue);
      });

      test('isStayFitGoal is true only for stayFit', () {
        const state = OnboardingState(userGoal: 'stayFit');
        expect(state.isStayFitGoal, isTrue);
      });

      test('all goal checks are false when userGoal is null', () {
        const state = OnboardingState();
        expect(state.isBuildMuscleGoal, isFalse);
        expect(state.isLoseWeightGoal, isFalse);
        expect(state.isGetStrongerGoal, isFalse);
        expect(state.isStayFitGoal, isFalse);
      });
    });

    group('targetWorkoutsPerWeek', () {
      test('returns 3 when weeklyWorkoutTarget is null', () {
        const state = OnboardingState();
        expect(state.targetWorkoutsPerWeek, equals(3));
      });

      test('returns the set value when weeklyWorkoutTarget is non-null', () {
        const state = OnboardingState(weeklyWorkoutTarget: 5);
        expect(state.targetWorkoutsPerWeek, equals(5));
      });
    });

    group('copyWith immutability', () {
      test('returns new instance with changed fields', () {
        const original = OnboardingState(currentStep: 0);
        final updated = original.copyWith(currentStep: 3);

        expect(updated.currentStep, equals(3));
        expect(original.currentStep, equals(0));
      });

      test('preserves unchanged fields', () {
        const original = OnboardingState(
          userGoal: 'buildMuscle',
          weeklyWorkoutTarget: 4,
          onboardingVersion: 2,
        );
        final updated = original.copyWith(currentStep: 1);

        expect(updated.userGoal, equals('buildMuscle'));
        expect(updated.weeklyWorkoutTarget, equals(4));
        expect(updated.onboardingVersion, equals(2));
        expect(updated.currentStep, equals(1));
      });

      test('can update seenOverlays while preserving other fields', () {
        const original = OnboardingState(
          userExperienceLevel: 'beginner',
          seenOverlays: ['overlay1'],
        );
        final updated = original.copyWith(
          seenOverlays: ['overlay1', 'overlay2'],
        );

        expect(updated.seenOverlays, equals(['overlay1', 'overlay2']));
        expect(updated.userExperienceLevel, equals('beginner'));
      });

      test('can update completedSteps', () {
        const original = OnboardingState(completedSteps: [0]);
        final updated = original.copyWith(completedSteps: [0, 1, 2]);

        expect(updated.completedSteps, equals([0, 1, 2]));
        expect(original.completedSteps, equals([0]));
      });

      test('can update dateTime fields', () {
        final now = DateTime(2025, 3, 15, 10, 30);
        const original = OnboardingState();
        final updated = original.copyWith(
          quickStartCompletedAt: now,
          firstExerciseAddedAt: now,
        );

        expect(updated.quickStartCompletedAt, equals(now));
        expect(updated.firstExerciseAddedAt, equals(now));
        expect(original.quickStartCompletedAt, isNull);
      });
    });

    group('toJson / fromJson round-trip', () {
      test('round-trips minimal state', () {
        const original = OnboardingState();
        final json = original.toJson();
        final restored = OnboardingState.fromJson(json);

        expect(restored.hasSeenGlobalOnboarding,
            equals(original.hasSeenGlobalOnboarding));
        expect(restored.currentStep, equals(original.currentStep));
        expect(restored.completedSteps, equals(original.completedSteps));
        expect(restored.userExperienceLevel, isNull);
        expect(restored.userGoal, isNull);
        expect(restored.weeklyWorkoutTarget, isNull);
      });

      test('round-trips a fully populated state', () {
        final timestamp = DateTime(2025, 1, 10, 8, 0);
        final original = OnboardingState(
          hasSeenGlobalOnboarding: true,
          currentStep: 5,
          completedSteps: const [0, 1, 2, 3, 4],
          canResume: true,
          onboardingVersion: 2,
          lastInteraction: timestamp,
          stepData: const {'key': 'value'},
          userExperienceLevel: 'beginner',
          seenOverlays: const ['overlay1'],
          overlayVersionSeen: 2,
          quickStartCompletedAt: timestamp,
          hasCompletedFirstWorkout: true,
          firstExerciseAddedAt: timestamp,
          firstSetCompletedAt: timestamp,
          hasSeenRestTimerExplanation: true,
          userGoal: 'buildMuscle',
          weeklyWorkoutTarget: 5,
          hasAcceptedLegalDisclaimer: true,
          legalDisclaimerAcceptedAt: timestamp,
        );

        final json = original.toJson();
        final restored = OnboardingState.fromJson(json);

        expect(restored.hasSeenGlobalOnboarding, isTrue);
        expect(restored.currentStep, equals(5));
        expect(restored.completedSteps, equals([0, 1, 2, 3, 4]));
        expect(restored.canResume, isTrue);
        expect(restored.onboardingVersion, equals(2));
        expect(restored.lastInteraction, equals(timestamp));
        expect(restored.stepData, equals({'key': 'value'}));
        expect(restored.userExperienceLevel, equals('beginner'));
        expect(restored.seenOverlays, equals(['overlay1']));
        expect(restored.overlayVersionSeen, equals(2));
        expect(restored.quickStartCompletedAt, equals(timestamp));
        expect(restored.hasCompletedFirstWorkout, isTrue);
        expect(restored.firstExerciseAddedAt, equals(timestamp));
        expect(restored.firstSetCompletedAt, equals(timestamp));
        expect(restored.hasSeenRestTimerExplanation, isTrue);
        expect(restored.userGoal, equals('buildMuscle'));
        expect(restored.weeklyWorkoutTarget, equals(5));
        expect(restored.hasAcceptedLegalDisclaimer, isTrue);
        expect(restored.legalDisclaimerAcceptedAt, equals(timestamp));
      });

      test('fromJson handles missing optional fields gracefully', () {
        const json = <String, dynamic>{};
        final state = OnboardingState.fromJson(json);

        expect(state.hasSeenGlobalOnboarding, isFalse);
        expect(state.currentStep, equals(0));
        expect(state.completedSteps, isEmpty);
        expect(state.canResume, isFalse);
        expect(state.onboardingVersion, equals(1));
        expect(state.lastInteraction, isNull);
        expect(state.userExperienceLevel, isNull);
        expect(state.seenOverlays, isEmpty);
        expect(state.quickStartCompletedAt, isNull);
      });

      test('toJson serializes DateTime fields as ISO 8601 strings', () {
        final timestamp = DateTime(2025, 2, 28, 12, 0, 0);
        final state = OnboardingState(lastInteraction: timestamp);
        final json = state.toJson();

        expect(json['lastInteraction'], equals(timestamp.toIso8601String()));
      });

      test('toJson serializes null DateTime fields as null', () {
        const state = OnboardingState();
        final json = state.toJson();

        expect(json['lastInteraction'], isNull);
        expect(json['quickStartCompletedAt'], isNull);
      });
    });

    group('equality', () {
      test('two identical states are equal', () {
        const a = OnboardingState(currentStep: 2, completedSteps: [0, 1]);
        const b = OnboardingState(currentStep: 2, completedSteps: [0, 1]);
        expect(a, equals(b));
      });

      test('states with different currentStep are not equal', () {
        const a = OnboardingState(currentStep: 1);
        const b = OnboardingState(currentStep: 2);
        expect(a, isNot(equals(b)));
      });

      test('states with different completedSteps lengths are not equal', () {
        const a = OnboardingState(completedSteps: [0]);
        const b = OnboardingState(completedSteps: [0, 1]);
        expect(a, isNot(equals(b)));
      });

      test('same instance is equal to itself', () {
        const state = OnboardingState(currentStep: 3);
        expect(state, equals(state));
      });
    });

    group('toString', () {
      test('contains progress percentage', () {
        const state = OnboardingState(completedSteps: [0, 1, 2, 3]);
        final str = state.toString();
        expect(str, contains('50.0%'));
      });

      test('contains currentStep', () {
        const state = OnboardingState(currentStep: 3);
        final str = state.toString();
        expect(str, contains('3'));
      });
    });
  });

  // =========================================================================
  // OnboardingStep enum
  // =========================================================================
  group('OnboardingStep', () {
    test('has 8 values matching totalSteps', () {
      expect(OnboardingStep.values.length, equals(8));
    });

    test('each value has a unique stepIndex from 0 to 7', () {
      final indices = OnboardingStep.values.map((s) => s.stepIndex).toList();
      expect(indices, equals([0, 1, 2, 3, 4, 5, 6, 7]));
    });

    test('fromIndex returns correct step', () {
      expect(OnboardingStep.fromIndex(0), equals(OnboardingStep.welcome));
      expect(OnboardingStep.fromIndex(3), equals(OnboardingStep.createWorkout));
      expect(OnboardingStep.fromIndex(7), equals(OnboardingStep.advancedFeatures));
    });

    test('fromIndex returns welcome for out-of-range index', () {
      expect(OnboardingStep.fromIndex(99), equals(OnboardingStep.welcome));
      expect(OnboardingStep.fromIndex(-1), equals(OnboardingStep.welcome));
    });

    test('all steps have non-empty titles', () {
      for (final step in OnboardingStep.values) {
        expect(step.title, isNotEmpty);
      }
    });
  });

  // =========================================================================
  // InitialOnboardingData
  // =========================================================================
  group('InitialOnboardingData', () {
    group('construction', () {
      test('creates with required fields', () {
        final data = _minimalOnboardingData();

        expect(data.goal, equals(TrainingGoalUI.buildMuscle));
        expect(data.sex, equals(BiologicalSex.male));
        expect(data.age, equals(25));
        expect(data.heightCm, equals(175.0));
        expect(data.bodyweightKg, equals(75.0));
        expect(data.experience, equals(ExperienceLevelUI.beginner));
      });

      test('applies correct defaults for optional fields', () {
        final data = _minimalOnboardingData();

        expect(data.healthKitConnected, isFalse);
        expect(data.healthKitPermissionsGranted, isEmpty);
        expect(data.workoutsPerWeek, equals(3));
        expect(data.completedAt, isNull);
      });

      test('overrides optional fields when provided', () {
        final completedAt = DateTime(2025, 1, 5);
        final data = InitialOnboardingData(
          goal: TrainingGoalUI.getStronger,
          sex: BiologicalSex.female,
          age: 30,
          heightCm: 165.0,
          bodyweightKg: 60.0,
          experience: ExperienceLevelUI.experienced,
          healthKitConnected: true,
          healthKitPermissionsGranted: const ['steps', 'heartRate'],
          workoutsPerWeek: 5,
          completedAt: completedAt,
        );

        expect(data.healthKitConnected, isTrue);
        expect(data.healthKitPermissionsGranted, equals(['steps', 'heartRate']));
        expect(data.workoutsPerWeek, equals(5));
        expect(data.completedAt, equals(completedAt));
      });
    });

    group('copyWith (freezed)', () {
      test('returns same values when no arguments provided', () {
        final original = _minimalOnboardingData();
        final copy = original.copyWith();

        expect(copy.goal, equals(original.goal));
        expect(copy.sex, equals(original.sex));
        expect(copy.age, equals(original.age));
        expect(copy.heightCm, equals(original.heightCm));
        expect(copy.bodyweightKg, equals(original.bodyweightKg));
        expect(copy.experience, equals(original.experience));
      });

      test('updates specified field while preserving the rest', () {
        final original = _minimalOnboardingData();
        final updated = original.copyWith(workoutsPerWeek: 6);

        expect(updated.workoutsPerWeek, equals(6));
        expect(updated.goal, equals(original.goal));
        expect(updated.age, equals(original.age));
      });

      test('immutability: original is not modified', () {
        final original = _minimalOnboardingData();
        final _ = original.copyWith(age: 99);

        expect(original.age, equals(25));
      });
    });

    group('toQuestionnaire', () {
      test('maps buildMuscle goal to hypertrophy TrainingGoal', () {
        final data = _minimalOnboardingData();
        final questionnaire = data.toQuestionnaire();

        expect(questionnaire.trainingGoal, equals(TrainingGoal.hypertrophy));
      });

      test('maps getStronger goal to strength TrainingGoal', () {
        final data = _minimalOnboardingData().copyWith(
          goal: TrainingGoalUI.getStronger,
        );
        final questionnaire = data.toQuestionnaire();

        expect(questionnaire.trainingGoal, equals(TrainingGoal.strength));
      });

      test('maps endurance goal to endurance TrainingGoal', () {
        final data = _minimalOnboardingData().copyWith(
          goal: TrainingGoalUI.endurance,
        );
        final questionnaire = data.toQuestionnaire();

        expect(questionnaire.trainingGoal, equals(TrainingGoal.endurance));
      });

      test('maps stayFit goal to hypertrophy TrainingGoal', () {
        final data = _minimalOnboardingData().copyWith(
          goal: TrainingGoalUI.stayFit,
        );
        final questionnaire = data.toQuestionnaire();

        expect(questionnaire.trainingGoal, equals(TrainingGoal.hypertrophy));
      });

      test('maps beginner experience to novice ExperienceLevel', () {
        final data = _minimalOnboardingData();
        final questionnaire = data.toQuestionnaire();

        expect(questionnaire.experienceLevel, equals(ExperienceLevel.novice));
      });

      test('maps someExperience to intermediate ExperienceLevel', () {
        final data = _minimalOnboardingData().copyWith(
          experience: ExperienceLevelUI.someExperience,
        );
        final questionnaire = data.toQuestionnaire();

        expect(questionnaire.experienceLevel, equals(ExperienceLevel.intermediate));
      });

      test('maps experienced to advanced ExperienceLevel', () {
        final data = _minimalOnboardingData().copyWith(
          experience: ExperienceLevelUI.experienced,
        );
        final questionnaire = data.toQuestionnaire();

        expect(questionnaire.experienceLevel, equals(ExperienceLevel.advanced));
      });

      test('maps athlete to elite ExperienceLevel', () {
        final data = _minimalOnboardingData().copyWith(
          experience: ExperienceLevelUI.athlete,
        );
        final questionnaire = data.toQuestionnaire();

        expect(questionnaire.experienceLevel, equals(ExperienceLevel.elite));
      });

      test('preserves bodyweight, age, height, sex', () {
        const data = InitialOnboardingData(
          goal: TrainingGoalUI.buildMuscle,
          sex: BiologicalSex.female,
          age: 32,
          heightCm: 162.0,
          bodyweightKg: 58.5,
          experience: ExperienceLevelUI.experienced,
        );
        final questionnaire = data.toQuestionnaire();

        expect(questionnaire.bodyweightKg, equals(58.5));
        expect(questionnaire.age, equals(32));
        expect(questionnaire.heightCm, equals(162.0));
        expect(questionnaire.sex, equals(BiologicalSex.female));
      });

      test('uses provided completedAt if set', () {
        final completedAt = DateTime(2025, 5, 20);
        final data = _minimalOnboardingData().copyWith(completedAt: completedAt);
        final questionnaire = data.toQuestionnaire();

        expect(questionnaire.completedAt, equals(completedAt));
      });

      test('uses a non-null completedAt even when data.completedAt is null', () {
        final data = _minimalOnboardingData();
        expect(data.completedAt, isNull);

        final questionnaire = data.toQuestionnaire();
        // Should use DateTime.now() internally, so it must not be null
        expect(questionnaire.completedAt, isNotNull);
      });
    });
  });

  // =========================================================================
  // TrainingGoalUI extension
  // =========================================================================
  group('TrainingGoalUI', () {
    test('each value returns a non-empty icon', () {
      for (final goal in TrainingGoalUI.values) {
        expect(goal.icon, isNotEmpty);
      }
    });

    test('all values map to a TrainingGoal', () {
      for (final goal in TrainingGoalUI.values) {
        expect(() => goal.toTrainingGoal(), returnsNormally);
      }
    });
  });

  // =========================================================================
  // ExperienceLevelUI extension
  // =========================================================================
  group('ExperienceLevelUI', () {
    test('each value returns a positive estimatedMonths', () {
      for (final level in ExperienceLevelUI.values) {
        expect(level.estimatedMonths, greaterThan(0));
      }
    });

    test('estimated months are in ascending order', () {
      final months = ExperienceLevelUI.values.map((e) => e.estimatedMonths).toList();
      for (var i = 0; i < months.length - 1; i++) {
        expect(months[i], lessThan(months[i + 1]));
      }
    });

    test('each value returns a non-empty icon', () {
      for (final level in ExperienceLevelUI.values) {
        expect(level.icon, isNotEmpty);
      }
    });

    test('all values map to an ExperienceLevel', () {
      for (final level in ExperienceLevelUI.values) {
        expect(() => level.toExperienceLevel(), returnsNormally);
      }
    });
  });

  // =========================================================================
  // OnboardingTourStep
  // =========================================================================
  group('OnboardingTourStep', () {
    group('isSimple / isComplex', () {
      test('simple step reports isSimple true and isComplex false', () {
        final step = _tourStep(position: 0, type: TourStepType.simple);
        expect(step.isSimple, isTrue);
        expect(step.isComplex, isFalse);
      });

      test('complex step reports isComplex true and isSimple false', () {
        final step = _tourStep(position: 0, type: TourStepType.complex);
        expect(step.isComplex, isTrue);
        expect(step.isSimple, isFalse);
      });
    });

    group('hasBulletPoints', () {
      test('returns false when bulletPointKeys is empty', () {
        final step = _tourStep(position: 0);
        expect(step.hasBulletPoints, isFalse);
      });

      test('returns true when bulletPointKeys is non-empty', () {
        final step = _tourStep(
          position: 0,
          bulletPointKeys: ['point1', 'point2'],
        );
        expect(step.hasBulletPoints, isTrue);
      });
    });

    group('progress', () {
      test('first step (position 0) has progress 1/5 = 0.2 for 5-step tour', () {
        final step = _tourStep(position: 0);
        expect(step.progress, closeTo(0.2, 1e-10));
      });

      test('last step (position 4) has progress 5/5 = 1.0 for 5-step tour', () {
        final step = _tourStep(position: 4);
        expect(step.progress, equals(1.0));
      });

      test('middle step has correct fractional progress', () {
        final step = _tourStep(position: 2);
        expect(step.progress, closeTo(3.0 / 5.0, 1e-10));
      });
    });

    group('isFirst / isLast', () {
      test('step at position 0 is first', () {
        final step = _tourStep(position: 0);
        expect(step.isFirst, isTrue);
        expect(step.isLast, isFalse);
      });

      test('step at last position (totalSteps - 1) is last', () {
        final step = _tourStep(position: 4); // totalSteps = 5
        expect(step.isLast, isTrue);
        expect(step.isFirst, isFalse);
      });

      test('middle step is neither first nor last', () {
        final step = _tourStep(position: 2);
        expect(step.isFirst, isFalse);
        expect(step.isLast, isFalse);
      });
    });

    group('bottomSheetPosition', () {
      test('defaults to bottom', () {
        final step = _tourStep(position: 0);
        expect(step.bottomSheetPosition, equals(BottomSheetPosition.bottom));
      });

      test('can be set to top', () {
        final step = _tourStep(
          position: 0,
          bottomSheetPosition: BottomSheetPosition.top,
        );
        expect(step.bottomSheetPosition, equals(BottomSheetPosition.top));
      });
    });

    group('autoAdvanceDuration', () {
      test('defaults to null when not provided', () {
        final step = _tourStep(position: 0);
        expect(step.autoAdvanceDuration, isNull);
      });

      test('stores provided duration', () {
        final step = _tourStep(
          position: 0,
          autoAdvanceDuration: const Duration(seconds: 12),
        );
        expect(step.autoAdvanceDuration, equals(const Duration(seconds: 12)));
      });
    });

    group('freezed equality', () {
      test('two identical steps are equal', () {
        final a = _tourStep(position: 1);
        final b = _tourStep(position: 1);
        expect(a, equals(b));
      });

      test('steps with different positions are not equal', () {
        final a = _tourStep(position: 1);
        final b = _tourStep(position: 2);
        expect(a, isNot(equals(b)));
      });
    });
  });

  // =========================================================================
  // OnboardingTourConfig
  // =========================================================================
  group('OnboardingTourConfig', () {
    test('totalSteps constant equals 10', () {
      expect(OnboardingTourConfig.totalSteps, equals(10));
    });

    test('allSteps has totalSteps entries', () {
      expect(
        OnboardingTourConfig.allSteps.length,
        equals(OnboardingTourConfig.totalSteps),
      );
    });

    test('steps are in sequential order from 0 to totalSteps - 1', () {
      final positions =
          OnboardingTourConfig.allSteps.map((s) => s.position).toList();
      for (var i = 0; i < positions.length; i++) {
        expect(positions[i], equals(i));
      }
    });

    test('all steps report the same totalSteps', () {
      for (final step in OnboardingTourConfig.allSteps) {
        expect(step.totalSteps, equals(OnboardingTourConfig.totalSteps));
      }
    });

    test('all step ids are unique', () {
      final ids = OnboardingTourConfig.allSteps.map((s) => s.id).toList();
      expect(ids.toSet().length, equals(ids.length));
    });

    test('all steps have non-empty required string fields', () {
      for (final step in OnboardingTourConfig.allSteps) {
        expect(step.id, isNotEmpty);
        expect(step.titleKey, isNotEmpty);
        expect(step.descriptionKey, isNotEmpty);
        expect(step.targetWidgetKey, isNotEmpty);
      }
    });

    test('simpleStepDuration is 12 seconds', () {
      expect(OnboardingTourConfig.simpleStepDuration, equals(const Duration(seconds: 12)));
    });

    test('briefStepDuration is 8 seconds', () {
      expect(OnboardingTourConfig.briefStepDuration, equals(const Duration(seconds: 8)));
    });

    test('last step is complex (user-controlled)', () {
      final lastStep = OnboardingTourConfig.allSteps.last;
      expect(lastStep.isComplex, isTrue);
      expect(lastStep.autoAdvanceDuration, isNull);
    });

    group('getStepById', () {
      test('returns step for known id', () {
        final step = OnboardingTourConfig.getStepById('settings');
        expect(step, isNotNull);
        expect(step!.id, equals('settings'));
      });

      test('returns null for unknown id', () {
        final step = OnboardingTourConfig.getStepById('nonExistentId');
        expect(step, isNull);
      });

      test('returned step is correct for "xpProgress"', () {
        final step = OnboardingTourConfig.getStepById('xpProgress');
        expect(step, isNotNull);
        expect(step!.position, equals(0));
      });
    });

    group('getStepByPosition', () {
      test('returns step for valid position 0', () {
        final step = OnboardingTourConfig.getStepByPosition(0);
        expect(step, isNotNull);
        expect(step!.position, equals(0));
      });

      test('returns step for last valid position', () {
        final step =
            OnboardingTourConfig.getStepByPosition(OnboardingTourConfig.totalSteps - 1);
        expect(step, isNotNull);
        expect(step!.position, equals(OnboardingTourConfig.totalSteps - 1));
      });

      test('returns null for negative position', () {
        expect(OnboardingTourConfig.getStepByPosition(-1), isNull);
      });

      test('returns null for position >= totalSteps', () {
        expect(
          OnboardingTourConfig.getStepByPosition(OnboardingTourConfig.totalSteps),
          isNull,
        );
      });
    });
  });

  // =========================================================================
  // TutorialState
  // =========================================================================
  group('TutorialState', () {
    group('factory constructors', () {
      test('initial() returns a fresh empty state', () {
        final state = TutorialState.initial();

        expect(state.seenTutorialsList, isEmpty);
        expect(state.dismissedHintsList, isEmpty);
        expect(state.lastDismissTimeList, isEmpty);
        expect(state.totalWorkouts, equals(0));
        expect(state.firstWorkoutDate, isNull);
        expect(state.tutorialsEnabled, isTrue);
      });

      test('fromSets() converts Sets and Maps to Lists correctly', () {
        final dt = DateTime(2025, 1, 1, 12, 0, 0, 0, 0); // no microseconds
        final state = TutorialState.fromSets(
          seenTutorials: {'tutorial_a', 'tutorial_b'},
          dismissedHints: {'hint_x'},
          lastDismissTime: {'hint_x': dt},
          totalWorkouts: 5,
          firstWorkoutDate: dt,
        );

        expect(state.seenTutorialsList, containsAll(['tutorial_a', 'tutorial_b']));
        expect(state.seenTutorialsList.length, equals(2));
        expect(state.dismissedHintsList, equals(['hint_x']));
        expect(state.totalWorkouts, equals(5));
        expect(state.firstWorkoutDate, equals(dt));

        // The lastDismissTime list should encode the entry
        expect(state.lastDismissTimeList.length, equals(1));
        expect(state.lastDismissTimeList.first, contains('hint_x'));
      });
    });

    group('convenience getters', () {
      test('seenTutorials returns Set view', () {
        const state = TutorialState(
          seenTutorialsList: ['a', 'b', 'a'], // intentional duplicate
        );
        // Set deduplicates
        expect(state.seenTutorials, equals({'a', 'b'}));
      });

      test('dismissedHints returns Set view', () {
        const state = TutorialState(dismissedHintsList: ['h1', 'h2']);
        expect(state.dismissedHints, equals({'h1', 'h2'}));
      });

      test('lastDismissTime parses encoded entries correctly', () {
        final dt = DateTime(2025, 3, 10, 8, 30, 0);
        final encoded = 'myHint:${dt.toIso8601String()}';
        final state = TutorialState(lastDismissTimeList: [encoded]);

        final map = state.lastDismissTime;
        expect(map.containsKey('myHint'), isTrue);
        expect(map['myHint'], equals(dt));
      });

      test('lastDismissTime handles malformed entries gracefully', () {
        const state = TutorialState(
          lastDismissTimeList: ['badEntry', ':alsoInvalid'],
        );
        // Should not throw; malformed entries are skipped
        expect(() => state.lastDismissTime, returnsNormally);
      });
    });

    group('hasSeen', () {
      test('returns false for tutorial not in seenTutorialsList', () {
        const state = TutorialState(seenTutorialsList: ['a']);
        expect(state.hasSeen('b'), isFalse);
      });

      test('returns true for tutorial present in seenTutorialsList', () {
        const state = TutorialState(seenTutorialsList: ['logging_set', 'rest_timer']);
        expect(state.hasSeen('logging_set'), isTrue);
      });
    });

    group('canShowHint', () {
      test('returns true when hint has never been dismissed', () {
        const state = TutorialState();
        expect(state.canShowHint('newHint'), isTrue);
      });

      test('returns true when hint was dismissed more than 24h ago', () {
        final oldDismiss = DateTime.now().subtract(const Duration(hours: 25));
        final encoded = 'myHint:${oldDismiss.toIso8601String()}';
        final state = TutorialState(
          dismissedHintsList: const ['myHint'],
          lastDismissTimeList: [encoded],
        );
        expect(state.canShowHint('myHint'), isTrue);
      });

      test('returns false when hint was dismissed within the last 24h', () {
        final recentDismiss = DateTime.now().subtract(const Duration(hours: 2));
        final encoded = 'freshHint:${recentDismiss.toIso8601String()}';
        final state = TutorialState(
          dismissedHintsList: const ['freshHint'],
          lastDismissTimeList: [encoded],
        );
        expect(state.canShowHint('freshHint'), isFalse);
      });

      test('returns true when hint is dismissed but no timestamp recorded', () {
        const state = TutorialState(
          dismissedHintsList: ['noTimestampHint'],
          // No corresponding entry in lastDismissTimeList
        );
        expect(state.canShowHint('noTimestampHint'), isTrue);
      });
    });

    group('isNewUser / hasCompletedFirstWorkout', () {
      test('isNewUser is true when totalWorkouts < 3', () {
        const state = TutorialState(totalWorkouts: 0);
        expect(state.isNewUser, isTrue);
      });

      test('isNewUser is false when totalWorkouts >= 3', () {
        const state = TutorialState(totalWorkouts: 3);
        expect(state.isNewUser, isFalse);
      });

      test('hasCompletedFirstWorkout is false when totalWorkouts == 0', () {
        const state = TutorialState(totalWorkouts: 0);
        expect(state.hasCompletedFirstWorkout, isFalse);
      });

      test('hasCompletedFirstWorkout is true when totalWorkouts > 0', () {
        const state = TutorialState(totalWorkouts: 1);
        expect(state.hasCompletedFirstWorkout, isTrue);
      });
    });

    group('copyWith immutability', () {
      test('returns new instance without modifying original', () {
        const original = TutorialState(totalWorkouts: 2);
        final updated = original.copyWith(totalWorkouts: 10);

        expect(updated.totalWorkouts, equals(10));
        expect(original.totalWorkouts, equals(2));
      });

      test('can update via Set parameters', () {
        const original = TutorialState(seenTutorialsList: ['a']);
        final updated = original.copyWith(seenTutorials: {'a', 'b'});

        expect(updated.seenTutorialsList, containsAll(['a', 'b']));
        expect(original.seenTutorialsList, equals(['a']));
      });

      test('can update dismissedHints via Set parameter', () {
        const original = TutorialState();
        final updated = original.copyWith(dismissedHints: {'h1', 'h2'});

        expect(updated.dismissedHintsList, containsAll(['h1', 'h2']));
      });

      test('can update lastDismissTime via Map parameter', () {
        const original = TutorialState();
        final dt = DateTime(2025, 6, 1);
        final updated = original.copyWith(lastDismissTime: {'hintA': dt});

        expect(updated.lastDismissTimeList.length, equals(1));
        expect(updated.lastDismissTimeList.first, contains('hintA'));
      });

      test('List parameter takes priority over Set parameter for seenTutorials', () {
        const original = TutorialState();
        final updated = original.copyWith(
          seenTutorialsList: ['explicit'],
          seenTutorials: {'ignored'},
        );
        expect(updated.seenTutorialsList, equals(['explicit']));
      });
    });

    group('toJson / fromJson round-trip', () {
      test('round-trips initial state', () {
        final original = TutorialState.initial();
        final json = original.toJson();
        final restored = TutorialState.fromJson(json);

        expect(restored, equals(original));
      });

      test('round-trips state with data', () {
        final dt = DateTime(2025, 4, 1, 9, 0, 0);
        final original = TutorialState(
          seenTutorialsList: const ['t1', 't2'],
          dismissedHintsList: const ['h1'],
          lastDismissTimeList: ['h1:${dt.toIso8601String()}'],
          totalWorkouts: 7,
          firstWorkoutDate: dt,
          tutorialsEnabled: false,
        );

        final json = original.toJson();
        final restored = TutorialState.fromJson(json);

        expect(restored.seenTutorialsList, equals(['t1', 't2']));
        expect(restored.dismissedHintsList, equals(['h1']));
        expect(restored.totalWorkouts, equals(7));
        expect(restored.firstWorkoutDate, equals(dt));
        expect(restored.tutorialsEnabled, isFalse);
      });

      test('fromJson handles missing optional fields with defaults', () {
        const json = <String, dynamic>{};
        final state = TutorialState.fromJson(json);

        expect(state.seenTutorialsList, isEmpty);
        expect(state.totalWorkouts, equals(0));
        expect(state.tutorialsEnabled, isTrue);
        expect(state.firstWorkoutDate, isNull);
      });
    });

    group('equality', () {
      test('two states with same data are equal', () {
        const a = TutorialState(
          seenTutorialsList: ['t1'],
          totalWorkouts: 3,
        );
        const b = TutorialState(
          seenTutorialsList: ['t1'],
          totalWorkouts: 3,
        );
        expect(a, equals(b));
      });

      test('states differing in totalWorkouts are not equal', () {
        const a = TutorialState(totalWorkouts: 1);
        const b = TutorialState(totalWorkouts: 2);
        expect(a, isNot(equals(b)));
      });

      test('states differing in seenTutorialsList are not equal', () {
        const a = TutorialState(seenTutorialsList: ['a']);
        const b = TutorialState(seenTutorialsList: ['b']);
        expect(a, isNot(equals(b)));
      });
    });

    group('toString', () {
      test('includes seen count, dismissed count, and workout count', () {
        const state = TutorialState(
          seenTutorialsList: ['a', 'b'],
          dismissedHintsList: ['c'],
          totalWorkouts: 5,
        );
        final str = state.toString();
        expect(str, contains('2')); // seen count
        expect(str, contains('1')); // dismissed count
        expect(str, contains('5')); // workouts count
      });
    });
  });

  // =========================================================================
  // OnboardingChoice enum
  // =========================================================================
  group('OnboardingChoice', () {
    test('has three values: guided, explore, notAsked', () {
      expect(OnboardingChoice.values.length, equals(3));
      expect(OnboardingChoice.values, contains(OnboardingChoice.guided));
      expect(OnboardingChoice.values, contains(OnboardingChoice.explore));
      expect(OnboardingChoice.values, contains(OnboardingChoice.notAsked));
    });

    test('names match expected strings for serialization', () {
      expect(OnboardingChoice.guided.name, equals('guided'));
      expect(OnboardingChoice.explore.name, equals('explore'));
      expect(OnboardingChoice.notAsked.name, equals('notAsked'));
    });
  });

  // =========================================================================
  // TourStepType enum
  // =========================================================================
  group('TourStepType', () {
    test('has simple and complex values', () {
      expect(TourStepType.values.length, equals(2));
      expect(TourStepType.values, contains(TourStepType.simple));
      expect(TourStepType.values, contains(TourStepType.complex));
    });
  });

  // =========================================================================
  // BottomSheetPosition enum
  // =========================================================================
  group('BottomSheetPosition', () {
    test('has bottom and top values', () {
      expect(BottomSheetPosition.values.length, equals(2));
      expect(BottomSheetPosition.values, contains(BottomSheetPosition.bottom));
      expect(BottomSheetPosition.values, contains(BottomSheetPosition.top));
    });
  });

  // =========================================================================
  // Integration: OnboardingState progression scenario
  // =========================================================================
  group('OnboardingState progression scenario', () {
    test('step-by-step beginner journey updates state correctly', () {
      // Start fresh
      OnboardingState state = const OnboardingState();
      expect(state.hasStarted, isFalse);
      expect(state.isCompleted, isFalse);

      // User sets experience level
      state = state.copyWith(userExperienceLevel: 'beginner');
      expect(state.isBeginner, isTrue);
      expect(state.hasCompletedQuickStart, isTrue);

      // User sets goal
      state = state.copyWith(
        userGoal: 'buildMuscle',
        weeklyWorkoutTarget: 3,
      );
      expect(state.hasSelectedGoal, isTrue);
      expect(state.isBuildMuscleGoal, isTrue);
      expect(state.targetWorkoutsPerWeek, equals(3));

      // User starts onboarding steps
      state = state.copyWith(
        currentStep: 1,
        completedSteps: [0],
      );
      expect(state.hasStarted, isTrue);
      expect(state.progress, closeTo(1.0 / 8.0, 1e-10));

      // User is shown 'addFirstExercise' overlay
      expect(state.shouldShowAddFirstExercise, isTrue);
      state = state.copyWith(seenOverlays: ['addFirstExercise']);
      expect(state.shouldShowAddFirstExercise, isFalse);

      // User adds first exercise
      final exerciseTime = DateTime(2025, 2, 1);
      state = state.copyWith(firstExerciseAddedAt: exerciseTime);
      expect(state.hasAddedFirstExercise, isTrue);

      // User completes a set
      state = state.copyWith(firstSetCompletedAt: exerciseTime);
      expect(state.hasCompletedFirstSet, isTrue);
      expect(state.shouldShowCompleteWorkout, isTrue);

      // User sees 'completeFirstWorkout' overlay, then finishes workout
      state = state.copyWith(
        seenOverlays: ['addFirstExercise', 'completeFirstWorkout'],
        hasCompletedFirstWorkout: true,
      );
      expect(state.shouldShowCompleteWorkout, isFalse);
      expect(state.isInGuidedFirstWorkout, isFalse);

      // User completes all onboarding steps
      state = state.copyWith(
        completedSteps: [0, 1, 2, 3, 4, 5, 6, 7],
        hasSeenGlobalOnboarding: true,
      );
      expect(state.isCompleted, isTrue);
      expect(state.progress, equals(1.0));
    });

    test('expert user bypasses guided first workout flow', () {
      const state = OnboardingState(
        userExperienceLevel: 'expert',
        hasCompletedFirstWorkout: false,
      );

      expect(state.isExpert, isTrue);
      expect(state.isBeginner, isFalse);
      expect(state.isInGuidedFirstWorkout, isFalse);
      expect(state.shouldShowAddFirstExercise, isFalse);
      expect(state.shouldShowCompleteWorkout, isFalse);
    });
  });
}
