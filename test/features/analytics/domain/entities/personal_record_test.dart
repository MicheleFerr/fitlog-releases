import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/personal_record.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import '../../../../test_helpers/firebase_test_helper.dart';
import '../../../../helpers/test_setup.dart';

void main() {
  setUpAll(() async {
    mockSecureStorage();
    await setupTestEnvironment();
  });
  
  group('PersonalRecord', () {
    test('should create PR from exercise set correctly', () {
      // Arrange
      final set = ExerciseSet(
        setNumber: 1,
        weight: 100,
        reps: 10,
        isCompleted: true,
        completedAt: DateTime.now(),
      );

      // Act
      final pr = PersonalRecord.fromSet(
        exerciseName: 'Bench Press',
        exerciseId: 'exercise123',
        set: set,
        type: PRType.weight,
        workoutId: 'workout123',
      );

      // Assert
      expect(pr.exerciseName, equals('Bench Press'));
      expect(pr.type, equals(PRType.weight));
      expect(pr.value, equals(100));
      expect(pr.reps, equals(10));
      expect(pr.workoutId, equals('workout123'));
    });

    test('should format PR values correctly', () {
      // Arrange
      final weightPR = PersonalRecord(
        id: '1',
        exerciseName: 'Squat',
        exerciseId: 'ex1',
        type: PRType.weight,
        value: 150.5,
        achievedAt: DateTime.now(),
        workoutId: 'w1',
      );

      final volumePR = PersonalRecord(
        id: '2',
        exerciseName: 'Deadlift',
        exerciseId: 'ex2',
        type: PRType.volume,
        value: 1500,
        achievedAt: DateTime.now(),
        workoutId: 'w2',
      );

      final repsPR = PersonalRecord(
        id: '3',
        exerciseName: 'Push-ups',
        exerciseId: 'ex3',
        type: PRType.reps,
        value: 50,
        achievedAt: DateTime.now(),
        workoutId: 'w3',
      );

      // Act & Assert
      expect(weightPR.formattedValue, equals('150.5 kg'));
      expect(volumePR.formattedValue, equals('1500 kg'));
      expect(repsPR.formattedValue, equals('50 reps'));
    });

    test('should generate correct PR description', () {
      // Arrange
      final pr = PersonalRecord(
        id: '1',
        exerciseName: 'Bench Press',
        exerciseId: 'ex1',
        type: PRType.weight,
        value: 100,
        reps: 5,
        weight: 100,
        achievedAt: DateTime.now(),
        workoutId: 'w1',
      );

      // Act
      final description = pr.description;

      // Assert
      expect(description, equals('100.0 kg × 5 reps'));
    });

    test('should calculate 1RM correctly using Epley formula', () {
      // Arrange
      final set = ExerciseSet(
        setNumber: 1,
        weight: 100,
        reps: 10,
        isCompleted: true,
      );

      // Act
      final pr = PersonalRecord.fromSet(
        exerciseName: 'Squat',
        exerciseId: 'ex1',
        set: set,
        type: PRType.oneRM,
        workoutId: 'w1',
      );

      // Assert
      // Epley formula: 1RM = weight × (1 + reps/30)
      // 100 × (1 + 10/30) = 100 × 1.333... = 133.33...
      expect(pr.value, closeTo(133.33, 0.01));
    });

    test('should serialize and deserialize correctly', () {
      // Arrange
      final original = PersonalRecord(
        id: 'pr123',
        exerciseName: 'Deadlift',
        exerciseId: 'ex123',
        type: PRType.volume,
        value: 2000,
        reps: 10,
        weight: 200,
        achievedAt: DateTime(2024, 1, 1),
        workoutId: 'w123',
        metadata: {'setNumber': 3, 'isWarmup': false},
      );

      // Act
      final json = original.toJson();
      final deserialized = PersonalRecord.fromJson(json);

      // Assert
      expect(deserialized.id, equals(original.id));
      expect(deserialized.exerciseName, equals(original.exerciseName));
      expect(deserialized.type, equals(original.type));
      expect(deserialized.value, equals(original.value));
      expect(deserialized.metadata['setNumber'], equals(3));
    });
  });

  group('PRDetector', () {
    test('should detect new weight PR', () {
      // Arrange
      final historicalPRs = {
        'ex1': [
          PersonalRecord(
            id: 'old_pr',
            exerciseName: 'Bench Press',
            exerciseId: 'ex1',
            type: PRType.weight,
            value: 90,
            achievedAt: DateTime.now().subtract(const Duration(days: 7)),
            workoutId: 'old_workout',
          ),
        ],
      };

      final detector = PRDetector(historicalPRs: historicalPRs);

      final exercise = Exercise(
        id: 'ex1',
        name: 'Bench Press',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        sets: [
          ExerciseSet(
            setNumber: 1,
            weight: 100, // New PR!
            reps: 5,
            isCompleted: true,
            isWarmup: false,
          ),
        ],
      );

      // Act
      final result = detector.detectForExercise(exercise, 'current_workout');

      // Assert
      expect(result.hasNewPR, isTrue);
      expect(result.status, equals(PRStatus.newPR));
      expect(result.newPRs.length, greaterThan(0));
      expect(result.newPRs.first.value, equals(100));
    });

    test('should detect near PR status', () {
      // Arrange - must provide all 5 PR types to prevent false "new PR" detection
      final achievedAt = DateTime.now().subtract(const Duration(days: 7));
      final historicalPRs = {
        'ex1': [
          PersonalRecord(
            id: 'pr1',
            exerciseName: 'Squat',
            exerciseId: 'ex1',
            type: PRType.weight,
            value: 100,
            achievedAt: achievedAt,
            workoutId: 'old_workout',
          ),
          PersonalRecord(
            id: 'pr2',
            exerciseName: 'Squat',
            exerciseId: 'ex1',
            type: PRType.volume,
            value: 600, // > 97*5=485
            achievedAt: achievedAt,
            workoutId: 'old_workout',
          ),
          PersonalRecord(
            id: 'pr3',
            exerciseName: 'Squat',
            exerciseId: 'ex1',
            type: PRType.reps,
            value: 8, // > 5 reps
            weight: 97, // must match set weight within 2.5kg for reps PR filter
            achievedAt: achievedAt,
            workoutId: 'old_workout',
          ),
          PersonalRecord(
            id: 'pr4',
            exerciseName: 'Squat',
            exerciseId: 'ex1',
            type: PRType.oneRM,
            value: 130, // > 97*(1+5/30)=113.2
            achievedAt: achievedAt,
            workoutId: 'old_workout',
          ),
          PersonalRecord(
            id: 'pr5',
            exerciseName: 'Squat',
            exerciseId: 'ex1',
            type: PRType.totalVolume,
            value: 600, // > 485
            achievedAt: achievedAt,
            workoutId: 'old_workout',
          ),
        ],
      };

      final detector = PRDetector(historicalPRs: historicalPRs);

      final exercise = Exercise(
        id: 'ex1',
        name: 'Squat',
        type: ExerciseType.single,
        category: ExerciseCategory.legs,
        sets: [
          ExerciseSet(
            setNumber: 1,
            weight: 97, // 97% of PR
            reps: 5,
            isCompleted: true,
            isWarmup: false,
          ),
        ],
      );

      // Act
      final result = detector.detectForExercise(exercise, 'current_workout');

      // Assert
      expect(result.hasNewPR, isFalse);
      expect(result.status, equals(PRStatus.nearPR));
      expect(result.proximityPercentage, equals(97));
    });

    test('should detect volume PR', () {
      // Arrange
      final historicalPRs = {
        'ex1': [
          PersonalRecord(
            id: 'pr1',
            exerciseName: 'Deadlift',
            exerciseId: 'ex1',
            type: PRType.volume,
            value: 1000, // 100kg × 10 reps
            achievedAt: DateTime.now().subtract(const Duration(days: 7)),
            workoutId: 'old_workout',
          ),
        ],
      };

      final detector = PRDetector(historicalPRs: historicalPRs);

      final exercise = Exercise(
        id: 'ex1',
        name: 'Deadlift',
        type: ExerciseType.single,
        category: ExerciseCategory.back,
        sets: [
          ExerciseSet(
            setNumber: 1,
            weight: 90,
            reps: 12, // 90 × 12 = 1080 (new volume PR!)
            isCompleted: true,
            isWarmup: false,
          ),
        ],
      );

      // Act
      final result = detector.detectForExercise(exercise, 'current_workout');

      // Assert
      expect(result.hasNewPR, isTrue);
      final volumePR = result.newPRs.firstWhere((pr) => pr.type == PRType.volume);
      expect(volumePR.value, equals(1080));
    });

    test('should handle exercise with no historical PRs', () {
      // Arrange
      const detector = PRDetector(historicalPRs: {});

      final exercise = Exercise(
        id: 'new_ex',
        name: 'Lat Pulldown',
        type: ExerciseType.single,
        category: ExerciseCategory.back,
        sets: [
          ExerciseSet(
            setNumber: 1,
            weight: 50,
            reps: 12,
            isCompleted: true,
            isWarmup: false,
          ),
        ],
      );

      // Act
      final result = detector.detectForExercise(exercise, 'current_workout');

      // Assert
      expect(result.hasNewPR, isTrue);
      expect(result.status, equals(PRStatus.newPR));
      // Should detect multiple types of PRs for new exercise
      expect(result.newPRs.length, greaterThan(1));
    });

    test('should ignore warmup sets for PR detection', () {
      // Arrange
      const detector = PRDetector(historicalPRs: {});

      final exercise = Exercise(
        id: 'ex1',
        name: 'Bench Press',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        sets: [
          ExerciseSet(
            setNumber: 1,
            weight: 100,
            reps: 10,
            isCompleted: true,
            isWarmup: true, // Warmup set should be ignored
          ),
          ExerciseSet(
            setNumber: 2,
            weight: 80,
            reps: 8,
            isCompleted: true,
            isWarmup: false,
          ),
        ],
      );

      // Act
      final result = detector.detectForExercise(exercise, 'current_workout');

      // Assert
      expect(result.hasNewPR, isTrue);
      // Check that the PR is from the working set, not warmup
      expect(result.newPRs.first.value, equals(80));
    });

    test('should generate correct motivational message', () {
      // Arrange
      final newPRResult = PRDetectionResult(
        exerciseId: 'ex1',
        exerciseName: 'Squat',
        newPRs: [
          PersonalRecord(
            id: 'pr1',
            exerciseName: 'Squat',
            exerciseId: 'ex1',
            type: PRType.weight,
            value: 100,
            achievedAt: DateTime.now(),
            workoutId: 'w1',
          ),
        ],
        status: PRStatus.newPR,
      );

      const nearPRResult = PRDetectionResult(
        exerciseId: 'ex2',
        exerciseName: 'Bench Press',
        status: PRStatus.nearPR,
        proximityPercentage: 95,
      );

      // Act & Assert
      expect(newPRResult.getMotivationalMessage(), contains('NEW PERSONAL RECORD'));
      expect(nearPRResult.getMotivationalMessage(), contains('95% of your PR'));
    });
  });
}