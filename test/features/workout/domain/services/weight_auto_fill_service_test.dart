import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/weight_auto_fill_service.dart';
import 'package:gymbro_flutter_new/features/workout/data/services/exercise_history_service.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'weight_auto_fill_service_test.mocks.dart';

@GenerateMocks([ExerciseHistoryService])
void main() {
  late MockExerciseHistoryService mockHistory;
  late WeightAutoFillService sut;

  setUp(() {
    mockHistory = MockExerciseHistoryService();
    sut = WeightAutoFillService(historyService: mockHistory);
  });

  group('fillFromHistory', () {
    test('populates weight from last session', () async {
      final workout = _buildWorkout([_buildExercise('Squat', sets: 3)]);
      when(mockHistory.getLastExerciseData('Squat', 'user1')).thenAnswer(
        (_) async => (weight: 100.0, date: DateTime.now()),
      );

      final result =
          await sut.fillFromHistory(workout: workout, userId: 'user1');

      final sets = result.exercises.first.sets;
      expect(sets.every((s) => s.weight == 100.0), isTrue);
    });

    test('leaves sets unchanged when no history', () async {
      final workout = _buildWorkout([_buildExercise('Squat', sets: 2)]);
      when(mockHistory.getLastExerciseData('Squat', 'user1')).thenAnswer(
        (_) async => (weight: null, date: null),
      );

      final result =
          await sut.fillFromHistory(workout: workout, userId: 'user1');

      expect(
          result.exercises.first.sets.every((s) => s.weight == null), isTrue);
    });

    test('returns original workout silently on error', () async {
      final workout = _buildWorkout([_buildExercise('Squat', sets: 2)]);
      when(mockHistory.getLastExerciseData(any, any))
          .thenThrow(Exception('fail'));

      final result =
          await sut.fillFromHistory(workout: workout, userId: 'user1');

      expect(result, equals(workout));
    });
  });
}

Workout _buildWorkout(List<Exercise> exercises) => Workout(
      id: 'w1',
      name: 'Test',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      exercises: exercises,
    );

Exercise _buildExercise(String name, {required int sets}) => Exercise(
      id: 'e1',
      name: name,
      type: ExerciseType.single,
      category: ExerciseCategory.legs,
      sets: List.generate(
        sets,
        (i) => ExerciseSet(id: 'set$i', setNumber: i + 1),
      ),
    );
