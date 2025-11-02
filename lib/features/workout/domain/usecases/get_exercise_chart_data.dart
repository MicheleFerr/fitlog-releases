/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: domain/usecases
/// 🎯 Feature: workout
/// 🔧 Type: use case (Get Chart Data)
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// Dependencies:
/// - ChartDataPoint entity
/// - ExerciseChartRepository interface
library;

import 'package:fpdart/fpdart.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/chart_data_point.dart';
import 'package:gymbro_flutter_new/features/workout/domain/repositories/exercise_chart_repository.dart';
import 'package:gymbro_flutter_new/features/workout/domain/failures/chart_failure.dart';

/// Use case per ottenere dati grafico esercizio
///
/// Clean Architecture: Incapsula business logic, isola presentation da data layer.
///
/// Dependency Injection: Repository iniettato via costruttore (testabile)
///
/// FASE 1: Return type semplice
/// FASE 2: Aggiornato con Either<Failure, List<ChartDataPoint>>
class GetExerciseChartData {
  final ExerciseChartRepository _repository;

  const GetExerciseChartData(this._repository);

  /// Esegue use case: ottiene e valida dati grafico
  ///
  /// [exerciseName] - Nome esercizio
  /// [metric] - Metrica (Peso/Reps/RPE/TUT)
  /// [days] - Giorni da visualizzare (default 90)
  ///
  /// Business rules:
  /// - Validazione input delegata al repository
  /// - Ordinamento delegato al repository
  /// - Limiti agli ultimi N giorni
  ///
  /// Returns Either:
  /// - Right: Lista ChartDataPoint (può essere vuota se nessun dato)
  /// - Left: ChartFailure specifico
  ///
  /// FASE 2: ✅ Either pattern implementato
  Future<Either<ChartFailure, List<ChartDataPoint>>> call({
    required String exerciseName,
    required String metric,
    int days = 90,
  }) async {
    // Delega al repository (validazione + data retrieval)
    final result = await _repository.getChartData(
      exerciseName: exerciseName,
      metric: metric,
      days: days,
    );

    // Use case può applicare business logic addizionale qui se necessario
    // FASE 2: Per ora passa direttamente il risultato del repository
    return result;
  }
}
