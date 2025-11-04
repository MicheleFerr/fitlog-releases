/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: domain/usecases
/// 🎯 Feature: workout
/// 🔧 Type: use case (business logic)
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// Dependencies:
/// - fpdart: Either type
/// - Domain repository interface
library;

import 'package:fpdart/fpdart.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/chart_data_point.dart';
import 'package:gymbro_flutter_new/features/workout/domain/failures/chart_failure.dart';
import 'package:gymbro_flutter_new/features/workout/domain/repositories/exercise_chart_repository.dart';

/// Use case: Get exercise chart data
///
/// Clean Architecture:
/// - Incapsula business logic
/// - Usa repository interface (non implementation)
/// - Returns Either<Failure, Success>
class GetExerciseChartData {

  const GetExerciseChartData(this._repository);
  final ExerciseChartRepository _repository;

  /// Execute use case
  ///
  /// Parameters:
  /// - exerciseName: Nome esercizio
  /// - metric: Metrica (Peso, Reps, RPE, TUT)
  /// - days: Numero giorni da includere (default 90)
  ///
  /// Returns Either<ChartFailure, List<ChartDataPoint>>
  Future<Either<ChartFailure, List<ChartDataPoint>>> call({
    required String exerciseName,
    required String metric,
    int days = 90,
  }) async {
    return await _repository.getChartData(
      exerciseName: exerciseName,
      metric: metric,
      days: days,
    );
  }
}
