/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: domain/repositories
/// 🎯 Feature: workout
/// 🔧 Type: repository interface (abstract)
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// Dependencies:
/// - fpdart: Either type for error handling
/// - Domain entities
library;

import 'package:fpdart/fpdart.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/chart_data_point.dart';
import 'package:gymbro_flutter_new/features/workout/domain/failures/chart_failure.dart';

/// Abstract repository per chart data
///
/// Clean Architecture: Domain layer non dipende da implementazione
/// Data layer implementa questa interfaccia
abstract class ExerciseChartRepository {
  /// Get chart data per esercizio e metrica
  ///
  /// Returns:
  /// - Right(List<ChartDataPoint>): Success con dati
  /// - Left(ChartFailure): Failure con errore
  Future<Either<ChartFailure, List<ChartDataPoint>>> getChartData({
    required String exerciseName,
    required String metric,
    int days = 90,
  });
}
