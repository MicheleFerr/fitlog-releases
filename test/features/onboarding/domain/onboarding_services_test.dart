// ignore_for_file: avoid_redundant_argument_values

/// Tests for onboarding domain services and entities.
///
/// Covers:
/// - HomeTourState / HomeTourNotifier
/// - WorkoutTutorialState / WorkoutTutorialNotifier
/// - OnboardingChoiceService and its logic
/// - OnboardingState JSON round-trip + helpers
/// - TutorialState JSON round-trip + helpers
/// - InitialOnboardingData JSON round-trip
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/entities/onboarding_state.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/entities/tutorial_state.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/entities/initial/initial_onboarding_data.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/services/home_tour_service.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/services/workout_tutorial_service.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/services/onboarding_choice_service.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/strength_standard.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/user_fitness_questionnaire.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ProviderContainer _makeContainer() => ProviderContainer();

// ---------------------------------------------------------------------------
// OnboardingState — JSON round-trip & computed helpers
// ---------------------------------------------------------------------------

void main() {
  // =========================================================================
  // OnboardingState
  // =========================================================================
  group('OnboardingState', () {
    test('default constructor creates correct initial state', () {
      const state = OnboardingState();
      expect(state.hasSeenGlobalOnboarding, isFalse);
      expect(state.currentStep, 0);
      expect(state.completedSteps, isEmpty);
      expect(state.canResume, isFalse);
      expect(state.onboardingVersion, 1);
      expect(state.hasAcceptedLegalDisclaimer, isFalse);
    });

    test('isCompleted is true when completedSteps.length >= totalSteps', () {
      final steps = List.generate(OnboardingState.totalSteps, (i) => i);
      final state = OnboardingState(completedSteps: steps);
      expect(state.isCompleted, isTrue);
    });

    test('isCompleted is false when steps are incomplete', () {
      const state = OnboardingState(completedSteps: [0, 1]);
      expect(state.isCompleted, isFalse);
    });

    test('hasStarted is true when currentStep > 0', () {
      const state = OnboardingState(currentStep: 1);
      expect(state.hasStarted, isTrue);
    });

    test('hasStarted is true when completedSteps is non-empty', () {
      const state = OnboardingState(completedSteps: [0]);
      expect(state.hasStarted, isTrue);
    });

    test('hasStarted is false on initial state', () {
      const state = OnboardingState();
      expect(state.hasStarted, isFalse);
    });

    test('progress returns fraction of completed steps', () {
      const state = OnboardingState(completedSteps: [0, 1, 2, 3]);
      expect(state.progress, closeTo(4 / OnboardingState.totalSteps, 0.001));
    });

    test('isStepCompleted returns true only for completed steps', () {
      const state = OnboardingState(completedSteps: [2, 5]);
      expect(state.isStepCompleted(2), isTrue);
      expect(state.isStepCompleted(5), isTrue);
      expect(state.isStepCompleted(0), isFalse);
    });

    test('isBeginner / isExpert helpers', () {
      const beginner = OnboardingState(userExperienceLevel: 'beginner');
      const expert = OnboardingState(userExperienceLevel: 'expert');
      const neither = OnboardingState();

      expect(beginner.isBeginner, isTrue);
      expect(beginner.isExpert, isFalse);
      expect(expert.isExpert, isTrue);
      expect(expert.isBeginner, isFalse);
      expect(neither.isBeginner, isFalse);
      expect(neither.isExpert, isFalse);
    });

    test('hasSeenOverlay correctly checks seenOverlays', () {
      const state = OnboardingState(seenOverlays: ['addFirstExercise']);
      expect(state.hasSeenOverlay('addFirstExercise'), isTrue);
      expect(state.hasSeenOverlay('other'), isFalse);
    });

    test('isInGuidedFirstWorkout logic', () {
      // beginner and NOT completed first workout
      const guided = OnboardingState(
        userExperienceLevel: 'beginner',
        hasCompletedFirstWorkout: false,
      );
      expect(guided.isInGuidedFirstWorkout, isTrue);

      // expert should not be guided
      const expert = OnboardingState(userExperienceLevel: 'expert');
      expect(expert.isInGuidedFirstWorkout, isFalse);

      // beginner who already completed first workout
      const completed = OnboardingState(
        userExperienceLevel: 'beginner',
        hasCompletedFirstWorkout: true,
      );
      expect(completed.isInGuidedFirstWorkout, isFalse);
    });

    test('shouldShowAddFirstExercise logic', () {
      const state = OnboardingState(
        userExperienceLevel: 'beginner',
        hasCompletedFirstWorkout: false,
        firstExerciseAddedAt: null,
        seenOverlays: [],
      );
      expect(state.shouldShowAddFirstExercise, isTrue);

      // Already seen overlay
      const seen = OnboardingState(
        userExperienceLevel: 'beginner',
        hasCompletedFirstWorkout: false,
        firstExerciseAddedAt: null,
        seenOverlays: ['addFirstExercise'],
      );
      expect(seen.shouldShowAddFirstExercise, isFalse);
    });

    test('goal helpers', () {
      const state = OnboardingState(
        userGoal: 'buildMuscle',
        weeklyWorkoutTarget: 4,
      );
      expect(state.hasSelectedGoal, isTrue);
      expect(state.isBuildMuscleGoal, isTrue);
      expect(state.isLoseWeightGoal, isFalse);
      expect(state.targetWorkoutsPerWeek, 4);
    });

    test('targetWorkoutsPerWeek defaults to 3 when not set', () {
      const state = OnboardingState();
      expect(state.targetWorkoutsPerWeek, 3);
    });

    test('toJson/fromJson round-trip preserves all fields', () {
      final now = DateTime.now();
      final state = OnboardingState(
        hasSeenGlobalOnboarding: true,
        currentStep: 3,
        completedSteps: const [0, 1, 2],
        canResume: true,
        onboardingVersion: 2,
        lastInteraction: now,
        stepData: const {'key': 'value'},
        userExperienceLevel: 'beginner',
        seenOverlays: const ['overlay1'],
        overlayVersionSeen: 2,
        quickStartCompletedAt: now,
        hasCompletedFirstWorkout: true,
        firstExerciseAddedAt: now,
        firstSetCompletedAt: now,
        hasSeenRestTimerExplanation: true,
        userGoal: 'getStronger',
        weeklyWorkoutTarget: 5,
        hasAcceptedLegalDisclaimer: true,
        legalDisclaimerAcceptedAt: now,
      );

      final json = state.toJson();
      final restored = OnboardingState.fromJson(json);

      expect(restored.hasSeenGlobalOnboarding, isTrue);
      expect(restored.currentStep, 3);
      expect(restored.completedSteps, [0, 1, 2]);
      expect(restored.canResume, isTrue);
      expect(restored.onboardingVersion, 2);
      expect(restored.userExperienceLevel, 'beginner');
      expect(restored.seenOverlays, ['overlay1']);
      expect(restored.hasCompletedFirstWorkout, isTrue);
      expect(restored.hasSeenRestTimerExplanation, isTrue);
      expect(restored.userGoal, 'getStronger');
      expect(restored.weeklyWorkoutTarget, 5);
      expect(restored.hasAcceptedLegalDisclaimer, isTrue);
    });

    test('fromJson handles missing optional fields gracefully', () {
      final state = OnboardingState.fromJson({});
      expect(state.hasSeenGlobalOnboarding, isFalse);
      expect(state.currentStep, 0);
      expect(state.completedSteps, isEmpty);
      expect(state.onboardingVersion, 1);
      expect(state.userExperienceLevel, isNull);
      expect(state.userGoal, isNull);
    });

    test('copyWith creates new instance with updated fields', () {
      const original = OnboardingState();
      final updated = original.copyWith(
        hasSeenGlobalOnboarding: true,
        currentStep: 2,
      );
      expect(updated.hasSeenGlobalOnboarding, isTrue);
      expect(updated.currentStep, 2);
      // original unchanged
      expect(original.hasSeenGlobalOnboarding, isFalse);
      expect(original.currentStep, 0);
    });

    test('equality based on key fields', () {
      const a = OnboardingState(currentStep: 1, canResume: true);
      const b = OnboardingState(currentStep: 1, canResume: true);
      expect(a, equals(b));
    });

    test('toString contains relevant info', () {
      const state = OnboardingState(currentStep: 2);
      expect(state.toString(), contains('OnboardingState'));
    });
  });

  // =========================================================================
  // OnboardingStep enum
  // =========================================================================
  group('OnboardingStep', () {
    test('fromIndex returns correct step', () {
      expect(OnboardingStep.fromIndex(0), OnboardingStep.welcome);
      expect(OnboardingStep.fromIndex(3), OnboardingStep.createWorkout);
      expect(OnboardingStep.fromIndex(7), OnboardingStep.advancedFeatures);
    });

    test('fromIndex returns welcome for out-of-range index', () {
      expect(OnboardingStep.fromIndex(99), OnboardingStep.welcome);
    });

    test('each step has correct index and title', () {
      expect(OnboardingStep.welcome.stepIndex, 0);
      expect(OnboardingStep.modeSelection.stepIndex, 1);
      expect(OnboardingStep.addExercise.stepIndex, 4);
      expect(OnboardingStep.advancedFeatures.stepIndex, 7);
      expect(OnboardingStep.welcome.title, 'Welcome');
    });
  });

  // =========================================================================
  // TutorialState — JSON round-trip & helpers
  // =========================================================================
  group('TutorialState', () {
    test('initial() creates empty state', () {
      final state = TutorialState.initial();
      expect(state.seenTutorialsList, isEmpty);
      expect(state.dismissedHintsList, isEmpty);
      expect(state.lastDismissTimeList, isEmpty);
      expect(state.totalWorkouts, 0);
      expect(state.tutorialsEnabled, isTrue);
    });

    test('fromSets constructor converts sets correctly', () {
      final now = DateTime.now();
      final state = TutorialState.fromSets(
        seenTutorials: {'logging_set', 'rest_timer'},
        dismissedHints: {'hint_a'},
        lastDismissTime: {'hint_a': now},
        totalWorkouts: 5,
        firstWorkoutDate: now,
        tutorialsEnabled: false,
      );
      expect(state.seenTutorials, containsAll(['logging_set', 'rest_timer']));
      expect(state.dismissedHints, contains('hint_a'));
      expect(state.totalWorkouts, 5);
      expect(state.tutorialsEnabled, isFalse);
    });

    test('hasSeen returns true only for seen tutorials', () {
      final state = TutorialState.fromSets(
        seenTutorials: {'logging_set'},
      );
      expect(state.hasSeen('logging_set'), isTrue);
      expect(state.hasSeen('rest_timer'), isFalse);
    });

    test('isNewUser is true when totalWorkouts < 3', () {
      expect(const TutorialState(totalWorkouts: 0).isNewUser, isTrue);
      expect(const TutorialState(totalWorkouts: 2).isNewUser, isTrue);
      expect(const TutorialState(totalWorkouts: 3).isNewUser, isFalse);
    });

    test('hasCompletedFirstWorkout is true when totalWorkouts > 0', () {
      expect(const TutorialState(totalWorkouts: 0).hasCompletedFirstWorkout, isFalse);
      expect(const TutorialState(totalWorkouts: 1).hasCompletedFirstWorkout, isTrue);
    });

    test('canShowHint returns true for non-dismissed hints', () {
      const state = TutorialState();
      expect(state.canShowHint('any_hint'), isTrue);
    });

    test('canShowHint returns false for recently dismissed hints', () {
      final recentDismiss = DateTime.now().subtract(const Duration(hours: 1));
      final state = TutorialState.fromSets(
        dismissedHints: {'hint_x'},
        lastDismissTime: {'hint_x': recentDismiss},
      );
      expect(state.canShowHint('hint_x'), isFalse);
    });

    test('canShowHint returns true for hints dismissed >24h ago', () {
      final oldDismiss = DateTime.now().subtract(const Duration(hours: 25));
      final state = TutorialState.fromSets(
        dismissedHints: {'hint_x'},
        lastDismissTime: {'hint_x': oldDismiss},
      );
      expect(state.canShowHint('hint_x'), isTrue);
    });

    test('toJson/fromJson round-trip', () {
      final now = DateTime(2025, 1, 15, 10, 30);
      final original = TutorialState.fromSets(
        seenTutorials: {'tut1', 'tut2'},
        dismissedHints: {'hint1'},
        lastDismissTime: {'hint1': now},
        totalWorkouts: 7,
        firstWorkoutDate: now,
        tutorialsEnabled: false,
      );

      final json = original.toJson();
      final restored = TutorialState.fromJson(json);

      expect(restored.seenTutorials, containsAll(['tut1', 'tut2']));
      expect(restored.dismissedHints, contains('hint1'));
      expect(restored.totalWorkouts, 7);
      expect(restored.tutorialsEnabled, isFalse);
      expect(restored.firstWorkoutDate?.year, 2025);
    });

    test('fromJson handles missing fields gracefully', () {
      final state = TutorialState.fromJson({});
      expect(state.totalWorkouts, 0);
      expect(state.tutorialsEnabled, isTrue);
      expect(state.seenTutorialsList, isEmpty);
    });

    test('copyWith with List parameters', () {
      const original = TutorialState(totalWorkouts: 3);
      final updated = original.copyWith(
        seenTutorialsList: ['logging_set'],
        totalWorkouts: 5,
      );
      expect(updated.seenTutorialsList, ['logging_set']);
      expect(updated.totalWorkouts, 5);
      expect(original.totalWorkouts, 3); // original unchanged
    });

    test('copyWith with Set parameters', () {
      const original = TutorialState();
      final updated = original.copyWith(
        seenTutorials: {'t1', 't2'},
        dismissedHints: {'h1'},
      );
      expect(updated.seenTutorials, containsAll(['t1', 't2']));
      expect(updated.dismissedHints, contains('h1'));
    });

    test('lastDismissTime getter parses correctly', () {
      final now = DateTime(2025, 6, 1, 12, 0);
      final state = TutorialState.fromSets(
        dismissedHints: {'h1'},
        lastDismissTime: {'h1': now},
      );
      final map = state.lastDismissTime;
      expect(map.containsKey('h1'), isTrue);
      expect(map['h1']!.year, 2025);
      expect(map['h1']!.month, 6);
    });

    test('equality compares seenTutorialsList, dismissedHintsList, totalWorkouts', () {
      const a = TutorialState(seenTutorialsList: ['t1'], totalWorkouts: 3);
      const b = TutorialState(seenTutorialsList: ['t1'], totalWorkouts: 3);
      expect(a, equals(b));
    });

    test('toString contains relevant info', () {
      const state = TutorialState(totalWorkouts: 5);
      expect(state.toString(), contains('TutorialState'));
      expect(state.toString(), contains('5'));
    });
  });

  // =========================================================================
  // InitialOnboardingData — JSON round-trip & conversions
  // =========================================================================
  group('InitialOnboardingData', () {
    test('fromJson/toJson round-trip preserves all fields', () {
      final now = DateTime(2025, 3, 15);
      final original = InitialOnboardingData(
        goal: TrainingGoalUI.getStronger,
        sex: BiologicalSex.female,
        age: 30,
        heightCm: 165.0,
        bodyweightKg: 60.0,
        experience: ExperienceLevelUI.experienced,
        healthKitConnected: true,
        healthKitPermissionsGranted: const ['heart_rate'],
        workoutsPerWeek: 4,
        completedAt: now,
      );

      final json = original.toJson();
      final restored = InitialOnboardingData.fromJson(json);

      expect(restored.goal, TrainingGoalUI.getStronger);
      expect(restored.sex, BiologicalSex.female);
      expect(restored.age, 30);
      expect(restored.heightCm, 165.0);
      expect(restored.bodyweightKg, 60.0);
      expect(restored.experience, ExperienceLevelUI.experienced);
      expect(restored.healthKitConnected, isTrue);
      expect(restored.healthKitPermissionsGranted, ['heart_rate']);
      expect(restored.workoutsPerWeek, 4);
      expect(restored.completedAt?.year, 2025);
    });

    test('default values applied when optional fields absent', () {
      final json = {
        'goal': 'buildMuscle',
        'sex': 'male',
        'age': 25,
        'heightCm': 175.0,
        'bodyweightKg': 75.0,
        'experience': 'beginner',
      };
      final data = InitialOnboardingData.fromJson(json);
      expect(data.healthKitConnected, isFalse);
      expect(data.healthKitPermissionsGranted, isEmpty);
      expect(data.workoutsPerWeek, 3);
      expect(data.completedAt, isNull);
    });

    test('toQuestionnaire converts correctly', () {
      const data = InitialOnboardingData(
        goal: TrainingGoalUI.buildMuscle,
        sex: BiologicalSex.male,
        age: 28,
        heightCm: 180.0,
        bodyweightKg: 80.0,
        experience: ExperienceLevelUI.someExperience,
      );
      final questionnaire = data.toQuestionnaire();
      expect(questionnaire.bodyweightKg, 80.0);
      expect(questionnaire.age, 28);
      expect(questionnaire.heightCm, 180.0);
    });

    test('TrainingGoalUI extension maps correctly', () {
      expect(TrainingGoalUI.buildMuscle.toTrainingGoal(), TrainingGoal.hypertrophy);
      expect(TrainingGoalUI.getStronger.toTrainingGoal(), TrainingGoal.strength);
      expect(TrainingGoalUI.endurance.toTrainingGoal(), TrainingGoal.endurance);
      expect(TrainingGoalUI.stayFit.toTrainingGoal(), TrainingGoal.hypertrophy);
    });

    test('TrainingGoalUI icon is non-empty for all values', () {
      for (final goal in TrainingGoalUI.values) {
        expect(goal.icon, isNotEmpty);
      }
    });

    test('ExperienceLevelUI extension maps correctly', () {
      expect(ExperienceLevelUI.beginner.estimatedMonths, 3);
      expect(ExperienceLevelUI.someExperience.estimatedMonths, 12);
      expect(ExperienceLevelUI.experienced.estimatedMonths, 36);
      expect(ExperienceLevelUI.athlete.estimatedMonths, 72);
    });

    test('ExperienceLevelUI icon is non-empty for all values', () {
      for (final level in ExperienceLevelUI.values) {
        expect(level.icon, isNotEmpty);
      }
    });
  });

  // =========================================================================
  // HomeTourState
  // =========================================================================
  group('HomeTourState', () {
    test('default values', () {
      const state = HomeTourState(
        isActive: false,
        currentStep: HomeTourStep.xpProgress,
        hasCompletedTour: false,
      );
      expect(state.isActive, isFalse);
      expect(state.currentStep, HomeTourStep.xpProgress);
      expect(state.hasCompletedTour, isFalse);
    });

    test('copyWith updates fields', () {
      const state = HomeTourState(
        isActive: false,
        currentStep: HomeTourStep.xpProgress,
        hasCompletedTour: false,
      );
      final updated = state.copyWith(
        isActive: true,
        currentStep: HomeTourStep.myTemplates,
        hasCompletedTour: true,
      );
      expect(updated.isActive, isTrue);
      expect(updated.currentStep, HomeTourStep.myTemplates);
      expect(updated.hasCompletedTour, isTrue);
      // Original unchanged
      expect(state.isActive, isFalse);
    });

    test('copyWith preserves unchanged fields', () {
      const state = HomeTourState(
        isActive: true,
        currentStep: HomeTourStep.aiCoachIntro,
        hasCompletedTour: false,
      );
      final updated = state.copyWith(hasCompletedTour: true);
      expect(updated.isActive, isTrue);
      expect(updated.currentStep, HomeTourStep.aiCoachIntro);
    });
  });

  // =========================================================================
  // HomeTourNotifier (Riverpod Notifier)
  // =========================================================================
  group('HomeTourNotifier', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('initial state has isActive=false', () {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final state = container.read(homeTourProvider);
      expect(state.isActive, isFalse);
    });

    test('startTour sets isActive=true and resets step', () {
      final container = _makeContainer();
      addTearDown(container.dispose);

      container.read(homeTourProvider.notifier).startTour();

      final state = container.read(homeTourProvider);
      expect(state.isActive, isTrue);
      expect(state.currentStep, HomeTourStep.xpProgress);
    });

    test('stopTour sets isActive=false', () {
      final container = _makeContainer();
      addTearDown(container.dispose);

      container.read(homeTourProvider.notifier).startTour();
      container.read(homeTourProvider.notifier).stopTour();

      expect(container.read(homeTourProvider).isActive, isFalse);
    });

    test('advanceToStep only works when active', () {
      final container = _makeContainer();
      addTearDown(container.dispose);

      // Not active — advanceToStep should no-op
      container
          .read(homeTourProvider.notifier)
          .advanceToStep(HomeTourStep.myTemplates);
      expect(
        container.read(homeTourProvider).currentStep,
        HomeTourStep.xpProgress,
      );

      // Now active — advance should work
      container.read(homeTourProvider.notifier).startTour();
      container
          .read(homeTourProvider.notifier)
          .advanceToStep(HomeTourStep.myTemplates);
      expect(
        container.read(homeTourProvider).currentStep,
        HomeTourStep.myTemplates,
      );
    });

    test('completeTour persists hasCompletedTour=true', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      container.read(homeTourProvider.notifier).startTour();
      await container.read(homeTourProvider.notifier).completeTour();

      final state = container.read(homeTourProvider);
      expect(state.hasCompletedTour, isTrue);
      expect(state.isActive, isFalse);
      expect(state.currentStep, HomeTourStep.completed);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('home_tour_completed'), isTrue);
    });

    test('resetTour clears SharedPreferences key', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      await container.read(homeTourProvider.notifier).completeTour();
      await container.read(homeTourProvider.notifier).resetTour();

      final state = container.read(homeTourProvider);
      expect(state.hasCompletedTour, isFalse);
      expect(state.isActive, isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('home_tour_completed'), isNull);
    });

    test('homeTourCompletedProvider reflects hasCompletedTour', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      expect(container.read(homeTourCompletedProvider), isFalse);
      container.read(homeTourProvider.notifier).startTour();
      await container.read(homeTourProvider.notifier).completeTour();
      expect(container.read(homeTourCompletedProvider), isTrue);
    });

    test('completeTour + resetTour cycle correctly toggles hasCompletedTour', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      // Start -> complete -> reset cycle
      container.read(homeTourProvider.notifier).startTour();
      await container.read(homeTourProvider.notifier).completeTour();
      expect(container.read(homeTourProvider).hasCompletedTour, isTrue);

      await container.read(homeTourProvider.notifier).resetTour();
      expect(container.read(homeTourProvider).hasCompletedTour, isFalse);
    });
  });

  // =========================================================================
  // WorkoutTutorialState
  // =========================================================================
  group('WorkoutTutorialState', () {
    test('default values', () {
      const state = WorkoutTutorialState(
        isActive: false,
        currentStep: WorkoutTutorialStep.addExercise,
        hasCompletedTutorial: false,
        hasStartedTutorial: false,
      );
      expect(state.isActive, isFalse);
      expect(state.isPaused, isFalse);
      expect(state.currentStep, WorkoutTutorialStep.addExercise);
      expect(state.hasCompletedTutorial, isFalse);
      expect(state.hasStartedTutorial, isFalse);
    });

    test('copyWith updates fields', () {
      const state = WorkoutTutorialState(
        isActive: false,
        currentStep: WorkoutTutorialStep.addExercise,
        hasCompletedTutorial: false,
        hasStartedTutorial: false,
      );
      final updated = state.copyWith(
        isActive: true,
        currentStep: WorkoutTutorialStep.tapSet,
        isPaused: true,
      );
      expect(updated.isActive, isTrue);
      expect(updated.currentStep, WorkoutTutorialStep.tapSet);
      expect(updated.isPaused, isTrue);
      // original unchanged
      expect(state.isActive, isFalse);
    });
  });

  // =========================================================================
  // WorkoutTutorialNotifier (Riverpod Notifier)
  // =========================================================================
  group('WorkoutTutorialNotifier', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      WorkoutTutorialNotifier.clearCacheForTesting();
    });

    tearDown(() {
      WorkoutTutorialNotifier.clearCacheForTesting();
    });

    test('initial state has isActive=false', () {
      final container = _makeContainer();
      addTearDown(container.dispose);
      expect(container.read(workoutTutorialProvider).isActive, isFalse);
    });

    test('startTutorial sets isActive=true and hasStartedTutorial=true', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      await container.read(workoutTutorialProvider.notifier).startTutorial();

      final state = container.read(workoutTutorialProvider);
      expect(state.isActive, isTrue);
      expect(state.hasStartedTutorial, isTrue);
      expect(state.currentStep, WorkoutTutorialStep.addExercise);
    });

    test('stopTutorial sets isActive=false', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      await container.read(workoutTutorialProvider.notifier).startTutorial();
      container.read(workoutTutorialProvider.notifier).stopTutorial();

      expect(container.read(workoutTutorialProvider).isActive, isFalse);
    });

    test('pauseTutorial sets isPaused=true', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      await container.read(workoutTutorialProvider.notifier).startTutorial();
      container.read(workoutTutorialProvider.notifier).pauseTutorial();

      expect(container.read(workoutTutorialProvider).isPaused, isTrue);
    });

    test('resumeTutorial sets isPaused=false', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      await container.read(workoutTutorialProvider.notifier).startTutorial();
      container.read(workoutTutorialProvider.notifier).pauseTutorial();
      container.read(workoutTutorialProvider.notifier).resumeTutorial();

      expect(container.read(workoutTutorialProvider).isPaused, isFalse);
    });

    test('advanceToStep only works when active', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      // Not active
      container
          .read(workoutTutorialProvider.notifier)
          .advanceToStep(WorkoutTutorialStep.tapSet);
      expect(
        container.read(workoutTutorialProvider).currentStep,
        WorkoutTutorialStep.addExercise,
      );

      // Now active
      await container.read(workoutTutorialProvider.notifier).startTutorial();
      container
          .read(workoutTutorialProvider.notifier)
          .advanceToStep(WorkoutTutorialStep.exerciseMenu);
      expect(
        container.read(workoutTutorialProvider).currentStep,
        WorkoutTutorialStep.exerciseMenu,
      );
    });

    test('completeTutorial sets hasCompletedTutorial=true and persists', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      await container.read(workoutTutorialProvider.notifier).startTutorial();
      await container.read(workoutTutorialProvider.notifier).completeTutorial();

      final state = container.read(workoutTutorialProvider);
      expect(state.hasCompletedTutorial, isTrue);
      expect(state.isActive, isFalse);
      expect(state.currentStep, WorkoutTutorialStep.completed);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('workout_tutorial_completed'), isTrue);
    });

    test('resetTutorial clears persisted flags', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      await container.read(workoutTutorialProvider.notifier).startTutorial();
      await container.read(workoutTutorialProvider.notifier).completeTutorial();
      await container.read(workoutTutorialProvider.notifier).resetTutorial();

      final state = container.read(workoutTutorialProvider);
      expect(state.hasCompletedTutorial, isFalse);
      expect(state.hasStartedTutorial, isFalse);
      expect(state.isActive, isFalse);
      expect(state.currentStep, WorkoutTutorialStep.addExercise);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('workout_tutorial_completed'), isNull);
      expect(prefs.getBool('workout_tutorial_started'), isNull);
    });

    test('isLoaded is true after _loadState completes', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      final notifier = container.read(workoutTutorialProvider.notifier);
      await notifier.waitForLoad();
      expect(notifier.isLoaded, isTrue);
    });

    test('workoutTutorialCompletedProvider reflects state', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      expect(container.read(workoutTutorialCompletedProvider), isFalse);

      await container.read(workoutTutorialProvider.notifier).startTutorial();
      await container.read(workoutTutorialProvider.notifier).completeTutorial();

      expect(container.read(workoutTutorialCompletedProvider), isTrue);
    });

    test('startTutorial persists hasStartedTutorial to SharedPreferences', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      await container.read(workoutTutorialProvider.notifier).startTutorial();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('workout_tutorial_started'), isTrue);
    });

    test('second startTutorial does not re-persist started flag', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      // Start twice — should not throw
      await container.read(workoutTutorialProvider.notifier).startTutorial();
      await container.read(workoutTutorialProvider.notifier).startTutorial();

      final state = container.read(workoutTutorialProvider);
      expect(state.hasStartedTutorial, isTrue);
    });
  });

  // =========================================================================
  // HomeTourStep enum
  // =========================================================================
  group('HomeTourStep enum', () {
    test('all values accessible', () {
      expect(HomeTourStep.values, hasLength(4));
      expect(HomeTourStep.values, contains(HomeTourStep.completed));
    });
  });

  // =========================================================================
  // WorkoutTutorialStep enum
  // =========================================================================
  group('WorkoutTutorialStep enum', () {
    test('all 6 values accessible', () {
      expect(WorkoutTutorialStep.values, hasLength(6));
      expect(WorkoutTutorialStep.values.first, WorkoutTutorialStep.addExercise);
      expect(WorkoutTutorialStep.values.last, WorkoutTutorialStep.completed);
    });
  });

  // =========================================================================
  // OnboardingChoiceService
  // =========================================================================
  group('OnboardingChoiceService', () {
    late SharedPreferences prefs;
    late OnboardingChoiceService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      service = OnboardingChoiceService(prefs);
    });

    test('getChoice returns notAsked by default', () {
      expect(service.getChoice(), OnboardingChoice.notAsked);
    });

    test('setChoice persists and getChoice returns correct value', () async {
      await service.setChoice(OnboardingChoice.guided);
      expect(service.getChoice(), OnboardingChoice.guided);

      await service.setChoice(OnboardingChoice.explore);
      expect(service.getChoice(), OnboardingChoice.explore);
    });

    test('isTemplateWizardCompleted returns false by default', () {
      expect(service.isTemplateWizardCompleted(), isFalse);
    });

    test('setTemplateWizardCompleted persists correctly', () async {
      await service.setTemplateWizardCompleted(true);
      expect(service.isTemplateWizardCompleted(), isTrue);

      await service.setTemplateWizardCompleted(false);
      expect(service.isTemplateWizardCompleted(), isFalse);
    });

    test('isTemplateWizardDismissed returns false by default', () {
      expect(service.isTemplateWizardDismissed(), isFalse);
    });

    test('dismissTemplateWizardReminder sets dismissed=true', () async {
      await service.dismissTemplateWizardReminder();
      expect(service.isTemplateWizardDismissed(), isTrue);
    });

    test('resetAll clears all stored values', () async {
      await service.setChoice(OnboardingChoice.guided);
      await service.setTemplateWizardCompleted(true);
      await service.dismissTemplateWizardReminder();

      await service.resetAll();

      expect(service.getChoice(), OnboardingChoice.notAsked);
      expect(service.isTemplateWizardCompleted(), isFalse);
      expect(service.isTemplateWizardDismissed(), isFalse);
    });
  });

  // =========================================================================
  // shouldShowTemplateWizardReminderProvider logic tests
  // (exercised through OnboardingChoiceService directly)
  // =========================================================================
  group('Template wizard reminder logic', () {
    late SharedPreferences prefs;
    late OnboardingChoiceService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      service = OnboardingChoiceService(prefs);
    });

    test('show reminder when choice=explore, not completed, not dismissed', () async {
      await service.setChoice(OnboardingChoice.explore);

      final choice = service.getChoice();
      final completed = service.isTemplateWizardCompleted();
      final dismissed = service.isTemplateWizardDismissed();

      final shouldShow = choice != OnboardingChoice.guided && !completed && !dismissed;
      expect(shouldShow, isTrue);
    });

    test('hide reminder when choice=guided', () async {
      await service.setChoice(OnboardingChoice.guided);

      final shouldShow = service.getChoice() != OnboardingChoice.guided;
      expect(shouldShow, isFalse);
    });

    test('hide reminder when wizard completed', () async {
      await service.setTemplateWizardCompleted(true);
      expect(service.isTemplateWizardCompleted(), isTrue);
    });

    test('hide reminder when dismissed', () async {
      await service.dismissTemplateWizardReminder();
      expect(service.isTemplateWizardDismissed(), isTrue);
    });

    test('show reminder when notAsked (existing user)', () {
      // Default state — notAsked, not completed, not dismissed
      final choice = service.getChoice();
      final completed = service.isTemplateWizardCompleted();
      final dismissed = service.isTemplateWizardDismissed();

      final shouldShow = choice != OnboardingChoice.guided && !completed && !dismissed;
      expect(shouldShow, isTrue);
    });
  });
}
