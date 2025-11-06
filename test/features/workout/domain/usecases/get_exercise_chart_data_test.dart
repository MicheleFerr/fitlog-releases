/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: test/domain/usecases
/// 🎯 Feature: workout
/// 🔧 Type: unit test (GetExerciseChartData use case)
///
/// Dependencies:
/// - mockito: Mocking
/// - fpdart: Either testing
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/chart_data_point.dart';
import 'package:gymbro_flutter_new/features/workout/domain/repositories/exercise_chart_repository.dart';
import 'package:gymbro_flutter_new/features/workout/domain/usecases/get_exercise_chart_data.dart';
import 'package:gymbro_flutter_new/features/workout/domain/failures/chart_failure.dart';

@GenerateMocks([ExerciseChartRepository])
import 'get_exercise_chart_data_test.mocks.dart';

void main() {
  late GetExerciseChartData useCase;
  late MockExerciseChartRepository mockRepository;

  setUpAll(() {
    // Provide dummy value for Either type to satisfy Mockito
    provideDummyBuilder<Either<ChartFailure, List<ChartDataPoint>>>(
      (_, __) => right([]),
    );
  });

  setUp(() {
    mockRepository = MockExerciseChartRepository();
    useCase = GetExerciseChartData(mockRepository);
  });

  group('GetExerciseChartData', () {
    const tExerciseName = 'Bench Press';
    const tMetric = 'Peso';
    const tDays = 90;

    final tChartData = [
      ChartDataPoint(
        date: DateTime(2024, 1, 1),
        value: 80.0,
      ),
      ChartDataPoint(
        date: DateTime(2024, 1, 8),
        value: 85.0,
      ),
      ChartDataPoint(
        date: DateTime(2024, 1, 15),
        value: 90.0,
      ),
    ];

    test('should return Right with chart data when repository returns success', () async {
      // Arrange
      when(mockRepository.getChartData(
        exerciseName: anyNamed('exerciseName'),
        metric: anyNamed('metric'),
        days: anyNamed('days'),
      )).thenAnswer((_) async => right(tChartData));

      // Act
      final result = await useCase(
        exerciseName: tExerciseName,
        metric: tMetric,
        days: tDays,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (data) {
          expect(data, tChartData);
          expect(data.length, 3);
        },
      );
      verify(mockRepository.getChartData(
        exerciseName: tExerciseName,
        metric: tMetric,
        days: tDays,
      )).called(1);
    });

    test('should return Left with InvalidInput when repository returns InvalidInput failure', () async {
      // Arrange
      const tFailure = ChartFailure.invalidInput(message: 'Invalid metric');
      when(mockRepository.getChartData(
        exerciseName: anyNamed('exerciseName'),
        metric: anyNamed('metric'),
        days: anyNamed('days'),
      )).thenAnswer((_) async => left(tFailure));

      // Act
      final result = await useCase(
        exerciseName: tExerciseName,
        metric: 'InvalidMetric',
        days: tDays,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, tFailure);
          failure.when(
            invalidInput: (message, details) {
              expect(message, 'Invalid metric');
            },
            dataNotFound: (_) => fail('Wrong failure type'),
            cacheFailure: (_, __) => fail('Wrong failure type'),
            serverFailure: (_, __) => fail('Wrong failure type'),
            unknown: (_, __, ___) => fail('Wrong failure type'),
          );
        },
        (data) => fail('Should not return data'),
      );
    });

    test('should return Left with DataNotFound when repository has no data', () async {
      // Arrange
      const tFailure = ChartFailure.dataNotFound(message: 'No data found');
      when(mockRepository.getChartData(
        exerciseName: anyNamed('exerciseName'),
        metric: anyNamed('metric'),
        days: anyNamed('days'),
      )).thenAnswer((_) async => left(tFailure));

      // Act
      final result = await useCase(
        exerciseName: tExerciseName,
        metric: tMetric,
        days: tDays,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<DataNotFound>()),
        (data) => fail('Should not return data'),
      );
    });

    test('should return empty list when repository returns Right with empty list', () async {
      // Arrange
      when(mockRepository.getChartData(
        exerciseName: anyNamed('exerciseName'),
        metric: anyNamed('metric'),
        days: anyNamed('days'),
      )).thenAnswer((_) async => right([]));

      // Act
      final result = await useCase(
        exerciseName: tExerciseName,
        metric: tMetric,
        days: tDays,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (data) {
          expect(data, isEmpty);
        },
      );
    });

    test('should pass correct parameters to repository', () async {
      // Arrange
      when(mockRepository.getChartData(
        exerciseName: anyNamed('exerciseName'),
        metric: anyNamed('metric'),
        days: anyNamed('days'),
      )).thenAnswer((_) async => right([]));

      // Act
      await useCase(
        exerciseName: 'Squat',
        metric: 'Reps',
        days: 30,
      );

      // Assert
      verify(mockRepository.getChartData(
        exerciseName: 'Squat',
        metric: 'Reps',
        days: 30,
      )).called(1);
    });
  });
}
