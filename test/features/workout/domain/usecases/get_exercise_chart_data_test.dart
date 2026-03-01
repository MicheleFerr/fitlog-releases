import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/chart_data_point.dart';
import 'package:gymbro_flutter_new/features/workout/domain/failures/chart_failure.dart';
import 'package:gymbro_flutter_new/features/workout/domain/repositories/exercise_chart_repository.dart';
import 'package:gymbro_flutter_new/features/workout/domain/usecases/get_exercise_chart_data.dart';

class MockExerciseChartRepository extends Mock
    implements ExerciseChartRepository {}

void main() {
  late GetExerciseChartData usecase;
  late MockExerciseChartRepository mockRepository;

  setUp(() {
    mockRepository = MockExerciseChartRepository();
    usecase = GetExerciseChartData(mockRepository);
  });

  group('GetExerciseChartData', () {
    final tChartData = [
      ChartDataPoint(date: DateTime(2026, 1, 1), value: 80.0),
      ChartDataPoint(date: DateTime(2026, 1, 8), value: 82.5),
      ChartDataPoint(date: DateTime(2026, 1, 15), value: 85.0),
    ];

    test('should return chart data when repository call succeeds', () async {
      when(
        () => mockRepository.getChartData(
          exerciseName: any(named: 'exerciseName'),
          metric: any(named: 'metric'),
          days: any(named: 'days'),
        ),
      ).thenAnswer((_) async => Right(tChartData));

      final result = await usecase(
        exerciseName: 'Bench Press',
        metric: 'Peso',
      );

      expect(result.isRight(), isTrue);
      expect(
        result.getOrElse((_) => []),
        equals(tChartData),
      );
      verify(
        () => mockRepository.getChartData(
          exerciseName: 'Bench Press',
          metric: 'Peso',
          days: 90,
        ),
      ).called(1);
    });

    test('should pass default days = 90 to repository', () async {
      when(
        () => mockRepository.getChartData(
          exerciseName: any(named: 'exerciseName'),
          metric: any(named: 'metric'),
          days: any(named: 'days'),
        ),
      ).thenAnswer((_) async => Right(tChartData));

      await usecase(exerciseName: 'Squat', metric: 'Reps');

      verify(
        () => mockRepository.getChartData(
          exerciseName: 'Squat',
          metric: 'Reps',
          days: 90,
        ),
      ).called(1);
    });

    test('should pass custom days to repository', () async {
      when(
        () => mockRepository.getChartData(
          exerciseName: any(named: 'exerciseName'),
          metric: any(named: 'metric'),
          days: any(named: 'days'),
        ),
      ).thenAnswer((_) async => Right(tChartData));

      await usecase(exerciseName: 'Deadlift', metric: 'RPE', days: 30);

      verify(
        () => mockRepository.getChartData(
          exerciseName: 'Deadlift',
          metric: 'RPE',
          days: 30,
        ),
      ).called(1);
    });

    test('should return failure when repository returns failure', () async {
      const failure = ChartFailure.serverFailure(
        message: 'Network error',
      );

      when(
        () => mockRepository.getChartData(
          exerciseName: any(named: 'exerciseName'),
          metric: any(named: 'metric'),
          days: any(named: 'days'),
        ),
      ).thenAnswer((_) async => const Left(failure));

      final result = await usecase(
        exerciseName: 'Bench Press',
        metric: 'Peso',
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<ChartServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('should return invalid input failure', () async {
      const failure = ChartFailure.invalidInput(
        message: 'Invalid exercise name',
      );

      when(
        () => mockRepository.getChartData(
          exerciseName: any(named: 'exerciseName'),
          metric: any(named: 'metric'),
          days: any(named: 'days'),
        ),
      ).thenAnswer((_) async => const Left(failure));

      final result = await usecase(
        exerciseName: '',
        metric: 'Peso',
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<ChartInvalidInputFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('should return empty list when no data available', () async {
      when(
        () => mockRepository.getChartData(
          exerciseName: any(named: 'exerciseName'),
          metric: any(named: 'metric'),
          days: any(named: 'days'),
        ),
      ).thenAnswer((_) async => const Right([]));

      final result = await usecase(
        exerciseName: 'Unknown Exercise',
        metric: 'Peso',
      );

      expect(result.isRight(), isTrue);
      expect(
        result.getOrElse((_) => [ChartDataPoint(date: DateTime.now(), value: 0)]),
        isEmpty,
      );
    });

    test('should return unknown failure', () async {
      const failure = ChartFailure.unknown(
        message: 'Something went wrong',
      );

      when(
        () => mockRepository.getChartData(
          exerciseName: any(named: 'exerciseName'),
          metric: any(named: 'metric'),
          days: any(named: 'days'),
        ),
      ).thenAnswer((_) async => const Left(failure));

      final result = await usecase(
        exerciseName: 'Bench Press',
        metric: 'TUT',
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<ChartUnknownFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });
}
