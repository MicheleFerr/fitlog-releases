import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/progression/domain/usecases/analyze_progression.dart';
import 'package:gymbro_flutter_new/features/progression/domain/entities/progression_suggestion.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_log.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';

void main() {
  late AnalyzeProgression usecase;

  setUp(() {
    usecase = AnalyzeProgression();
  });

  group('AnalyzeProgression', () {
    test('should suggest weight increase when plateau detected (10+ reps for 3 weeks)', () {
      // Mock 3 workouts with same weight, high reps
      final recentWorkouts = [
        ExerciseLog(
          name: 'Squat',
          sets: [
            ExerciseSet(
              setNumber: 1,
              weight: 80,
              reps: 10,
              isCompleted: true,
              isWarmup: false,
            ),
            ExerciseSet(
              setNumber: 2,
              weight: 80,
              reps: 10,
              isCompleted: true,
              isWarmup: false,
            ),
          ],
          date: DateTime(2025, 1, 1),
        ),
        ExerciseLog(
          name: 'Squat',
          sets: [
            ExerciseSet(
              setNumber: 1,
              weight: 80,
              reps: 11,
              isCompleted: true,
              isWarmup: false,
            ),
            ExerciseSet(
              setNumber: 2,
              weight: 80,
              reps: 10,
              isCompleted: true,
              isWarmup: false,
            ),
          ],
          date: DateTime(2025, 1, 8),
        ),
        ExerciseLog(
          name: 'Squat',
          sets: [
            ExerciseSet(
              setNumber: 1,
              weight: 80,
              reps: 12,
              isCompleted: true,
              isWarmup: false,
            ),
            ExerciseSet(
              setNumber: 2,
              weight: 80,
              reps: 11,
              isCompleted: true,
              isWarmup: false,
            ),
          ],
          date: DateTime(2025, 1, 15),
        ),
      ];

      final suggestion = usecase.execute(
        exerciseName: 'Squat',
        recentWorkouts: recentWorkouts,
        referenceDate: DateTime(2025, 1, 22),
      );

      expect(suggestion.suggestedWeight, 82.5);
      expect(suggestion.reason, contains('10+ reps easily for 3 weeks'));
      expect(suggestion.confidence, ProgressionConfidence.high);
    });

    test('should suggest reps focus when weight too heavy (reps < 6)', () {
      final recentWorkouts = [
        ExerciseLog(
          name: 'Bench',
          sets: [
            ExerciseSet(
              setNumber: 1,
              weight: 70,
              reps: 5,
              isCompleted: true,
              isWarmup: false,
            ),
            ExerciseSet(
              setNumber: 2,
              weight: 70,
              reps: 4,
              isCompleted: true,
              isWarmup: false,
            ),
          ],
          date: DateTime(2025, 1, 15),
        ),
      ];

      final suggestion = usecase.execute(
        exerciseName: 'Bench',
        recentWorkouts: recentWorkouts,
        referenceDate: DateTime(2025, 1, 22),
      );

      expect(suggestion.suggestedWeight, 70.0);
      expect(suggestion.targetReps, greaterThanOrEqualTo(8));
      expect(suggestion.reason, contains('hitting 8+ reps'));
    });
  });
}
