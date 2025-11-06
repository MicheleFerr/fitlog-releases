import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_suggestion_provider.dart';
import 'package:gymbro_flutter_new/features/community/domain/entities/community_contribution.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';

// Mock classes
class MockRef extends Mock implements Ref {}

void main() {
  group('SuggestionContext - appExperienceLevel', () {
    test('should return beginner for less than 5 workouts', () {
      final context = SuggestionContext(
        exercise: Exercise(name: 'Bench Press', type: ExerciseType.single, category: ExerciseCategory.chest),
        hasNotes: false,
        isFirstTime: false,
        completedSets: 0,
        totalSets: 3,
        existingContributions: [],
        userLevel: UserLevel.rookie,
        userContributionCount: 0,
        exerciseHistoryCount: 0,
        totalVolume: 0,
        totalWorkoutsCompleted: 3, // < 5
        accountAgeInDays: 20,
        isLastExerciseInWorkout: false,
        currentExerciseIndex: 0,
        totalExercisesInWorkout: 5,
        averageWorkoutVolume: 1000,
        uniqueExercisesCount: 10,
        workoutsPerWeek: 2.0,
      );

      expect(context.appExperienceLevel, equals(AppExperienceLevel.beginner));
    });

    test('should return beginner for less than 14 days account age', () {
      final context = SuggestionContext(
        exercise: Exercise(name: 'Bench Press', type: ExerciseType.single, category: ExerciseCategory.chest),
        hasNotes: false,
        isFirstTime: false,
        completedSets: 0,
        totalSets: 3,
        existingContributions: [],
        userLevel: UserLevel.rookie,
        userContributionCount: 0,
        exerciseHistoryCount: 0,
        totalVolume: 0,
        totalWorkoutsCompleted: 10,
        accountAgeInDays: 10, // < 14
        isLastExerciseInWorkout: false,
        currentExerciseIndex: 0,
        totalExercisesInWorkout: 5,
        averageWorkoutVolume: 1000,
        uniqueExercisesCount: 10,
        workoutsPerWeek: 2.0,
      );

      expect(context.appExperienceLevel, equals(AppExperienceLevel.beginner));
    });

    test('should return expert for 20+ workouts', () {
      final context = SuggestionContext(
        exercise: Exercise(name: 'Bench Press', type: ExerciseType.single, category: ExerciseCategory.chest),
        hasNotes: false,
        isFirstTime: false,
        completedSets: 0,
        totalSets: 3,
        existingContributions: [],
        userLevel: UserLevel.rookie,
        userContributionCount: 0,
        exerciseHistoryCount: 0,
        totalVolume: 0,
        totalWorkoutsCompleted: 25, // >= 20
        accountAgeInDays: 60,
        isLastExerciseInWorkout: false,
        currentExerciseIndex: 0,
        totalExercisesInWorkout: 5,
        averageWorkoutVolume: 1000,
        uniqueExercisesCount: 10,
        workoutsPerWeek: 2.0,
      );

      expect(context.appExperienceLevel, equals(AppExperienceLevel.expert));
    });

    test('should return intermediate for 5-19 workouts', () {
      final context = SuggestionContext(
        exercise: Exercise(name: 'Bench Press', type: ExerciseType.single, category: ExerciseCategory.chest),
        hasNotes: false,
        isFirstTime: false,
        completedSets: 0,
        totalSets: 3,
        existingContributions: [],
        userLevel: UserLevel.rookie,
        userContributionCount: 0,
        exerciseHistoryCount: 0,
        totalVolume: 0,
        totalWorkoutsCompleted: 12, // 5-19
        accountAgeInDays: 30,
        isLastExerciseInWorkout: false,
        currentExerciseIndex: 0,
        totalExercisesInWorkout: 5,
        averageWorkoutVolume: 1000,
        uniqueExercisesCount: 10,
        workoutsPerWeek: 2.0,
      );

      expect(context.appExperienceLevel, equals(AppExperienceLevel.intermediate));
    });
  });

  group('SuggestionContext - fitnessExperienceLevel', () {
    test('should return beginner for insufficient data (< 3 workouts)', () {
      final context = SuggestionContext(
        exercise: Exercise(name: 'Bench Press', type: ExerciseType.single, category: ExerciseCategory.chest),
        hasNotes: false,
        isFirstTime: false,
        completedSets: 0,
        totalSets: 3,
        existingContributions: [],
        userLevel: UserLevel.rookie,
        userContributionCount: 0,
        exerciseHistoryCount: 0,
        totalVolume: 0,
        totalWorkoutsCompleted: 2, // < 3
        accountAgeInDays: 7,
        isLastExerciseInWorkout: false,
        currentExerciseIndex: 0,
        totalExercisesInWorkout: 5,
        averageWorkoutVolume: 1000,
        uniqueExercisesCount: 5,
        workoutsPerWeek: 1.0,
      );

      expect(context.fitnessExperienceLevel, equals(FitnessExperienceLevel.beginner));
    });

    test('should return expert for high volume, variety, and frequency (score >= 5)', () {
      final context = SuggestionContext(
        exercise: Exercise(name: 'Bench Press', type: ExerciseType.single, category: ExerciseCategory.chest),
        hasNotes: false,
        isFirstTime: false,
        completedSets: 0,
        totalSets: 3,
        existingContributions: [],
        userLevel: UserLevel.rookie,
        userContributionCount: 0,
        exerciseHistoryCount: 0,
        totalVolume: 0,
        totalWorkoutsCompleted: 30,
        accountAgeInDays: 90,
        isLastExerciseInWorkout: false,
        currentExerciseIndex: 0,
        totalExercisesInWorkout: 5,
        averageWorkoutVolume: 9000, // > 8000 = +3 points
        uniqueExercisesCount: 35,   // > 30 = +2 points
        workoutsPerWeek: 5.0,        // >= 4 = +2 points (total 7 points)
      );

      expect(context.fitnessExperienceLevel, equals(FitnessExperienceLevel.expert));
    });

    test('should return intermediate for medium performance (score 2-4)', () {
      final context = SuggestionContext(
        exercise: Exercise(name: 'Bench Press', type: ExerciseType.single, category: ExerciseCategory.chest),
        hasNotes: false,
        isFirstTime: false,
        completedSets: 0,
        totalSets: 3,
        existingContributions: [],
        userLevel: UserLevel.rookie,
        userContributionCount: 0,
        exerciseHistoryCount: 0,
        totalVolume: 0,
        totalWorkoutsCompleted: 15,
        accountAgeInDays: 45,
        isLastExerciseInWorkout: false,
        currentExerciseIndex: 0,
        totalExercisesInWorkout: 5,
        averageWorkoutVolume: 4000, // 3000-8000 = +1 point
        uniqueExercisesCount: 15,   // 10-30 = +1 point
        workoutsPerWeek: 3.0,        // 2.5-4 = +1 point (total 3 points)
      );

      expect(context.fitnessExperienceLevel, equals(FitnessExperienceLevel.intermediate));
    });

    test('should return beginner for low performance (score 0-1)', () {
      final context = SuggestionContext(
        exercise: Exercise(name: 'Bench Press', type: ExerciseType.single, category: ExerciseCategory.chest),
        hasNotes: false,
        isFirstTime: false,
        completedSets: 0,
        totalSets: 3,
        existingContributions: [],
        userLevel: UserLevel.rookie,
        userContributionCount: 0,
        exerciseHistoryCount: 0,
        totalVolume: 0,
        totalWorkoutsCompleted: 5,
        accountAgeInDays: 15,
        isLastExerciseInWorkout: false,
        currentExerciseIndex: 0,
        totalExercisesInWorkout: 5,
        averageWorkoutVolume: 2000, // < 3000 = 0 points
        uniqueExercisesCount: 8,    // < 10 = 0 points
        workoutsPerWeek: 2.0,        // < 2.5 = 0 points (total 0 points)
      );

      expect(context.fitnessExperienceLevel, equals(FitnessExperienceLevel.beginner));
    });
  });

  group('SuggestionContext - shouldShowSuggestions', () {
    test('should return true when last exercise is completed', () {
      final context = SuggestionContext(
        exercise: Exercise(name: 'Bench Press', type: ExerciseType.single, category: ExerciseCategory.chest),
        hasNotes: false,
        isFirstTime: false,
        completedSets: 3,
        totalSets: 3, // Completed
        existingContributions: [],
        userLevel: UserLevel.rookie,
        userContributionCount: 0,
        exerciseHistoryCount: 0,
        totalVolume: 0,
        totalWorkoutsCompleted: 5,
        accountAgeInDays: 15,
        isLastExerciseInWorkout: true, // Last exercise
        currentExerciseIndex: 4,
        totalExercisesInWorkout: 5,
        averageWorkoutVolume: 2000,
        uniqueExercisesCount: 10,
        workoutsPerWeek: 2.0,
      );

      expect(context.shouldShowSuggestions, isTrue);
    });

    test('should return true when workout duration >= 30 minutes', () {
      final workoutStartTime = DateTime.now().subtract(const Duration(minutes: 35));
      final context = SuggestionContext(
        exercise: Exercise(name: 'Bench Press', type: ExerciseType.single, category: ExerciseCategory.chest),
        hasNotes: false,
        isFirstTime: false,
        completedSets: 2,
        totalSets: 3,
        existingContributions: [],
        userLevel: UserLevel.rookie,
        userContributionCount: 0,
        exerciseHistoryCount: 0,
        totalVolume: 0,
        totalWorkoutsCompleted: 5,
        accountAgeInDays: 15,
        workoutStartTime: workoutStartTime, // 35 minutes ago
        isLastExerciseInWorkout: false,
        currentExerciseIndex: 2,
        totalExercisesInWorkout: 5,
        averageWorkoutVolume: 2000,
        uniqueExercisesCount: 10,
        workoutsPerWeek: 2.0,
      );

      expect(context.shouldShowSuggestions, isTrue);
    });

    test('should return true when exercise index >= 2 and completed', () {
      final context = SuggestionContext(
        exercise: Exercise(name: 'Bench Press', type: ExerciseType.single, category: ExerciseCategory.chest),
        hasNotes: false,
        isFirstTime: false,
        completedSets: 3,
        totalSets: 3, // Completed
        existingContributions: [],
        userLevel: UserLevel.rookie,
        userContributionCount: 0,
        exerciseHistoryCount: 0,
        totalVolume: 0,
        totalWorkoutsCompleted: 5,
        accountAgeInDays: 15,
        isLastExerciseInWorkout: false,
        currentExerciseIndex: 2, // >= 2
        totalExercisesInWorkout: 5,
        averageWorkoutVolume: 2000,
        uniqueExercisesCount: 10,
        workoutsPerWeek: 2.0,
      );

      expect(context.shouldShowSuggestions, isTrue);
    });

    test('should return false during active workout (no conditions met)', () {
      final context = SuggestionContext(
        exercise: Exercise(name: 'Bench Press', type: ExerciseType.single, category: ExerciseCategory.chest),
        hasNotes: false,
        isFirstTime: false,
        completedSets: 1,
        totalSets: 3, // Not completed
        existingContributions: [],
        userLevel: UserLevel.rookie,
        userContributionCount: 0,
        exerciseHistoryCount: 0,
        totalVolume: 0,
        totalWorkoutsCompleted: 5,
        accountAgeInDays: 15,
        isLastExerciseInWorkout: false,
        currentExerciseIndex: 0, // < 2
        totalExercisesInWorkout: 5,
        averageWorkoutVolume: 2000,
        uniqueExercisesCount: 10,
        workoutsPerWeek: 2.0,
      );

      expect(context.shouldShowSuggestions, isFalse);
    });
  });

  group('SuggestionContext - isExperiencedWithExercise', () {
    test('should return true when exercise done >= 5 times with volume >= 500kg', () {
      final context = SuggestionContext(
        exercise: Exercise(name: 'Bench Press', type: ExerciseType.single, category: ExerciseCategory.chest),
        hasNotes: false,
        isFirstTime: false,
        completedSets: 3,
        totalSets: 3,
        existingContributions: [],
        userLevel: UserLevel.rookie,
        userContributionCount: 0,
        exerciseHistoryCount: 6, // >= 5
        totalVolume: 600, // >= 500
        totalWorkoutsCompleted: 10,
        accountAgeInDays: 30,
        isLastExerciseInWorkout: false,
        currentExerciseIndex: 0,
        totalExercisesInWorkout: 5,
        averageWorkoutVolume: 3000,
        uniqueExercisesCount: 15,
        workoutsPerWeek: 3.0,
      );

      expect(context.isExperiencedWithExercise, isTrue);
    });

    test('should return false for expert/master if volume < 500kg (second check blocks)', () {
      final context = SuggestionContext(
        exercise: Exercise(name: 'Bench Press', type: ExerciseType.single, category: ExerciseCategory.chest),
        hasNotes: false,
        isFirstTime: false,
        completedSets: 3,
        totalSets: 3,
        existingContributions: [],
        userLevel: UserLevel.expert, // Expert user
        userContributionCount: 60,
        exerciseHistoryCount: 5, // >= 5
        totalVolume: 350, // < 500 (second check fails, expert branch never reached)
        totalWorkoutsCompleted: 50,
        accountAgeInDays: 90,
        isLastExerciseInWorkout: false,
        currentExerciseIndex: 0,
        totalExercisesInWorkout: 5,
        averageWorkoutVolume: 5000,
        uniqueExercisesCount: 30,
        workoutsPerWeek: 4.0,
      );

      // The second check (totalVolume < 500) blocks before expert branch
      expect(context.isExperiencedWithExercise, isFalse);
    });

    test('should return false when exercise done < 5 times', () {
      final context = SuggestionContext(
        exercise: Exercise(name: 'Bench Press', type: ExerciseType.single, category: ExerciseCategory.chest),
        hasNotes: false,
        isFirstTime: false,
        completedSets: 3,
        totalSets: 3,
        existingContributions: [],
        userLevel: UserLevel.rookie,
        userContributionCount: 0,
        exerciseHistoryCount: 3, // < 5
        totalVolume: 600,
        totalWorkoutsCompleted: 10,
        accountAgeInDays: 30,
        isLastExerciseInWorkout: false,
        currentExerciseIndex: 0,
        totalExercisesInWorkout: 5,
        averageWorkoutVolume: 3000,
        uniqueExercisesCount: 15,
        workoutsPerWeek: 3.0,
      );

      expect(context.isExperiencedWithExercise, isFalse);
    });

    test('should return false when volume < 500kg', () {
      final context = SuggestionContext(
        exercise: Exercise(name: 'Bench Press', type: ExerciseType.single, category: ExerciseCategory.chest),
        hasNotes: false,
        isFirstTime: false,
        completedSets: 3,
        totalSets: 3,
        existingContributions: [],
        userLevel: UserLevel.rookie,
        userContributionCount: 0,
        exerciseHistoryCount: 6, // >= 5
        totalVolume: 400, // < 500
        totalWorkoutsCompleted: 10,
        accountAgeInDays: 30,
        isLastExerciseInWorkout: false,
        currentExerciseIndex: 0,
        totalExercisesInWorkout: 5,
        averageWorkoutVolume: 3000,
        uniqueExercisesCount: 15,
        workoutsPerWeek: 3.0,
      );

      expect(context.isExperiencedWithExercise, isFalse);
    });
  });

  group('SuggestionContext - computed properties', () {
    test('isCompleted should return true when completedSets == totalSets', () {
      final context = SuggestionContext(
        exercise: Exercise(name: 'Bench Press', type: ExerciseType.single, category: ExerciseCategory.chest),
        hasNotes: false,
        isFirstTime: false,
        completedSets: 3,
        totalSets: 3,
        existingContributions: [],
        userLevel: UserLevel.rookie,
        userContributionCount: 0,
        exerciseHistoryCount: 0,
        totalVolume: 0,
        totalWorkoutsCompleted: 5,
        accountAgeInDays: 15,
        isLastExerciseInWorkout: false,
        currentExerciseIndex: 0,
        totalExercisesInWorkout: 5,
        averageWorkoutVolume: 2000,
        uniqueExercisesCount: 10,
        workoutsPerWeek: 2.0,
      );

      expect(context.isCompleted, isTrue);
    });

    test('hasWeightJump should return true when maxWeight > minWeight * 2', () {
      final context = SuggestionContext(
        exercise: Exercise(name: 'Bench Press', type: ExerciseType.single, category: ExerciseCategory.chest),
        hasNotes: false,
        isFirstTime: false,
        completedSets: 3,
        totalSets: 3,
        minWeight: 50.0,
        maxWeight: 120.0, // > 50 * 2
        existingContributions: [],
        userLevel: UserLevel.rookie,
        userContributionCount: 0,
        exerciseHistoryCount: 0,
        totalVolume: 0,
        totalWorkoutsCompleted: 5,
        accountAgeInDays: 15,
        isLastExerciseInWorkout: false,
        currentExerciseIndex: 0,
        totalExercisesInWorkout: 5,
        averageWorkoutVolume: 2000,
        uniqueExercisesCount: 10,
        workoutsPerWeek: 2.0,
      );

      expect(context.hasWeightJump, isTrue);
    });

    test('hasExistingTips should return true when there are tip contributions', () {
      final tipContribution = CommunityContribution(
        id: 'tip-1',
        exerciseId: 'exercise-1',
        exerciseName: 'Bench Press',
        userId: 'user-1',
        userName: 'Test User',
        type: ContributionType.tip,
        status: ContributionStatus.approved,
        title: 'Tip Title',
        description: 'Great tip',
        createdAt: DateTime.now(),
        upvotes: 5,
        downvotes: 0,
      );

      final context = SuggestionContext(
        exercise: Exercise(name: 'Bench Press', type: ExerciseType.single, category: ExerciseCategory.chest),
        hasNotes: false,
        isFirstTime: false,
        completedSets: 3,
        totalSets: 3,
        existingContributions: [tipContribution],
        userLevel: UserLevel.rookie,
        userContributionCount: 0,
        exerciseHistoryCount: 0,
        totalVolume: 0,
        totalWorkoutsCompleted: 5,
        accountAgeInDays: 15,
        isLastExerciseInWorkout: false,
        currentExerciseIndex: 0,
        totalExercisesInWorkout: 5,
        averageWorkoutVolume: 2000,
        uniqueExercisesCount: 10,
        workoutsPerWeek: 2.0,
      );

      expect(context.hasExistingTips, isTrue);
    });

    test('hasExistingWarnings should return true when there are warning contributions', () {
      final warningContribution = CommunityContribution(
        id: 'warning-1',
        exerciseId: 'exercise-1',
        exerciseName: 'Bench Press',
        userId: 'user-1',
        userName: 'Test User',
        type: ContributionType.warning,
        status: ContributionStatus.approved,
        title: 'Warning Title',
        description: 'Safety warning',
        createdAt: DateTime.now(),
        upvotes: 10,
        downvotes: 0,
      );

      final context = SuggestionContext(
        exercise: Exercise(name: 'Bench Press', type: ExerciseType.single, category: ExerciseCategory.chest),
        hasNotes: false,
        isFirstTime: false,
        completedSets: 3,
        totalSets: 3,
        existingContributions: [warningContribution],
        userLevel: UserLevel.rookie,
        userContributionCount: 0,
        exerciseHistoryCount: 0,
        totalVolume: 0,
        totalWorkoutsCompleted: 5,
        accountAgeInDays: 15,
        isLastExerciseInWorkout: false,
        currentExerciseIndex: 0,
        totalExercisesInWorkout: 5,
        averageWorkoutVolume: 2000,
        uniqueExercisesCount: 10,
        workoutsPerWeek: 2.0,
      );

      expect(context.hasExistingWarnings, isTrue);
    });
  });

  group('SmartSuggestion', () {
    test('should create valid SmartSuggestion', () {
      final now = DateTime.now();
      final suggestion = SmartSuggestion(
        id: 'suggestion-1',
        text: 'Test suggestion',
        type: ContributionType.tip,
        contextType: 'test_context',
        priority: 85,
        createdAt: DateTime(2024, 1, 1),
        trigger: 'test_trigger',
      );

      expect(suggestion.id, equals('suggestion-1'));
      expect(suggestion.text, equals('Test suggestion'));
      expect(suggestion.type, equals(ContributionType.tip));
      expect(suggestion.contextType, equals('test_context'));
      expect(suggestion.priority, equals(85));
      expect(suggestion.createdAt, equals(now));
      expect(suggestion.trigger, equals('test_trigger'));
    });

    test('copyWith should create new instance with updated values', () {
      final original = SmartSuggestion(
        id: 'suggestion-1',
        text: 'Original text',
        type: ContributionType.tip,
        contextType: 'original',
        priority: 50,
        createdAt: DateTime.now(),
        trigger: 'original_trigger',
      );

      final updated = original.copyWith(
        text: 'Updated text',
        priority: 90,
      );

      expect(updated.id, equals(original.id));
      expect(updated.text, equals('Updated text'));
      expect(updated.type, equals(original.type));
      expect(updated.contextType, equals(original.contextType));
      expect(updated.priority, equals(90));
      expect(updated.createdAt, equals(original.createdAt));
      expect(updated.trigger, equals(original.trigger));
    });
  });

  group('ExerciseSuggestionsNotifier - dismissSuggestion', () {
    test('should remove suggestion with matching ID', () {
      final notifier = ExerciseSuggestionsNotifier(MockRef(), 'exercise-1');
      final suggestions = [
        SmartSuggestion(
          id: 'suggestion-1',
          text: 'First',
          type: ContributionType.tip,
          contextType: 'test',
          priority: 80,
          createdAt: DateTime.now(),
          trigger: 'test',
        ),
        SmartSuggestion(
          id: 'suggestion-2',
          text: 'Second',
          type: ContributionType.tip,
          contextType: 'test',
          priority: 70,
          createdAt: DateTime.now(),
          trigger: 'test',
        ),
      ];

      notifier.state = suggestions;
      notifier.dismissSuggestion('suggestion-1');

      expect(notifier.state.length, equals(1));
      expect(notifier.state.first.id, equals('suggestion-2'));
    });
  });

  group('ExerciseSuggestionsNotifier - clearSuggestions', () {
    test('should clear all suggestions', () {
      final notifier = ExerciseSuggestionsNotifier(MockRef(), 'exercise-1');
      final suggestions = [
        SmartSuggestion(
          id: 'suggestion-1',
          text: 'First',
          type: ContributionType.tip,
          contextType: 'test',
          priority: 80,
          createdAt: DateTime.now(),
          trigger: 'test',
        ),
      ];

      notifier.state = suggestions;
      notifier.clearSuggestions();

      expect(notifier.state, isEmpty);
    });
  });

  group('UserLevel enum', () {
    test('should have all expected values', () {
      expect(UserLevel.values.length, equals(4));
      expect(UserLevel.values, contains(UserLevel.rookie));
      expect(UserLevel.values, contains(UserLevel.contributor));
      expect(UserLevel.values, contains(UserLevel.expert));
      expect(UserLevel.values, contains(UserLevel.master));
    });
  });

  group('AppExperienceLevel enum', () {
    test('should have all expected values', () {
      expect(AppExperienceLevel.values.length, equals(3));
      expect(AppExperienceLevel.values, contains(AppExperienceLevel.beginner));
      expect(AppExperienceLevel.values, contains(AppExperienceLevel.intermediate));
      expect(AppExperienceLevel.values, contains(AppExperienceLevel.expert));
    });
  });

  group('FitnessExperienceLevel enum', () {
    test('should have all expected values', () {
      expect(FitnessExperienceLevel.values.length, equals(3));
      expect(FitnessExperienceLevel.values, contains(FitnessExperienceLevel.beginner));
      expect(FitnessExperienceLevel.values, contains(FitnessExperienceLevel.intermediate));
      expect(FitnessExperienceLevel.values, contains(FitnessExperienceLevel.expert));
    });
  });
}
